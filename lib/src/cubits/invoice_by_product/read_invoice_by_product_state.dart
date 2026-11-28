part of 'read_invoice_by_product_cubit.dart';

sealed class ReadInvoiceByProductState {}

final class ReadInvoiceByProductInitial extends ReadInvoiceByProductState {}

final class ReadInvoiceByProductLoading extends ReadInvoiceByProductState {}

class ReadInvoiceByProductSuccess extends ReadInvoiceByProductState {
  final List<InvoiceInDb> invoices;
  final ProductSalesSummary summary;
  final int count;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? clientId;
  final String? userCreatorId;

  ReadInvoiceByProductSuccess({
    required this.invoices,
    required this.summary,
    required this.count,
    this.startDate,
    this.endDate,
    this.clientId,
    this.userCreatorId,
  });
}

final class FetchingNextPageInvoiceByProduct extends ReadInvoiceByProductSuccess {
  FetchingNextPageInvoiceByProduct({
    required super.invoices,
    required super.summary,
    required super.count,
    super.startDate,
    super.endDate,
    super.clientId,
    super.userCreatorId,
  });
}

final class ReadInvoiceByProductLoadMoreError extends ReadInvoiceByProductSuccess {
  final String message;

  ReadInvoiceByProductLoadMoreError({
    required super.invoices,
    required super.summary,
    required super.count,
    super.startDate,
    super.endDate,
    super.clientId,
    super.userCreatorId,
    required this.message,
  });
}

final class ReadInvoiceByProductError extends ReadInvoiceByProductState {
  final String message;
  ReadInvoiceByProductError(this.message);
}
