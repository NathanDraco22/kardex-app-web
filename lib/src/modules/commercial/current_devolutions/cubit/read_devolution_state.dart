part of 'read_devolution_cubit.dart';

sealed class ReadDevolutionState {}

final class ReadDevolutionInitial extends ReadDevolutionState {}

final class ReadDevolutionLoading extends ReadDevolutionState {}

class ReadDevolutionSuccess extends ReadDevolutionState {
  final List<DevolutionInDb> devolutions;
  final int totalAmount;
  final Set<String> newDevolutionIds;
  final Set<String> updatedDevolutionIds;

  ReadDevolutionSuccess(
    this.devolutions, {
    this.totalAmount = 0,
    this.newDevolutionIds = const {},
    this.updatedDevolutionIds = const {},
  });
}

class HighlightedDevolution extends ReadDevolutionSuccess {
  final List<DevolutionInDb> newDevolutions;
  final List<DevolutionInDb> updatedDevolutions;

  HighlightedDevolution(
    super.devolutions, {
    super.totalAmount,
    super.newDevolutionIds,
    super.updatedDevolutionIds,
    this.newDevolutions = const [],
    this.updatedDevolutions = const [],
  });
}

final class ReadDevolutionError extends ReadDevolutionState {
  final String message;
  ReadDevolutionError(this.message);
}
