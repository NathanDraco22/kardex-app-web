part of 'write_unit_scale_cubit.dart';

sealed class WriteUnitScaleState {}

final class WriteUnitScaleInitial extends WriteUnitScaleState {}

final class WriteUnitScaleInProgress extends WriteUnitScaleState {}

class WriteUnitScaleSuccess extends WriteUnitScaleState {
  final UnitScaleInDb scale;
  WriteUnitScaleSuccess(this.scale);
}

class DeleteUnitScaleSuccess extends WriteUnitScaleState {
  final UnitScaleInDb scale;
  DeleteUnitScaleSuccess(this.scale);
}

class WriteUnitScaleError extends WriteUnitScaleState {
  final String error;
  WriteUnitScaleError(this.error);
}
