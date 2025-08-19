import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/entry_doc/entry_doc_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/constant.dart';

part 'read_entry_doc_state.dart';

class ReadEntryDocCubit extends Cubit<ReadEntryDocState> {
  ReadEntryDocCubit({
    required this.entryDocsRepository,
    required this.suppliersRepository,
    required this.branchesRepository,
  }) : super(ReadEntryDocInitial());

  final EntryDocsRepository entryDocsRepository;
  final SuppliersRepository suppliersRepository;
  final BranchesRepository branchesRepository;

  bool isLastPage = false;
  List<EntryDocInDb> _entryDocsCache = [];

  Future<void> loadPaginatedEntryDocs() async {
    if (isLastPage) return;
    emit(ReadEntryDocLoading());
    try {
      // Carga datos relacionados necesarios para la vista
      await Future.wait([
        suppliersRepository.getAllSuppliers(),
        branchesRepository.getAllBranches(),
      ]);
      final docs = await entryDocsRepository.getPaginatedEntryDocs(_entryDocsCache.length);
      if (docs.length < paginationItems) isLastPage = true;
      _entryDocsCache = [..._entryDocsCache, ...docs];
      emit(ReadEntryDocSuccess(_entryDocsCache));
    } catch (error) {
      emit(EntryDocReadError(error.toString()));
    }
  }

  Future<void> getNextPagedEntryDocs() async {
    if (isLastPage) return;
    try {
      final docs = await entryDocsRepository.getPaginatedEntryDocs(_entryDocsCache.length);
      if (docs.length < paginationItems) isLastPage = true;
      _entryDocsCache = [..._entryDocsCache, ...docs];
      emit(ReadEntryDocSuccess(_entryDocsCache));
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> searchEntryDocByKeyword(String keyword) async {
    final currentState = state as ReadEntryDocSuccess;

    if (keyword.isEmpty) {
      emit(ReadEntryDocSuccess(_entryDocsCache));
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
    _entryDocsCache = [doc, ..._entryDocsCache];
    final freshList = _entryDocsCache;
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
    final freshList = _entryDocsCache;
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
