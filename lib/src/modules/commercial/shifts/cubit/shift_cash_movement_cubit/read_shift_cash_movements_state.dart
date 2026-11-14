import 'package:kardex_business/kardex_business.dart';

sealed class ReadShiftCashMovementsState {}

class ReadShiftCashMovementsInitial extends ReadShiftCashMovementsState {}

class ReadShiftCashMovementsLoading extends ReadShiftCashMovementsState {}

class ReadShiftCashMovementsLoaded extends ReadShiftCashMovementsState {
  final List<ShiftCashMovementInDb> movements;

  ReadShiftCashMovementsLoaded(this.movements);
}

class ReadShiftCashMovementsError extends ReadShiftCashMovementsState {
  final String message;

  ReadShiftCashMovementsError(this.message);
}
