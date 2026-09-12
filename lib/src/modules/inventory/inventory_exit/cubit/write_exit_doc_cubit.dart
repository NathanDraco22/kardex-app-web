import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'write_exit_doc_state.dart';

class WriteExitDocCubit extends Cubit<WriteExitDocState> {
  WriteExitDocCubit(
    this.exitDocsRepository, {
    this.useKardex = true,
  }) : super(WriteExitDocInitial());

  final ExitDocsRepository exitDocsRepository;
  bool useKardex;

  void setUseKardex(bool value) {
    useKardex = value;
  }

  Future<void> createNewExitDoc(CreateExitDoc createExitDoc) async {
    if (!useKardex) {
      return createNewExitDocDirect(createExitDoc);
    }
    emit(WriteExitDocInProgress());
    try {
      final doc = await exitDocsRepository.createExitDoc(createExitDoc);
      emit(WriteExitDocSuccess(doc));
      emit(WriteExitDocInitial());
    } catch (error) {
      emit(WriteExitDocError(error.toString()));
    }
  }

  Future<void> createNewExitDocDirect(CreateExitDoc createExitDoc) async {
    emit(WriteExitDocInProgress());
    try {
      final doc = await exitDocsRepository.createExitDocDirect(createExitDoc);
      emit(WriteExitDocSuccess(doc));
      emit(WriteExitDocInitial());
    } catch (error) {
      emit(WriteExitDocError(error.toString()));
    }
  }
}
