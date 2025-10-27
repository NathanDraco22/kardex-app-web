part of 'write_expiration_log_cubit.dart';

sealed class WriteExpirationLogState {}

final class WriteExpirationLogInitial extends WriteExpirationLogState {}

final class WriteExpirationLogInProgress extends WriteExpirationLogState {}

final class WriteExpirationLogSuccess extends WriteExpirationLogState {
  final ExpirationLogInDb log;
  WriteExpirationLogSuccess(this.log);
}

final class DeleteExpirationLogSuccess extends WriteExpirationLogState {
  final ExpirationLogInDb log;
  DeleteExpirationLogSuccess(this.log);
}

final class WriteExpirationLogError extends WriteExpirationLogState {
  final String error;
  WriteExpirationLogError(this.error);
}
