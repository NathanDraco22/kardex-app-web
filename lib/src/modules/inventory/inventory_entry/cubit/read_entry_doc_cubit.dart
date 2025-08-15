import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/entry_doc/entry_doc_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'read_entry_doc_state.dart';

class ReadEntryDocCubit extends Cubit<ReadEntryDocState> {
  ReadEntryDocCubit(this.entryDocsRepository) : super(ReadEntryDocInitial());

  final EntryDocsRepository entryDocsRepository;

  Future<void> loadAllEntryDocs() async {
    emit(ReadEntryDocLoading());
    try {
      final docs = await entryDocsRepository.getAllEntryDocs();
      emit(ReadEntryDocSuccess(docs));
    } catch (error) {
      emit(EntryDocReadError(error.toString()));
    }
  }

  Future<void> searchEntryDocByKeyword(String keyword) async {
    final currentState = state as ReadEntryDocSuccess;

    if (keyword.isEmpty) {
      emit(ReadEntryDocSuccess(entryDocsRepository.entryDocs));
      return;
    }

    emit(EntryDocReadSearching(currentState.entryDocs));
    try {
      final docs = await entryDocsRepository.searchEntryDocByKeyword(keyword);
      emit(ReadEntryDocSuccess(docs));
    } catch (error) {
      emit(EntryDocReadError(error.toString()));
    }
  }

  Future<void> putEntryDocFirst(EntryDocInDb doc) async {
    final currentState = state as ReadEntryDocSuccess;
    final freshList = entryDocsRepository.entryDocs;
    if (currentState is HighlightedEntryDoc) {
      emit(
        HighlightedEntryDoc(
          freshList,
          newEntryDocs: [doc, ...currentState.newEntryDocs],
        ),
      );
      return;
    }
    emit(
      HighlightedEntryDoc(
        freshList,
        newEntryDocs: [doc],
      ),
    );
  }

  Future<void> refreshEntryDoc() async {
    final currentState = state as ReadEntryDocSuccess;
    final freshList = entryDocsRepository.entryDocs;
    if (currentState is HighlightedEntryDoc) {
      emit(
        HighlightedEntryDoc(
          freshList,
          newEntryDocs: currentState.newEntryDocs,
        ),
      );
      return;
    }
    emit(
      HighlightedEntryDoc(
        freshList,
      ),
    );
  }
}
