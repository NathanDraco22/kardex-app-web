import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/entry_doc/entry_doc_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'write_entry_doc_state.dart';

class WriteEntryDocCubit extends Cubit<WriteEntryDocState> {
  WriteEntryDocCubit(this.entryDocsRepository) : super(WriteEntryDocInitial());

  final EntryDocsRepository entryDocsRepository;

  Future<void> createNewEntryDoc(CreateEntryDoc createEntryDoc) async {
    emit(WriteEntryDocInProgress());
    try {
      final doc = await entryDocsRepository.createEntryDoc(createEntryDoc);
      emit(WriteEntryDocSuccess(doc));
      emit(WriteEntryDocInitial());
    } catch (error) {
      emit(WriteEntryDocError(error.toString()));
    }
  }
}
