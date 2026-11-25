import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_quotation_order_search_state.dart';

class ReadQuotationOrderSearchCubit extends Cubit<ReadQuotationOrderSearchState> {
  ReadQuotationOrderSearchCubit({
    required this.ordersRepository,
    this.defaultCreatorId,
  }) : super(ReadQuotationOrderSearchInitial()) {
    startDate = DateTimeTool.getTodayMidnight();
    endDate = startDate;
    userCreatorId = defaultCreatorId;
    _subscription = ordersRepository.eventStream.listen(_handleRepoEvent);
  }

  final OrdersRepository ordersRepository;
  final String? defaultCreatorId;

  StreamSubscription<RepoEvent<OrderInDb>>? _subscription;

  String? _branchId;
  String? userCreatorId;
  DateTime? startDate;
  DateTime? endDate;
  String? clientId;

  int offset = 0;
  bool isLastPage = false;

  final Set<String> _newOrderIds = {};
  final Set<String> _updatedOrderIds = {};

  Future<void> loadDocuments(String branchId) async {
    _branchId = branchId;
    emit(ReadQuotationOrderSearchLoading());
    offset = 0;
    isLastPage = false;
    try {
      final response = await ordersRepository.getPaginatedOrders(
        queryParams: _buildParams(branchId),
      );

      _newOrderIds.clear();
      _updatedOrderIds.clear();

      offset += response.data.length;
      isLastPage = response.data.length < 1000;

      final totalAmount = _sumOrdersTotal(response.data);

      if (isClosed) return;
      emit(
        ReadQuotationOrderSearchSuccess(
          response.data,
          offset,
          totalAmount,
          newOrderIds: Set<String>.unmodifiable(_newOrderIds),
          updatedOrderIds: Set<String>.unmodifiable(_updatedOrderIds),
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(ReadQuotationOrderSearchError(e.toString()));
    }
  }

  Future<void> nextPage(String branchId) async {
    _branchId ??= branchId;
    if (isLastPage) return;
    final currentState = state;
    if (currentState is! ReadQuotationOrderSearchSuccess) return;
    if (currentState is ReadQuotationOrderSearchLoadingMore) return;

    emit(
      ReadQuotationOrderSearchLoadingMore(
        currentState.orders,
        currentState.totalCount,
        currentState.totalAmount,
        newOrderIds: currentState.newOrderIds,
        updatedOrderIds: currentState.updatedOrderIds,
      ),
    );
    try {
      final response = await ordersRepository.getPaginatedOrders(
        queryParams: _buildParams(branchId),
      );

      offset += response.data.length;
      isLastPage = response.data.length < 1000;

      final combined = [...currentState.orders, ...response.data];
      final totalAmount = _sumOrdersTotal(combined);

      if (isClosed) return;
      emit(
        ReadQuotationOrderSearchSuccess(
          combined,
          offset,
          totalAmount,
          newOrderIds: Set<String>.unmodifiable(_newOrderIds),
          updatedOrderIds: Set<String>.unmodifiable(_updatedOrderIds),
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(ReadQuotationOrderSearchError(e.toString()));
    }
  }

  OrderQueryParams _buildParams(String branchId) {
    final effectiveUserCreatorId = defaultCreatorId ?? userCreatorId;
    final topEndDate = endDate?.add(const Duration(days: 1));

    return OrderQueryParams(
      skip: offset,
      limit: 1000,
      branchId: branchId,
      clientId: clientId,
      startDate: startDate?.millisecondsSinceEpoch,
      endDate: topEndDate?.millisecondsSinceEpoch,
      createdBy: effectiveUserCreatorId,
    );
  }

  void clearFilters(String branchId) {
    startDate = DateTimeTool.getTodayMidnight();
    endDate = startDate;
    clientId = null;
    userCreatorId = defaultCreatorId;
    offset = 0;
    isLastPage = false;
    loadDocuments(branchId);
  }

  void updateOrderInCache(OrderInDb order) {
    final currentState = state;
    if (currentState is! ReadQuotationOrderSearchSuccess) return;

    final index = currentState.orders.indexWhere((e) => e.id == order.id);
    if (index == -1) return;

    final newOrders = List<OrderInDb>.from(currentState.orders);
    newOrders[index] = order;

    _newOrderIds.remove(order.id);
    _updatedOrderIds.add(order.id);

    emit(
      ReadQuotationOrderSearchSuccess(
        newOrders,
        currentState.totalCount,
        _sumOrdersTotal(newOrders),
        newOrderIds: Set<String>.unmodifiable(_newOrderIds),
        updatedOrderIds: Set<String>.unmodifiable(_updatedOrderIds),
      ),
    );
  }

  void _handleRepoEvent(RepoEvent<OrderInDb> event) {
    final currentState = state;
    if (isClosed || currentState is! ReadQuotationOrderSearchSuccess) return;

    switch (event) {
      case RepoItemCreated<OrderInDb>(:final item):
        if (!_matchesFilters(item)) return;
        if (currentState.orders.any((e) => e.id == item.id)) return;

        final updatedOrders = [item, ...currentState.orders];
        offset += 1;
        _updatedOrderIds.remove(item.id);
        _newOrderIds.add(item.id);

        emit(
          ReadQuotationOrderSearchSuccess(
            updatedOrders,
            currentState.totalCount + 1,
            _sumOrdersTotal(updatedOrders),
            newOrderIds: Set<String>.unmodifiable(_newOrderIds),
            updatedOrderIds: Set<String>.unmodifiable(_updatedOrderIds),
          ),
        );

      case RepoItemUpdated<OrderInDb>(:final item):
        final index = currentState.orders.indexWhere((e) => e.id == item.id);
        final matches = _matchesFilters(item);

        if (!matches) {
          if (index == -1) return;
          final updatedOrders = currentState.orders.where((e) => e.id != item.id).toList();
          offset = (offset - 1).clamp(0, 1 << 30);
          final nextCount = (currentState.totalCount - 1).clamp(0, 1 << 30);
          _newOrderIds.remove(item.id);
          _updatedOrderIds.remove(item.id);

          emit(
            ReadQuotationOrderSearchSuccess(
              updatedOrders,
              nextCount,
              _sumOrdersTotal(updatedOrders),
              newOrderIds: Set<String>.unmodifiable(_newOrderIds),
              updatedOrderIds: Set<String>.unmodifiable(_updatedOrderIds),
            ),
          );
          return;
        }

        final List<OrderInDb> updatedOrders;
        final int nextCount;
        if (index == -1) {
          updatedOrders = [item, ...currentState.orders];
          offset += 1;
          nextCount = currentState.totalCount + 1;
        } else {
          updatedOrders = List<OrderInDb>.from(currentState.orders);
          updatedOrders[index] = item;
          nextCount = currentState.totalCount;
        }

        _newOrderIds.remove(item.id);
        _updatedOrderIds.add(item.id);

        emit(
          ReadQuotationOrderSearchSuccess(
            updatedOrders,
            nextCount,
            _sumOrdersTotal(updatedOrders),
            newOrderIds: Set<String>.unmodifiable(_newOrderIds),
            updatedOrderIds: Set<String>.unmodifiable(_updatedOrderIds),
          ),
        );

      case RepoItemDeleted<OrderInDb>(:final item):
        final exists = currentState.orders.any((e) => e.id == item.id);
        if (!exists) return;

        final updatedOrders = currentState.orders.where((e) => e.id != item.id).toList();
        offset = (offset - 1).clamp(0, 1 << 30);
        final nextCount = (currentState.totalCount - 1).clamp(0, 1 << 30);
        _newOrderIds.remove(item.id);
        _updatedOrderIds.remove(item.id);

        emit(
          ReadQuotationOrderSearchSuccess(
            updatedOrders,
            nextCount,
            _sumOrdersTotal(updatedOrders),
            newOrderIds: Set<String>.unmodifiable(_newOrderIds),
            updatedOrderIds: Set<String>.unmodifiable(_updatedOrderIds),
          ),
        );
    }
  }

  bool _matchesFilters(OrderInDb item) {
    if (_branchId != null && item.branchId != _branchId) return false;
    final effectiveCreator = defaultCreatorId ?? userCreatorId;
    if (effectiveCreator != null && item.createdBy.id != effectiveCreator) return false;
    if (clientId != null && item.clientId != clientId) return false;

    final createdMs = item.createdAt.millisecondsSinceEpoch;
    final start = startDate;
    if (start != null && createdMs < start.millisecondsSinceEpoch) {
      return false;
    }

    final end = endDate;
    if (end != null) {
      final topEndMs = end.add(const Duration(days: 1)).millisecondsSinceEpoch;
      if (createdMs > topEndMs) return false;
    }

    return true;
  }

  int _sumOrdersTotal(List<OrderInDb> orders) {
    var total = 0;
    for (final order in orders) {
      total += order.total;
    }
    return total;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
