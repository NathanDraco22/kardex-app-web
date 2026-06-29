part of 'write_exit_doc_cubit.dart';

sealed class WriteExitDocState {}

final class WriteExitDocInitial extends WriteExitDocState {}

final class WriteExitDocInProgress extends WriteExitDocState {}

final class WriteExitDocSuccess extends WriteExitDocState {
  final ExitDocInDb exitDoc;
  WriteExitDocSuccess(this.exitDoc);
}

final class WriteExitDocError extends WriteExitDocState {
  final String error;
  WriteExitDocError(this.error);
}
