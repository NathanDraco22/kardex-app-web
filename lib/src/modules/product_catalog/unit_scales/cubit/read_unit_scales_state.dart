part of 'read_unit_scales_cubit.dart';

sealed class ReadUnitScalesState {}

final class ReadUnitScalesInitial extends ReadUnitScalesState {}

final class ReadUnitScalesLoading extends ReadUnitScalesState {}

class ReadUnitScalesSuccess extends ReadUnitScalesState {
  final List<UnitScaleInDb> scales;
  ReadUnitScalesSuccess(this.scales);
}

final class ReadUnitScalesError extends ReadUnitScalesState {
  final String message;
  ReadUnitScalesError(this.message);
}
