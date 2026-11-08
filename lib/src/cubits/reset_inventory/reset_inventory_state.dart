import 'package:kardex_business/kardex_business.dart';

sealed class ResetInventoryState {}

class ResetInventoryInitial extends ResetInventoryState {}

class ResetInventoryLoading extends ResetInventoryState {}

class ResetInventorySuccess extends ResetInventoryState {
  final ResetInventoryResult result;
  ResetInventorySuccess(this.result);
}

class ResetInventoryFailure extends ResetInventoryState {
  final String message;
  ResetInventoryFailure(this.message);
}
