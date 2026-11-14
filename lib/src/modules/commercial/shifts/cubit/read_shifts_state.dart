import 'package:kardex_business/kardex_business.dart';

sealed class ReadShiftsState {}

class ReadShiftsInitial extends ReadShiftsState {}

class ReadShiftsLoading extends ReadShiftsState {}

class ReadShiftsLoaded extends ReadShiftsState {
  final List<ShiftInDb> shifts;

  ReadShiftsLoaded(this.shifts);
}

class ReadShiftsError extends ReadShiftsState {
  final String message;

  ReadShiftsError(this.message);
}
