part of 'write_transfer_cubit.dart';

abstract class WriteTransferState {
  const WriteTransferState();
}

class WriteTransferInitial extends WriteTransferState {
  const WriteTransferInitial();
}

class WriteTransferLoading extends WriteTransferState {
  const WriteTransferLoading();
}

class WriteTransferSuccess extends WriteTransferState {
  final TransferInDb transfer;
  const WriteTransferSuccess(this.transfer);
}

class WriteTransferFailure extends WriteTransferState {
  final String message;
  const WriteTransferFailure(this.message);
}
