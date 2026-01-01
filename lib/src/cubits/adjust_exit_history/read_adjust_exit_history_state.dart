part of 'read_adjust_exit_history_cubit.dart';

sealed class ReadAdjustExitHistoryState {}

final class ReadAdjustExitHistoryInitial extends ReadAdjustExitHistoryState {}

final class ReadAdjustExitHistoryLoading extends ReadAdjustExitHistoryState {}

class ReadAdjustExitHistorySuccess extends ReadAdjustExitHistoryState {
  final List<AdjustExitInDb> exits;

  ReadAdjustExitHistorySuccess(this.exits);
}

final class FetchingNextPage extends ReadAdjustExitHistorySuccess {
  FetchingNextPage(super.exits);
}

final class ReadAdjustExitHistoryError extends ReadAdjustExitHistoryState {
  final String message;
  ReadAdjustExitHistoryError(this.message);
}
