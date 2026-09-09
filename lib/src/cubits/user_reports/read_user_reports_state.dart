part of 'read_user_reports_cubit.dart';

abstract class ReadUserReportsState {}

class ReadUserReportsInitial extends ReadUserReportsState {}

class ReadUserReportsLoading extends ReadUserReportsState {}

class ReadUserReportsSuccess extends ReadUserReportsState {
  final TotalsResult result;

  ReadUserReportsSuccess(this.result);
}

class ReadUserReportsError extends ReadUserReportsState {
  final String message;

  ReadUserReportsError(this.message);
}
