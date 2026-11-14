import 'package:kardex_business/kardex_business.dart';

sealed class ShiftState {}

class ShiftInitial extends ShiftState {}

class ShiftFeatureDisabled extends ShiftState {}

class ShiftLoading extends ShiftState {}

class ShiftNoneOpen extends ShiftState {}

class ShiftActive extends ShiftState {
  final ShiftInDb shift;

  ShiftActive(this.shift);
}

class ShiftError extends ShiftState {
  final String message;

  ShiftError(this.message);
}
