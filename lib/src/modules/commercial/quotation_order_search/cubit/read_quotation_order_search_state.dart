part of 'read_quotation_order_search_cubit.dart';

sealed class ReadQuotationOrderSearchState {}

final class ReadQuotationOrderSearchInitial extends ReadQuotationOrderSearchState {}

final class ReadQuotationOrderSearchLoading extends ReadQuotationOrderSearchState {}

class ReadQuotationOrderSearchSuccess extends ReadQuotationOrderSearchState {
  final List<OrderInDb> orders;
  final int totalCount;
  final int totalAmount;

  ReadQuotationOrderSearchSuccess(this.orders, this.totalCount, this.totalAmount);
}

class ReadQuotationOrderSearchLoadingMore extends ReadQuotationOrderSearchSuccess {
  ReadQuotationOrderSearchLoadingMore(super.orders, super.totalCount, super.totalAmount);
}

final class ReadQuotationOrderSearchError extends ReadQuotationOrderSearchState {
  final String message;
  ReadQuotationOrderSearchError(this.message);
}