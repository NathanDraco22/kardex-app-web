part of 'write_credit_notes_cubit.dart';

sealed class WriteCreditNoteState {}

final class WriteCreditNoteInitial extends WriteCreditNoteState {}

final class WritingCreditNote extends WriteCreditNoteState {}

class WriteCreditNoteSuccess extends WriteCreditNoteState {
  final CreditNoteInDb item;
  WriteCreditNoteSuccess(this.item);
}

final class CreditNoteCreated extends WriteCreditNoteSuccess {
  CreditNoteCreated(super.item);
}

final class CreditNoteUpdated extends WriteCreditNoteSuccess {
  CreditNoteUpdated(super.item);
}

final class CreditNoteDeleted extends WriteCreditNoteSuccess {
  CreditNoteDeleted(super.item);
}

final class WriteCreditNoteError extends WriteCreditNoteState {
  final String message;
  WriteCreditNoteError(this.message);
}
