part of 'read_reports_cubit.dart';

abstract class ReadReportsState {}

class ReadReportsInitial extends ReadReportsState {}

class ReadReportsLoading extends ReadReportsState {}

class ReadReportsSuccess extends ReadReportsState {
  final TotalsResult result;

  ReadReportsSuccess(this.result);
}

class ReadReportsError extends ReadReportsState {
  final String message;

  ReadReportsError(this.message);
}
