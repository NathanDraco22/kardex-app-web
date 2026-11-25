import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_order_state.dart';

class ReadOrderCubit extends Cubit<ReadOrderState> {
  ReadOrderCubit({
    required this.ordersRepository,
    this.branchId,
    this.defaultCreatorId,
    OrderStatus? initialStatus = OrderStatus.open,
  }) : status = initialStatus,
       createdBy = defaultCreatorId,
       super(ReadOrderInitial()) {
    _subscription = ordersRepository.eventStream.listen(_handleRepoEvent);
  }

  final OrdersRepository ordersRepository;
  final String? defaultCreatorId;

  StreamSubscription<RepoEvent<OrderInDb>>? _subscription;

  bool isLastPage = false;
  List<OrderInDb> _ordersCache = [];
  final Set<String> _newOrderIds = {};
  final Set<String> _updatedOrderIds = {};

  String? branchId;
  OrderStatus? status;
  String? clientId;
  String? createdBy;
  String searchKeyword = '';

  Future<void> loadPaginatedOrders([String? branchId]) async {
    if (branchId != null) {
      this.branchId = branchId;
    }
    emit(ReadOrderLoading());
    try {
      final response = await ordersRepository.getPaginatedOrders(
        queryParams: OrderQueryParams(
          skip: 0,
          limit: 1000,
          branchId: this.branchId,
          clientId: clientId,
          status: status,
          neStatus: status == null ? OrderStatus.draft : null,
          createdBy: defaultCreatorId ?? createdBy,
        ),
      );

      _ordersCache = List<OrderInDb>.from(response.data);
      _newOrderIds.clear();
      _updatedOrderIds.clear();
      isLastPage = _ordersCache.length >= response.count;

      if (isClosed) return;
      _emitVisibleList(serverCount: response.count);
    } catch (error) {
      if (isClosed) return;
      emit(ReadOrderError(error.toString()));
    }
  }

  Future<void> applyFilters({
    OrderStatus? status,
    bool clearStatus = false,
    String? clientId,
    bool clearClient = false,
    String? createdBy,
    bool clearCreatedBy = false,
  }) async {
    if (clearStatus) {
      this.status = null;
    } else if (status != null) {
      this.status = status;
    }

    if (clearClient) {
      this.clientId = null;
    } else if (clientId != null) {
      this.clientId = clientId;
    }

    if (defaultCreatorId != null) {
      this.createdBy = defaultCreatorId;
    } else if (clearCreatedBy) {
      this.createdBy = null;
    } else if (createdBy != null) {
      this.createdBy = createdBy;
    }

    await loadPaginatedOrders();
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

  Future<void> clearFilterParams([String? branchId]) async {
    if (branchId != null) {
      this.branchId = branchId;
    }
    status = OrderStatus.open;
    clientId = null;
    createdBy = defaultCreatorId;
    searchKeyword = '';
    _ordersCache = [];
    isLastPage = false;
    await loadPaginatedOrders();
  }

  void searchOrder(String keyword) {
    searchKeyword = keyword;
    if (state is! ReadOrderSuccess) return;
    _emitVisibleList();
  }

  Future<void> updateOrderCache(OrderInDb order) async {
    final index = _ordersCache.indexWhere((element) => element.id == order.id);
    final matches = _matchesFilters(order);

    if (!matches) {
      if (index == -1) return;
      _ordersCache = _ordersCache.where((e) => e.id != order.id).toList();
      _newOrderIds.remove(order.id);
      _updatedOrderIds.remove(order.id);
      if (isClosed || state is! ReadOrderSuccess) return;
      _emitVisibleList();
      return;
    }

    if (index == -1) {
      _ordersCache = [order, ..._ordersCache];
    } else {
      final updated = List<OrderInDb>.from(_ordersCache);
      updated[index] = order;
      _ordersCache = updated;
    }
    _newOrderIds.remove(order.id);
    _updatedOrderIds.add(order.id);

    if (isClosed || state is! ReadOrderSuccess) return;
    _emitVisibleList();
  }

  void _handleRepoEvent(RepoEvent<OrderInDb> event) {
    if (isClosed || state is! ReadOrderSuccess) return;

    switch (event) {
      case RepoItemCreated<OrderInDb>(:final item):
        if (!_matchesFilters(item)) return;
        if (_ordersCache.any((e) => e.id == item.id)) return;
        _ordersCache = [item, ..._ordersCache];
        _updatedOrderIds.remove(item.id);
        _newOrderIds.add(item.id);
        _emitVisibleList();

      case RepoItemUpdated<OrderInDb>(:final item):
        updateOrderCache(item);

      case RepoItemDeleted<OrderInDb>(:final item):
        if (!_ordersCache.any((e) => e.id == item.id)) return;
        _ordersCache = _ordersCache.where((e) => e.id != item.id).toList();
        _newOrderIds.remove(item.id);
        _updatedOrderIds.remove(item.id);
        _emitVisibleList();
    }
  }

  bool _matchesFilters(OrderInDb item) {
    if (item.status == OrderStatus.draft) return false;
    if (branchId != null && item.branchId != branchId) return false;
    if (clientId != null && item.clientId != clientId) return false;
    final effectiveCreator = defaultCreatorId ?? createdBy;
    if (effectiveCreator != null && item.createdBy.id != effectiveCreator) return false;
    if (status != null && item.status != status) return false;
    return true;
  }

  void _emitVisibleList({int? serverCount}) {
    final query = searchKeyword.trim().toLowerCase();
    final visible = query.isEmpty
        ? _ordersCache
        : _ordersCache.where((order) {
            return order.clientInfo.name.toLowerCase().contains(query) ||
                order.docNumber.toLowerCase().contains(query);
          }).toList();

    var totalAmount = 0;
    for (final item in visible) {
      totalAmount += item.total;
    }

    emit(
      ReadOrderSuccess(
        List<OrderInDb>.unmodifiable(visible),
        query.isEmpty ? (serverCount ?? visible.length) : visible.length,
        totalAmount: totalAmount,
        newOrderIds: Set<String>.unmodifiable(_newOrderIds),
        updatedOrderIds: Set<String>.unmodifiable(_updatedOrderIds),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
