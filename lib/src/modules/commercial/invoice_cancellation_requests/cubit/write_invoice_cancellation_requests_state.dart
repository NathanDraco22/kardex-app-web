import 'package:kardex_business/kardex_business.dart';

sealed class WriteInvoiceCancellationRequestsState {
  const WriteInvoiceCancellationRequestsState();
}

final class WriteInvoiceCancellationRequestsInitial
    extends WriteInvoiceCancellationRequestsState {
  const WriteInvoiceCancellationRequestsInitial();
}

final class WriteInvoiceCancellationRequestsLoading
    extends WriteInvoiceCancellationRequestsState {
  const WriteInvoiceCancellationRequestsLoading();
}

final class WriteInvoiceCancellationRequestsSuccess
    extends WriteInvoiceCancellationRequestsState {
  final InvoiceCancellationRequestInDb request;
  final String message;
  const WriteInvoiceCancellationRequestsSuccess(this.request, this.message);
}

final class WriteInvoiceCancellationRequestsError
    extends WriteInvoiceCancellationRequestsState {
  final String message;
  const WriteInvoiceCancellationRequestsError(this.message);
}
