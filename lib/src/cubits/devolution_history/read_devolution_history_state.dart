part of 'read_devolution_history_cubit.dart';

sealed class ReadDevolutionHistoryState {}

final class ReadDevolutionHistoryInitial extends ReadDevolutionHistoryState {}

final class ReadDevolutionHistoryLoading extends ReadDevolutionHistoryState {}

class ReadDevolutionHistorySuccess extends ReadDevolutionHistoryState {
  final List<DevolutionInDb> devolutions;
  ReadDevolutionHistorySuccess(this.devolutions);
}

final class FetchingNextPage extends ReadDevolutionHistorySuccess {
  FetchingNextPage(super.devolutions);
}

final class ReadDevolutionHistoryError extends ReadDevolutionHistoryState {
  final String message;
  ReadDevolutionHistoryError(this.message);
}
