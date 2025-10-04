part of 'write_unit_cubit.dart';

sealed class WriteUnitState {}

final class WriteUnitInitial extends WriteUnitState {}

final class WriteUnitInProgress extends WriteUnitState {}

final class WriteUnitSuccess extends WriteUnitState {
  final UnitInDb unit;
  WriteUnitSuccess(this.unit);
}

final class DeleteUnitSuccess extends WriteUnitState {
  final UnitInDb unit;
  DeleteUnitSuccess(this.unit);
}

final class WriteUnitError extends WriteUnitState {
  final String error;
  WriteUnitError(this.error);
}
