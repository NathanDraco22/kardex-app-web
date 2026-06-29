part of 'write_entry_doc_cubit.dart';

sealed class WriteEntryDocState {}

final class WriteEntryDocInitial extends WriteEntryDocState {}

final class WriteEntryDocInProgress extends WriteEntryDocState {}

final class WriteEntryDocSuccess extends WriteEntryDocState {
  final EntryDocInDb entryDoc;
  WriteEntryDocSuccess(this.entryDoc);
}

final class WriteEntryDocError extends WriteEntryDocState {
  final String error;
  WriteEntryDocError(this.error);
}
