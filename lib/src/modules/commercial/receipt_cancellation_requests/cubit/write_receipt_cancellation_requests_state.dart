import 'package:kardex_business/kardex_business.dart';

sealed class WriteReceiptCancellationRequestsState {
  const WriteReceiptCancellationRequestsState();
}

final class WriteReceiptCancellationRequestsInitial
    extends WriteReceiptCancellationRequestsState {
  const WriteReceiptCancellationRequestsInitial();
}

final class WriteReceiptCancellationRequestsLoading
    extends WriteReceiptCancellationRequestsState {
  const WriteReceiptCancellationRequestsLoading();
}

final class WriteReceiptCancellationRequestsSuccess
    extends WriteReceiptCancellationRequestsState {
  final ReceiptCancellationRequestInDb request;
  final String message;
  const WriteReceiptCancellationRequestsSuccess(this.request, this.message);
}

final class WriteReceiptCancellationRequestsError
    extends WriteReceiptCancellationRequestsState {
  final String message;
  const WriteReceiptCancellationRequestsError(this.message);
}
