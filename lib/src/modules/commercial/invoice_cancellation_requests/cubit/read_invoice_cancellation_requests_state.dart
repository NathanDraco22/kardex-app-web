import 'package:kardex_business/kardex_business.dart';

sealed class ReadInvoiceCancellationRequestsState {
  const ReadInvoiceCancellationRequestsState();
}

final class ReadInvoiceCancellationRequestsInitial
    extends ReadInvoiceCancellationRequestsState {
  const ReadInvoiceCancellationRequestsInitial();
}

final class ReadInvoiceCancellationRequestsLoading
    extends ReadInvoiceCancellationRequestsState {
  const ReadInvoiceCancellationRequestsLoading();
}

final class ReadInvoiceCancellationRequestsSuccess
    extends ReadInvoiceCancellationRequestsState {
  final List<InvoiceCancellationRequestInDb> requests;
  final InvoiceCancellationRequestStatus? statusFilter;

  const ReadInvoiceCancellationRequestsSuccess({
    required this.requests,
    this.statusFilter,
  });
}

final class ReadInvoiceCancellationRequestsError
    extends ReadInvoiceCancellationRequestsState {
  final String message;
  const ReadInvoiceCancellationRequestsError(this.message);
}
