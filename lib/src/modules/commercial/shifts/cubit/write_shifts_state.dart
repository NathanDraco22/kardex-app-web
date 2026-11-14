import 'package:kardex_business/kardex_business.dart';

sealed class WriteShiftsState {}

class WriteShiftsInitial extends WriteShiftsState {}

class WriteShiftsLoading extends WriteShiftsState {}

class ShiftOpenedSuccess extends WriteShiftsState {
  final ShiftInDb shift;

  ShiftOpenedSuccess(this.shift);
}

class ShiftPreviewLoaded extends WriteShiftsState {
  final ShiftPreview preview;

  ShiftPreviewLoaded(this.preview);
}

class ShiftClosedSuccess extends WriteShiftsState {
  final ShiftInDb shift;

  ShiftClosedSuccess(this.shift);
}

class WriteShiftsError extends WriteShiftsState {
  final String message;

  WriteShiftsError(this.message);
}
