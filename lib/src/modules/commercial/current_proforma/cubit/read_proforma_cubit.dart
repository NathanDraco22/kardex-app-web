import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_proforma_state.dart';

class ReadProformaCubit extends Cubit<ReadProformaState> {
  ReadProformaCubit({
    required this.ordersRepository,
    this.defaultCreatorId,
  }) : createdBy = defaultCreatorId,
       super(ReadProformaInitial()) {
    _subscription = ordersRepository.eventStream.listen(_handleRepoEvent);
  }

  final OrdersRepository ordersRepository;
  final String? defaultCreatorId;

  StreamSubscription<RepoEvent<OrderInDb>>? _subscription;

  bool isLastPage = false;
  List<OrderInDb> _ordersCache = [];
  final Set<String> _newOrderIds = {};
  final Set<String> _updatedOrderIds = {};

  String? _branchId;
  String? clientId;
  String? createdBy;

  Future<void> loadPaginatedOrders(String branchId) async {
    _branchId = branchId;
    emit(ReadProformaLoading());
    try {
      final response = await ordersRepository.getPaginatedOrders(
        queryParams: OrderQueryParams(
          skip: 0,
          limit: 1000,
          branchId: branchId,
          clientId: clientId,
          status: OrderStatus.draft,
          createdBy: defaultCreatorId ?? createdBy,
        ),
      );

      _ordersCache = List<OrderInDb>.from(response.data);
      _newOrderIds.clear();
      _updatedOrderIds.clear();

      if (_ordersCache.length >= response.count) {
        isLastPage = true;
      } else {
        isLastPage = false;
      }
      if (isClosed) return;
      emit(_buildSuccessState(count: response.count));
    } catch (error) {
      if (isClosed) return;
      emit(ReadProformaError(error.toString()));
    }
  }

  Future<void> setFilterParams({
    String? clientId,
    String? createdBy,
  }) async {
    this.clientId = clientId;
    this.createdBy = defaultCreatorId ?? createdBy;
    _ordersCache = [];
    isLastPage = false;
  }

  Future<void> clearFilterParams() async {
    clientId = null;
    createdBy = defaultCreatorId;
    _ordersCache = [];
    isLastPage = false;
  }

  Future<void> updateOrderCache(OrderInDb order) async {
    final index = _ordersCache.indexWhere((element) => element.id == order.id);
    if (index != -1) {
      _ordersCache[index] = order;
      _newOrderIds.remove(order.id);
      _updatedOrderIds.add(order.id);
      if (isClosed) return;
      emit(_buildSuccessState());
    }
  }

  Future<void> deleteOrderDraft(String orderId) async {
    final index = _ordersCache.indexWhere((element) => element.id == orderId);
    if (index != -1) {
      _ordersCache.removeAt(index);
      _newOrderIds.remove(orderId);
      _updatedOrderIds.remove(orderId);
      if (isClosed) return;
      emit(_buildSuccessState());
    }
  }

  void _handleRepoEvent(RepoEvent<OrderInDb> event) {
    if (isClosed || state is! ReadProformaSuccess) return;

    switch (event) {
      case RepoItemCreated<OrderInDb>(:final item):
        if (!_matchesFilters(item)) return;
        final exists = _ordersCache.any((element) => element.id == item.id);
        if (exists) return;
        _ordersCache = [item, ..._ordersCache];
        _updatedOrderIds.remove(item.id);
        _newOrderIds.add(item.id);
        emit(_buildSuccessState());

      case RepoItemUpdated<OrderInDb>(:final item):
        final index = _ordersCache.indexWhere((element) => element.id == item.id);
        final matches = _matchesFilters(item);

        if (!matches) {
          if (index == -1) return;
          _ordersCache = _ordersCache.where((e) => e.id != item.id).toList();
          _newOrderIds.remove(item.id);
          _updatedOrderIds.remove(item.id);
          emit(_buildSuccessState());
          return;
        }

        if (index == -1) {
          _ordersCache = [item, ..._ordersCache];
        } else {
          final updatedList = List<OrderInDb>.from(_ordersCache);
          updatedList[index] = item;
          _ordersCache = updatedList;
        }
        _newOrderIds.remove(item.id);
        _updatedOrderIds.add(item.id);
        emit(_buildSuccessState());

      case RepoItemDeleted<OrderInDb>(:final item):
        final exists = _ordersCache.any((element) => element.id == item.id);
        if (!exists) return;
        _ordersCache = _ordersCache.where((e) => e.id != item.id).toList();
        _newOrderIds.remove(item.id);
        _updatedOrderIds.remove(item.id);
        emit(_buildSuccessState());
    }
  }

  bool _matchesFilters(OrderInDb item) {
    if (item.status != OrderStatus.draft) return false;
    if (_branchId != null && item.branchId != _branchId) return false;
    if (clientId != null && item.clientId != clientId) return false;
    final effectiveCreator = defaultCreatorId ?? createdBy;
    if (effectiveCreator != null && item.createdBy.id != effectiveCreator) return false;
    return true;
  }

  ReadProformaSuccess _buildSuccessState({int? count}) {
    return ReadProformaSuccess(
      List<OrderInDb>.unmodifiable(_ordersCache),
      count ?? _ordersCache.length,
      newOrderIds: Set<String>.unmodifiable(_newOrderIds),
      updatedOrderIds: Set<String>.unmodifiable(_updatedOrderIds),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
