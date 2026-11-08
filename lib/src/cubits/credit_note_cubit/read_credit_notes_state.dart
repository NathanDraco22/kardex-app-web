part of 'read_credit_notes_cubit.dart';

sealed class ReadCreditNoteState {}

final class ReadCreditNoteInitial extends ReadCreditNoteState {}

final class ReadCreditNoteLoading extends ReadCreditNoteState {}

class ReadCreditNoteSuccess extends ReadCreditNoteState {
  final List<CreditNoteInDb> items;
  List<CreditNoteInDb> newItems;
  List<CreditNoteInDb> updatedItems;
  List<CreditNoteInDb> deletedItems;

  ReadCreditNoteSuccess(
    this.items, {
    this.newItems = const [],
    this.updatedItems = const [],
    this.deletedItems = const [],
  });
}

final class ReadCreditNoteRefreshing extends ReadCreditNoteSuccess {
  ReadCreditNoteRefreshing(
    super.items, {
    super.newItems,
    super.updatedItems,
    super.deletedItems,
  });

  factory ReadCreditNoteRefreshing.fromSuccess(
    ReadCreditNoteSuccess success,
  ) =>
      ReadCreditNoteRefreshing(
        success.items,
        newItems: success.newItems,
        updatedItems: success.updatedItems,
        deletedItems: success.deletedItems,
      );
}

final class ReadCreditNoteError extends ReadCreditNoteState {
  final String message;
  ReadCreditNoteError(this.message);
}
