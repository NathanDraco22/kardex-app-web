import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'write_entry_doc_state.dart';

class WriteEntryDocCubit extends Cubit<WriteEntryDocState> {
  WriteEntryDocCubit(
    this.entryDocsRepository, {
    this.useKardex = true,
  }) : super(WriteEntryDocInitial());

  final EntryDocsRepository entryDocsRepository;
  bool useKardex;

  void setUseKardex(bool value) {
    useKardex = value;
  }

  Future<void> createNewEntryDoc(CreateEntryDoc createEntryDoc) async {
    if (!useKardex) {
      return createNewEntryDocDirect(createEntryDoc);
    }
    emit(WriteEntryDocInProgress());
    try {
      final doc = await entryDocsRepository.createEntryDoc(createEntryDoc);
      emit(WriteEntryDocSuccess(doc));
      emit(WriteEntryDocInitial());
    } catch (error) {
      emit(WriteEntryDocError(error.toString()));
    }
  }

  Future<void> createNewEntryDocDirect(CreateEntryDoc createEntryDoc) async {
    emit(WriteEntryDocInProgress());
    try {
      final doc = await entryDocsRepository.createEntryDocDirect(createEntryDoc);
      emit(WriteEntryDocSuccess(doc));
      emit(WriteEntryDocInitial());
    } catch (error) {
      emit(WriteEntryDocError(error.toString()));
    }
  }
}
