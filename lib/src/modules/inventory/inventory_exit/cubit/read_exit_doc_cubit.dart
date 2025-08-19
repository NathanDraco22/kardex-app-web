import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/exit_doc/exit_doc_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/constant.dart';

part 'read_exit_doc_state.dart';

class ReadExitDocCubit extends Cubit<ReadExitDocState> {
  ReadExitDocCubit({
    required this.exitDocsRepository,
    required this.clientsRepository,
    required this.branchesRepository,
  }) : super(ReadExitDocInitial());

  final ExitDocsRepository exitDocsRepository;
  final ClientsRepository clientsRepository;
  final BranchesRepository branchesRepository;

  bool isLastPage = false;
  List<ExitDocInDb> _exitDocsCache = [];

  Future<void> loadPaginatedExitDocs() async {
    if (isLastPage) return;
    emit(ReadExitDocLoading());
    try {
      // Carga datos relacionados necesarios para la vista
      await Future.wait([
        clientsRepository.getAllClients(),
        branchesRepository.getAllBranches(),
      ]);
      final docs = await exitDocsRepository.getPaginatedExitDocs(_exitDocsCache.length);
      if (docs.length < paginationItems) isLastPage = true;
      _exitDocsCache = [..._exitDocsCache, ...docs];
      emit(ReadExitDocSuccess(_exitDocsCache));
    } catch (error) {
      emit(ExitDocReadError(error.toString()));
    }
  }

  Future<void> getNextPagedExitDocs() async {
    if (isLastPage) return;
    try {
      final docs = await exitDocsRepository.getPaginatedExitDocs(_exitDocsCache.length);
      if (docs.length < paginationItems) isLastPage = true;
      _exitDocsCache = [..._exitDocsCache, ...docs];
      emit(ReadExitDocSuccess(_exitDocsCache));
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> searchExitDocByKeyword(String keyword) async {
    final currentState = state as ReadExitDocSuccess;

    if (keyword.isEmpty) {
      emit(ReadExitDocSuccess(_exitDocsCache));
      return;
    }

    emit(ExitDocReadSearching(currentState.exitDocs));
    try {
      final docs = await exitDocsRepository.searchExitDocByKeyword(keyword);
      emit(ReadExitDocSuccess(docs));
    } catch (error) {
      emit(ExitDocReadError(error.toString()));
    }
  }

  Future<void> putExitDocFirst(ExitDocInDb doc) async {
    final currentState = state as ReadExitDocSuccess;
    _exitDocsCache = [doc, ..._exitDocsCache];
    final freshList = _exitDocsCache;
    if (currentState is HighlightedExitDoc) {
      emit(
        HighlightedExitDoc(
          freshList,
          newExitDocs: [doc, ...currentState.newExitDocs],
        ),
      );
      return;
    }
    emit(
      HighlightedExitDoc(
        freshList,
        newExitDocs: [doc],
      ),
    );
  }

  Future<void> refreshExitDoc() async {
    final currentState = state as ReadExitDocSuccess;
    final freshList = _exitDocsCache;
    if (currentState is HighlightedExitDoc) {
      emit(
        HighlightedExitDoc(
          freshList,
          newExitDocs: currentState.newExitDocs,
        ),
      );
      return;
    }
    emit(
      HighlightedExitDoc(
        freshList,
      ),
    );
  }
}
