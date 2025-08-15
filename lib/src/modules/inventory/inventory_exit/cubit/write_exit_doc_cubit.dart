import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/exit_doc/exit_doc_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'write_exit_doc_state.dart';

class WriteExitDocCubit extends Cubit<WriteExitDocState> {
  WriteExitDocCubit(this.exitDocsRepository) : super(WriteExitDocInitial());

  final ExitDocsRepository exitDocsRepository;

  Future<void> createNewExitDoc(CreateExitDoc createExitDoc) async {
    emit(WriteExitDocInProgress());
    try {
      final doc = await exitDocsRepository.createExitDoc(createExitDoc);
      emit(WriteExitDocSuccess(doc));
      emit(WriteExitDocInitial());
    } catch (error) {
      emit(WriteExitDocError(error.toString()));
    }
  }
}
