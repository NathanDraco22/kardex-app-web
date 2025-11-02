part of 'write_devolution_cubit.dart';

sealed class WriteDevolutionState {}

final class WriteDevolutionInitial extends WriteDevolutionState {}

final class WriteDevolutionInProgress extends WriteDevolutionState {}

final class WriteDevolutionSuccess extends WriteDevolutionState {
  final DevolutionInDb devolution;
  WriteDevolutionSuccess(this.devolution);
}

final class DeleteDevolutionSuccess extends WriteDevolutionState {
  final DevolutionInDb devolution;
  DeleteDevolutionSuccess(this.devolution);
}

final class WriteDevolutionError extends WriteDevolutionState {
  final String error;
  WriteDevolutionError(this.error);
}
