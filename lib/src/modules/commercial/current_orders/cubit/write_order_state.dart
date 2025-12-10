part of 'write_order_cubit.dart';

sealed class WriteOrderState {}

final class WriteOrderInitial extends WriteOrderState {}

final class WriteOrderInProgress extends WriteOrderState {}

final class WriteOrderSuccess extends WriteOrderState {
  final OrderInDb order;
  WriteOrderSuccess(this.order);
}

final class WriteOrderDraftDeleted extends WriteOrderState {
  final OrderInDb order;
  WriteOrderDraftDeleted(this.order);
}

final class WriteOrderToInvoiceSuccess extends WriteOrderState {
  final InvoiceInDb invoice;
  final OrderInDb order;
  WriteOrderToInvoiceSuccess(this.invoice, this.order);
}

final class WriteOrderError extends WriteOrderState {
  final String error;
  WriteOrderError(this.error);
}
