import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_adjustment_requests_state.dart';

/// Cubit de lectura de solicitudes de ajuste.
///
/// Es dueño de los filtros, del offset y de la lista visible. Se suscribe al
/// [ReactiveRepository.eventStream] del repositorio para reflejar altas,
/// cambios y bajas sin refetch.
class ReadAdjustmentRequestsCubit extends Cubit<ReadAdjustmentRequestsState> {
  ReadAdjustmentRequestsCubit({
    required this.repository,
    required this.branchId,
    this.defaultCreatorId,
  }) : super(ReadAdjustmentRequestsInitial()) {
    final today = DateTimeTool.getTodayMidnight();
    startDate = today.subtract(const Duration(days: 29));
    endDate = today;
    createdBy = defaultCreatorId;
    _subscription = repository.eventStream.listen(_handleRepoEvent);
  }

  static const int pageSize = 50;

  final AdjustmentRequestsRepository repository;
  final String branchId;

  /// Usuario por defecto para roles que solo pueden ver sus propias
  /// solicitudes (Vendedor / Pre-Venta).
  final String? defaultCreatorId;

  StreamSubscription<RepoEvent<AdjustmentRequestInDb>>? _subscription;

  DateTime? startDate;
  DateTime? endDate;
  String? status;
  String? createdBy;
  String? docNumber;

  int _offset = 0;
  bool _isLastPage = false;
  int _generation = 0;

  bool get isLastPage => _isLastPage;

  AdjustmentRequestQueryParams _buildParams({int? offset}) {
    return AdjustmentRequestQueryParams(
      offset: offset ?? _offset,
      limit: pageSize,
      branchId: branchId,
      status: status,
      createdBy: createdBy,
      docNumber: docNumber,
      startDate: startDate?.millisecondsSinceEpoch,
      // El backend compara createdAt <= endDate.
      endDate: endDate?.endOfDay().millisecondsSinceEpoch,
    );
  }

  Future<void> loadFirstPage() async {
    final currentState = state;
    if (currentState is ReadAdjustmentRequestsSuccess) {
      emit(
        currentState.copyWith(
          isRefreshing: true,
          isLoadingMore: false,
          clearLoadMoreError: true,
        ),
      );
    } else {
      emit(ReadAdjustmentRequestsLoading());
    }

    _offset = 0;
    _isLastPage = false;
    final generation = ++_generation;

    try {
      final results = await repository.getAllAdjustmentRequests(_buildParams(offset: 0));
      if (isClosed || generation != _generation) return;

      _offset = results.length;
      _isLastPage = results.length < pageSize;

      emit(
        ReadAdjustmentRequestsSuccess(
          items: results,
          hasMore: !_isLastPage,
        ),
      );
    } catch (error) {
      if (isClosed || generation != _generation) return;
      emit(ReadAdjustmentRequestsError(_friendlyError(error)));
    }
  }

  Future<void> refresh() => loadFirstPage();

  Future<void> applyFilters({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? createdBy,
    String? docNumber,
  }) {
    this.startDate = startDate;
    this.endDate = endDate;
    this.status = status;
    this.createdBy = createdBy;
    this.docNumber = docNumber;
    return loadFirstPage();
  }

