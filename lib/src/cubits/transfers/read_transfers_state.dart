part of 'read_transfers_cubit.dart';

abstract class ReadTransfersState {}

class ReadTransfersInitial extends ReadTransfersState {}

class ReadTransfersLoading extends ReadTransfersState {}

class ReadTransfersSuccess extends ReadTransfersState {
  final List<TransferInDb> transfers;
  final int count;

  ReadTransfersSuccess(this.transfers, this.count);
}

class ReadTransfersError extends ReadTransfersState {
  final String message;

  ReadTransfersError(this.message);
}
