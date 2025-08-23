part of 'read_entry_history_cubit.dart';

sealed class ReadEntryHistoryState {}

final class ReadEntryHistoryInitial extends ReadEntryHistoryState {}

final class ReadEntryHistoryLoading extends ReadEntryHistoryState {}

class ReadEntryHistorySuccess extends ReadEntryHistoryState {
  final List<EntryHistoryInDb> histories;
  final int totalCount;
  ReadEntryHistorySuccess(this.histories, this.totalCount);
}

class ReadEntryHistoryFiltering extends ReadEntryHistoryState {}

final class ReadEntryHistoryError extends ReadEntryHistoryState {
  final String message;
  ReadEntryHistoryError(this.message);
}
