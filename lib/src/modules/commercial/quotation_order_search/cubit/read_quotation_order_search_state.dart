part of 'read_quotation_order_search_cubit.dart';

sealed class ReadQuotationOrderSearchState {}

final class ReadQuotationOrderSearchInitial extends ReadQuotationOrderSearchState {}

final class ReadQuotationOrderSearchLoading extends ReadQuotationOrderSearchState {}

class ReadQuotationOrderSearchSuccess extends ReadQuotationOrderSearchState {
  final List<OrderInDb> orders;
  final int totalCount;
  final int totalAmount;
  final Set<String> newOrderIds;
  final Set<String> updatedOrderIds;

  ReadQuotationOrderSearchSuccess(
    this.orders,
    this.totalCount,
    this.totalAmount, {
    this.newOrderIds = const {},
    this.updatedOrderIds = const {},
  });
}

class ReadQuotationOrderSearchLoadingMore extends ReadQuotationOrderSearchSuccess {
  ReadQuotationOrderSearchLoadingMore(
    super.orders,
    super.totalCount,
    super.totalAmount, {
    super.newOrderIds,
    super.updatedOrderIds,
  });
}

final class ReadQuotationOrderSearchError extends ReadQuotationOrderSearchState {
  final String message;
  ReadQuotationOrderSearchError(this.message);
}
