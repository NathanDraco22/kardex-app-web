part of 'write_anon_devolution_cubit.dart';

sealed class WriteAnonDevolutionState {}

final class WriteAnonDevolutionInitial extends WriteAnonDevolutionState {}

final class WriteAnonDevolutionInProgress extends WriteAnonDevolutionState {}

final class WriteAnonDevolutionSuccess extends WriteAnonDevolutionState {
  final DevolutionInDb devolution;

  WriteAnonDevolutionSuccess(this.devolution);
}

final class WriteAnonDevolutionError extends WriteAnonDevolutionState {
  final String error;

  WriteAnonDevolutionError(this.error);
}
