import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/adjust_entry/adjust_entry_model.dart';
import 'package:kardex_app_front/src/domain/repositories/adjust_entries_repository.dart';

abstract class WriteAdjustEntryState {}

class WriteAdjustEntryInitial extends WriteAdjustEntryState {}

class WriteAdjustEntryLoading extends WriteAdjustEntryState {}

class WriteAdjustEntrySuccess extends WriteAdjustEntryState {
  final AdjustEntryInDb adjustEntry;
  WriteAdjustEntrySuccess(this.adjustEntry);
}

class WriteAdjustEntryFailure extends WriteAdjustEntryState {
  final String message;
  WriteAdjustEntryFailure(this.message);
}

class WriteAdjustEntryCubit extends Cubit<WriteAdjustEntryState> {
  final AdjustEntriesRepository repository;

  WriteAdjustEntryCubit({required this.repository}) : super(WriteAdjustEntryInitial());

  Future<void> createAdjustEntry(CreateAdjustEntry entry) async {
    emit(WriteAdjustEntryLoading());
    try {
      final res = await repository.createAdjustEntry(entry);
      emit(WriteAdjustEntrySuccess(res));
    } catch (e) {
      emit(WriteAdjustEntryFailure(e.toString()));
    }
  }
}
