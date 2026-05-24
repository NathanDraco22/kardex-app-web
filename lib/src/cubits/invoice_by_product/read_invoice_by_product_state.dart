part of 'read_invoice_by_product_cubit.dart';

sealed class ReadInvoiceByProductState {}

final class ReadInvoiceByProductInitial extends ReadInvoiceByProductState {}

final class ReadInvoiceByProductLoading extends ReadInvoiceByProductState {}

class ReadInvoiceByProductSuccess extends ReadInvoiceByProductState {
  final List<InvoiceInDb> invoices;
  ReadInvoiceByProductSuccess(this.invoices);
}

final class FetchingNextPageInvoiceByProduct extends ReadInvoiceByProductSuccess {
  FetchingNextPageInvoiceByProduct(super.invoices);
}

final class ReadInvoiceByProductError extends ReadInvoiceByProductState {
  final String message;
  ReadInvoiceByProductError(this.message);
}
