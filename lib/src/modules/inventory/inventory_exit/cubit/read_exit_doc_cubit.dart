import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/exit_doc/exit_doc_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'read_exit_doc_state.dart';

class ReadExitDocCubit extends Cubit<ReadExitDocState> {
  ReadExitDocCubit(this.exitDocsRepository) : super(ReadExitDocInitial());

  final ExitDocsRepository exitDocsRepository;

  Future<void> loadAllExitDocs() async {
    emit(ReadExitDocLoading());
    try {
      final docs = await exitDocsRepository.getAllExitDocs();
      emit(ReadExitDocSuccess(docs));
    } catch (error) {
      emit(ExitDocReadError(error.toString()));
    }
  }

  Future<void> searchExitDocByKeyword(String keyword) async {
    final currentState = state as ReadExitDocSuccess;

    if (keyword.isEmpty) {
      emit(ReadExitDocSuccess(exitDocsRepository.exitDocs));
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
    final freshList = exitDocsRepository.exitDocs;
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
    final freshList = exitDocsRepository.exitDocs;
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
