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
  }

  String? defaultCreatorId;
  String? userCreatorId;

  DateTime? startDate;
  DateTime? endDate;
  String? clientId;

  int offset = 0;
  bool isLastPage = false;

  final OrdersRepository ordersRepository;

  Future<void> loadDocuments(String branchId) async {
    emit(ReadQuotationOrderSearchLoading());
    offset = 0;
    isLastPage = false;
    try {
      final response = await ordersRepository.getPaginatedOrders(
        queryParams: _buildParams(branchId),
      );

      offset += response.data.length;
      isLastPage = response.data.length < 1000;

      int totalAmount = 0;
      for (final order in response.data) {
        totalAmount += order.total;
      }

      if (isClosed) return;
      emit(ReadQuotationOrderSearchSuccess(response.data, offset, totalAmount));
    } catch (e) {
      if (isClosed) return;
      emit(ReadQuotationOrderSearchError(e.toString()));
    }
  }

  Future<void> nextPage(String branchId) async {
    if (isLastPage) return;
    final currentState = state;
    if (currentState is! ReadQuotationOrderSearchSuccess) return;
    if (currentState is ReadQuotationOrderSearchLoadingMore) return;

    emit(
      ReadQuotationOrderSearchLoadingMore(
        currentState.orders,
        currentState.totalCount,
        currentState.totalAmount,
      ),
    );
    try {
      final response = await ordersRepository.getPaginatedOrders(
        queryParams: _buildParams(branchId),
      );

      offset += response.data.length;
      isLastPage = response.data.length < 1000;

      int totalAmount = currentState.totalAmount;
      for (final order in response.data) {
        totalAmount += order.total;
      }

      if (isClosed) return;
      emit(
        ReadQuotationOrderSearchSuccess(
          [...currentState.orders, ...response.data],
          offset,
          totalAmount,
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

    int totalAmount = 0;
    for (final o in newOrders) {
      totalAmount += o.total;
    }

    emit(ReadQuotationOrderSearchSuccess(newOrders, currentState.totalCount, totalAmount));
  }
}