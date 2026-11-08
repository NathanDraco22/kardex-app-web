import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_credit_notes_state.dart';

class ReadCreditNoteCubit extends Cubit<ReadCreditNoteState> {
  ReadCreditNoteCubit(this._repository) : super(ReadCreditNoteInitial()) {
    _subscription = _repository.eventStream.listen(_handleRepoEvent);
  }

  final CreditNotesRepository _repository;
  StreamSubscription<RepoEvent<CreditNoteInDb>>? _subscription;

  void _handleRepoEvent(RepoEvent<CreditNoteInDb> event) {
    switch (event) {
      case RepoItemCreated(:final item):
        markCreditNoteCreated(item);
      case RepoItemUpdated(:final item):
        markCreditNoteUpdated(item);
      case RepoItemDeleted(:final item):
        markCreditNoteDeleted(item);
    }
  }

  Future<void> getAll([CreditNoteQueryParams? params]) async {
    final currentState = state;
    if (currentState is ReadCreditNoteSuccess) {
      emit(ReadCreditNoteRefreshing.fromSuccess(currentState));
    } else {
      emit(ReadCreditNoteLoading());
    }
    try {
      final items = await _repository.getAllCreditNotes(params ?? CreditNoteQueryParams());
      if (isClosed) return;
      emit(ReadCreditNoteSuccess(items));
    } catch (error) {
      if (isClosed) return;
      emit(ReadCreditNoteError(error.toString()));
    }
  }

  Future<void> getById(String creditNoteId) async {
    emit(ReadCreditNoteLoading());
    try {
      final item = await _repository.getCreditNoteById(creditNoteId);
      if (isClosed) return;
      if (item == null) {
        emit(ReadCreditNoteError("CreditNote not found"));
      } else {
        emit(ReadCreditNoteSuccess([item]));
      }
    } catch (error) {
      if (isClosed) return;
      emit(ReadCreditNoteError(error.toString()));
    }
  }

  void markCreditNoteCreated(CreditNoteInDb item) {
    final currentState = state;
    if (currentState is ReadCreditNoteSuccess) {
      final items = [item, ...currentState.items.where((u) => u.id != item.id)];
      final newItems = [...currentState.newItems, item];
      emit(ReadCreditNoteSuccess(items, newItems: newItems));
    }
  }

  void markCreditNoteUpdated(CreditNoteInDb item) {
    final currentState = state;
    if (currentState is ReadCreditNoteSuccess) {
      final items = currentState.items.map((u) => u.id == item.id ? item : u).toList();
      final updatedItems = [...currentState.updatedItems, item];
      emit(ReadCreditNoteSuccess(items, updatedItems: updatedItems));
    }
  }

  void markCreditNoteDeleted(CreditNoteInDb item) {
    final currentState = state;
    if (currentState is ReadCreditNoteSuccess) {
      final items = currentState.items.where((u) => u.id != item.id).toList();
      final deletedItems = [...currentState.deletedItems, item];
      emit(ReadCreditNoteSuccess(items, deletedItems: deletedItems));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
