import 'package:kardex_business/kardex_business.dart';

sealed class ReadReceiptCancellationRequestsState {
  const ReadReceiptCancellationRequestsState();
}

final class ReadReceiptCancellationRequestsInitial
    extends ReadReceiptCancellationRequestsState {
  const ReadReceiptCancellationRequestsInitial();
}

final class ReadReceiptCancellationRequestsLoading
    extends ReadReceiptCancellationRequestsState {
  const ReadReceiptCancellationRequestsLoading();
}

final class ReadReceiptCancellationRequestsSuccess
    extends ReadReceiptCancellationRequestsState {
  final List<ReceiptCancellationRequestInDb> requests;
  final ReceiptCancellationRequestStatus? statusFilter;

  const ReadReceiptCancellationRequestsSuccess({
    required this.requests,
    this.statusFilter,
  });
}

final class ReadReceiptCancellationRequestsError
    extends ReadReceiptCancellationRequestsState {
  final String message;
  const ReadReceiptCancellationRequestsError(this.message);
}
