part of 'read_expiration_log_cubit.dart';

sealed class ReadExpirationLogState {}

final class ReadExpirationLogInitial extends ReadExpirationLogState {}

final class ReadExpirationLogLoading extends ReadExpirationLogState {}

class ReadExpirationLogSuccess extends ReadExpirationLogState {
  final List<ExpirationLogInDb> logs;
  ReadExpirationLogSuccess(this.logs);
}

class HighlightedExpirationLog extends ReadExpirationLogSuccess {
  List<ExpirationLogInDb> newLogs;
  HighlightedExpirationLog(
    super.logs, {
    this.newLogs = const [],
  });
}

final class ReadExpirationLogError extends ReadExpirationLogState {
  final String message;
  ReadExpirationLogError(this.message);
}
