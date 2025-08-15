part of 'read_entry_doc_cubit.dart';

sealed class ReadEntryDocState {}

final class ReadEntryDocInitial extends ReadEntryDocState {}

final class ReadEntryDocLoading extends ReadEntryDocState {}

class ReadEntryDocSuccess extends ReadEntryDocState {
  final List<EntryDocInDb> entryDocs;
  ReadEntryDocSuccess(this.entryDocs);
}

final class EntryDocReadSearching extends ReadEntryDocSuccess {
  EntryDocReadSearching(super.entryDocs);
}

class HighlightedEntryDoc extends ReadEntryDocSuccess {
  List<EntryDocInDb> newEntryDocs;
  HighlightedEntryDoc(
    super.entryDocs, {
    this.newEntryDocs = const [],
  });
}

final class EntryDocInserted extends ReadEntryDocSuccess {
  int inserted;
  EntryDocInserted(this.inserted, super.entryDocs);
}

final class EntryDocReadError extends ReadEntryDocState {
  final String message;
  EntryDocReadError(this.message);
}
