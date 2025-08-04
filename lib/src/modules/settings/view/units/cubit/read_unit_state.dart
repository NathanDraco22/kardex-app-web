part of 'read_unit_cubit.dart';

sealed class ReadUnitState {}

final class ReadUnitInitial extends ReadUnitState {}

final class ReadUnitLoading extends ReadUnitState {}

class ReadUnitSuccess extends ReadUnitState {
  final List<UnitInDb> units;
  ReadUnitSuccess(this.units);
}

final class UnitReadSearching extends ReadUnitSuccess {
  UnitReadSearching(super.units);
}

class HighlightedUnit extends ReadUnitSuccess {
  List<UnitInDb> newUnits;
  List<UnitInDb> updatedUnits;
  HighlightedUnit(
    super.units, {
    this.newUnits = const [],
    this.updatedUnits = const [],
  });
}

final class UnitInserted extends ReadUnitSuccess {
  int inserted;
  UnitInserted(this.inserted, super.units);
}

final class UnitUpdated extends ReadUnitSuccess {
  List<UnitInDb> updated;
  UnitUpdated(this.updated, super.units);
}

final class UnitReadError extends ReadUnitState {
  final String message;
  UnitReadError(this.message);
}
