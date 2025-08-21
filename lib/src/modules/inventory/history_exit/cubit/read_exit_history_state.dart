part of 'read_exit_history_cubit.dart';

sealed class ReadExitHistoryState {}

final class ReadExitHistoryInitial extends ReadExitHistoryState {}

final class ReadExitHistoryLoading extends ReadExitHistoryState {}

final class ReadExitHistorySuccess extends ReadExitHistoryState {
  final List<ExitHistoryInDb> histories;
  final int totalCount;
  ReadExitHistorySuccess(this.histories, this.totalCount);
}

final class ReadExitHistoryError extends ReadExitHistoryState {
  final String message;
  ReadExitHistoryError(this.message);
}
