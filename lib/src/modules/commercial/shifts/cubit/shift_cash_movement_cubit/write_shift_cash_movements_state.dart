import 'package:kardex_business/kardex_business.dart';

sealed class WriteShiftCashMovementsState {}

class WriteShiftCashMovementsInitial extends WriteShiftCashMovementsState {}

class WriteShiftCashMovementsLoading extends WriteShiftCashMovementsState {}

class ShiftCashMovementCreated extends WriteShiftCashMovementsState {
  final ShiftCashMovementInDb movement;

  ShiftCashMovementCreated(this.movement);
}

class ShiftCashMovementDeleted extends WriteShiftCashMovementsState {
  final ShiftCashMovementInDb movement;

  ShiftCashMovementDeleted(this.movement);
}

class WriteShiftCashMovementsError extends WriteShiftCashMovementsState {
  final String message;

  WriteShiftCashMovementsError(this.message);
}
