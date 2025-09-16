part of 'write_receipt_cubit.dart';

sealed class WriteReceiptState {}

final class WriteReceiptInitial extends WriteReceiptState {}

final class WriteReceiptInProgress extends WriteReceiptState {}

final class WriteReceiptSuccess extends WriteReceiptState {
  final ReceiptInDb receipt;
  WriteReceiptSuccess(this.receipt);
}

final class WriteReceiptError extends WriteReceiptState {
  final String error;
  WriteReceiptError(this.error);
}