  Future<void> clearFilters() {
    final today = DateTimeTool.getTodayMidnight();
    return applyFilters(
      startDate: today.subtract(const Duration(days: 29)),
      endDate: today,
      status: null,
      createdBy: defaultCreatorId,
      docNumber: null,
    );
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! ReadAdjustmentRequestsSuccess) return;
    if (currentState.isLoadingMore || currentState.isRefreshing || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true, clearLoadMoreError: true));
    final generation = _generation;

    try {
      final results = await repository.getAllAdjustmentRequests(_buildParams());
      if (isClosed || generation != _generation) return;

      final latestState = state;
      if (latestState is! ReadAdjustmentRequestsSuccess) return;

      final existingIds = latestState.items.map((request) => request.id).toSet();
      final uniqueResults = results.where((request) => !existingIds.contains(request.id)).toList(growable: false);

      _offset += results.length;
      _isLastPage = results.length < pageSize;

      emit(
        latestState.copyWith(
          items: [...latestState.items, ...uniqueResults],
          hasMore: !_isLastPage,
          isLoadingMore: false,
          clearLoadMoreError: true,
        ),
      );
    } catch (error) {
      if (isClosed || generation != _generation) return;
      final latestState = state;
      if (latestState is! ReadAdjustmentRequestsSuccess) return;
      emit(
        latestState.copyWith(
          isLoadingMore: false,
          loadMoreError: _friendlyError(error),
        ),
      );
    }
  }

  void _handleRepoEvent(RepoEvent<AdjustmentRequestInDb> event) {
    switch (event) {
      case RepoItemCreated(:final item):
        _markCreated(item);
      case RepoItemUpdated(:final item):
        _markUpdated(item);
      case RepoItemDeleted(:final item):
        _markDeleted(item);
    }
  }

  void _markCreated(AdjustmentRequestInDb item) {
    final currentState = state;
    if (currentState is! ReadAdjustmentRequestsSuccess) return;
    if (!_matchesFilters(item)) return;

    final alreadyPresent = currentState.items.any((request) => request.id == item.id);
    if (alreadyPresent) {
      _markUpdated(item);
      return;
    }

    _offset += 1;
    emit(
      currentState.copyWith(
        items: [item, ...currentState.items],
      ),
    );
  }

  void _markUpdated(AdjustmentRequestInDb item) {
    final currentState = state;
    if (currentState is! ReadAdjustmentRequestsSuccess) return;

    final index = currentState.items.indexWhere((request) => request.id == item.id);
    final matches = _matchesFilters(item);

    if (index == -1) {
      if (!matches) return;
      _offset += 1;
      emit(currentState.copyWith(items: [item, ...currentState.items]));
      return;
    }

    if (!matches) {
      _offset = (_offset - 1).clamp(0, 1 << 30);
      emit(
        currentState.copyWith(
          items: currentState.items.where((request) => request.id != item.id).toList(growable: false),
        ),
      );
      return;
    }

    final updatedItems = List<AdjustmentRequestInDb>.of(currentState.items);
    updatedItems[index] = item;
    emit(currentState.copyWith(items: updatedItems));
  }

  void _markDeleted(AdjustmentRequestInDb item) {
    final currentState = state;
    if (currentState is! ReadAdjustmentRequestsSuccess) return;

    final wasVisible = currentState.items.any((request) => request.id == item.id);
    if (!wasVisible) return;

    _offset = (_offset - 1).clamp(0, 1 << 30);
    emit(
      currentState.copyWith(
        items: currentState.items.where((request) => request.id != item.id).toList(growable: false),
      ),
    );
  }

  bool _matchesFilters(AdjustmentRequestInDb item) {
    if (item.branchId != branchId) return false;
    if (status != null && item.status.name != status) return false;
    if (createdBy != null && item.createdBy.id != createdBy) return false;

    final query = docNumber?.trim().toLowerCase();
    if (query != null && query.isNotEmpty && !item.docNumber.toLowerCase().contains(query)) {
      return false;
    }

    final start = startDate;
    if (start != null && item.createdAt < start.millisecondsSinceEpoch) return false;

    final end = endDate;
    if (end != null && item.createdAt > end.endOfDay().millisecondsSinceEpoch) return false;

    return true;
  }

  String _friendlyError(Object error) {
    return mapAdjustmentRequestErrorMessage(error);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}

/// Centraliza la traducción de errores del backend a mensajes legibles.
String mapAdjustmentRequestErrorMessage(Object error) {
  final raw = error.toString().replaceFirst('HttpServiceException: ', '').trim();

  if (raw.contains('SELF_APPROVAL_NOT_ALLOWED')) {
    return 'No puedes aprobar una solicitud creada por ti. Solicita la aprobación a otro usuario.';
  }
  if (raw.contains('INSUFFICIENT_STOCK_FOR_ADJUSTMENT')) {
    return 'Stock insuficiente para aplicar el ajuste. Verifica las existencias actuales de la sucursal.';
  }
  if (raw.contains('REQUEST_CHANGED_RETRY')) {
    return 'La solicitud cambió mientras la aprobabas. Recarga e intenta de nuevo.';
  }
  if (raw.contains('ONLY_PENDING_REQUESTS_CAN_BE_APPROVED')) {
    return 'Solo las solicitudes pendientes pueden aprobarse.';
  }
  if (raw.contains('ONLY_PENDING_REQUESTS_CAN_BE_UPDATED')) {
    return 'Solo las solicitudes pendientes pueden editarse.';
  }
  if (raw.contains('ONLY_PENDING_REQUESTS_CAN_BE_CANCELLED')) {
    return 'Solo las solicitudes pendientes pueden cancelarse.';
  }
  if (raw.contains('ADJUSTMENT_REQUEST_WITHOUT_DIFFERENCES')) {
    return 'La solicitud no tiene diferencias para aplicar.';
  }
  if (raw.contains('ADJUSTMENT_REQUEST_ITEMS_REQUIRED')) {
    return 'La solicitud debe incluir al menos un producto.';
  }
  if (raw.contains('DUPLICATED_PRODUCT_IDS')) {
    return 'La solicitud contiene productos duplicados.';
  }
  if (raw.contains('INVALID_COUNTED_QUANTITY')) {
    return 'La cantidad contada no puede ser negativa.';
  }
  if (raw.contains('SURPLUS_COST_REQUIRED')) {
    return 'El costo de los productos con sobrante debe ser mayor a cero.';
  }
  if (raw.contains('ADJUSTMENT_REQUEST_NOT_FOUND')) {
    return 'La solicitud de ajuste ya no existe.';
  }

  return raw.isEmpty ? 'Ocurrió un error inesperado. Intenta nuevamente.' : raw;
}
