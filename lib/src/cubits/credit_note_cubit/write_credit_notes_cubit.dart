import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'write_credit_notes_state.dart';

class WriteCreditNoteCubit extends Cubit<WriteCreditNoteState> {
  WriteCreditNoteCubit(this._repository) : super(WriteCreditNoteInitial());

  final CreditNotesRepository _repository;

  Future<CreditNoteInDb?> create(CreateCreditNote createCreditNote) async {
    emit(WritingCreditNote());
    try {
      final item = await _repository.createCreditNote(createCreditNote);
      if (isClosed) return item;
      emit(CreditNoteCreated(item));
      emit(WriteCreditNoteInitial());
      return item;
    } catch (error) {
      if (isClosed) return null;
      emit(WriteCreditNoteError(error.toString()));
      return null;
    }
  }

  Future<CreditNoteInDb?> approve(String id, UserInfo approvedBy) async {
    emit(WritingCreditNote());
    try {
      final item = await _repository.approveCreditNote(id, approvedBy);
      if (isClosed) return item;
      emit(CreditNoteApproved(item));
      emit(WriteCreditNoteInitial());
      return item;
    } catch (error) {
      if (isClosed) return null;
      emit(WriteCreditNoteError(error.toString()));
      return null;
    }
  }

  Future<CreditNoteInDb?> reject(
    String id,
    UserInfo rejectedBy,
    String reason,
  ) async {
    emit(WritingCreditNote());
    try {
      final item = await _repository.rejectCreditNote(id, rejectedBy, reason);
      if (isClosed) return item;
      emit(CreditNoteRejected(item));
      emit(WriteCreditNoteInitial());
      return item;
    } catch (error) {
      if (isClosed) return null;
      emit(WriteCreditNoteError(error.toString()));
      return null;
    }
  }
}
