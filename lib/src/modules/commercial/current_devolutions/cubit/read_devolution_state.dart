part of 'read_devolution_cubit.dart';

sealed class ReadDevolutionState {}

final class ReadDevolutionInitial extends ReadDevolutionState {}

final class ReadDevolutionLoading extends ReadDevolutionState {}

class ReadDevolutionSuccess extends ReadDevolutionState {
  final List<DevolutionInDb> devolutions;
  ReadDevolutionSuccess(this.devolutions);
}

class HighlightedDevolution extends ReadDevolutionSuccess {
  List<DevolutionInDb> newDevolutions;
  List<DevolutionInDb> updatedDevolutions;
  HighlightedDevolution(
    super.devolutions, {
    this.newDevolutions = const [],
    this.updatedDevolutions = const [],
  });
}

final class ReadDevolutionError extends ReadDevolutionState {
  final String message;
  ReadDevolutionError(this.message);
}
