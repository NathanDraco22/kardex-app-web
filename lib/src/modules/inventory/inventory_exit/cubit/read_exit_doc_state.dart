part of 'read_exit_doc_cubit.dart';

sealed class ReadExitDocState {}

final class ReadExitDocInitial extends ReadExitDocState {}

final class ReadExitDocLoading extends ReadExitDocState {}

class ReadExitDocSuccess extends ReadExitDocState {
  final List<ExitDocInDb> exitDocs;
  ReadExitDocSuccess(this.exitDocs);
}

final class ExitDocReadSearching extends ReadExitDocSuccess {
  ExitDocReadSearching(super.exitDocs);
}

class HighlightedExitDoc extends ReadExitDocSuccess {
  List<ExitDocInDb> newExitDocs;
  HighlightedExitDoc(
    super.exitDocs, {
    this.newExitDocs = const [],
  });
}

final class ExitDocInserted extends ReadExitDocSuccess {
  int inserted;
  ExitDocInserted(this.inserted, super.exitDocs);
}

final class ExitDocReadError extends ReadExitDocState {
  final String message;
  ExitDocReadError(this.message);
}
