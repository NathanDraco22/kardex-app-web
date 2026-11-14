import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

import 'read_shifts_state.dart';

class ReadShiftsCubit extends Cubit<ReadShiftsState> {
  final ShiftsRepository shiftsRepository;

  StreamSubscription<RepoEvent<ShiftInDb>>? _repoSub;
  ShiftQueryParams _lastParams = ShiftQueryParams();

  ReadShiftsCubit({required this.shiftsRepository}) : super(ReadShiftsInitial()) {
    _repoSub = shiftsRepository.eventStream.listen((event) {
      if (state is! ReadShiftsLoaded) return;
      final current = List<ShiftInDb>.from((state as ReadShiftsLoaded).shifts);

      switch (event) {
        case RepoItemCreated<ShiftInDb>(:final item):
          if (!current.any((s) => s.id == item.id)) {
            current.insert(0, item);
            emit(ReadShiftsLoaded(current));
          }
        case RepoItemUpdated<ShiftInDb>(:final item):
          final updated = current.map((s) => s.id == item.id ? item : s).toList();
          emit(ReadShiftsLoaded(updated));
        case RepoItemDeleted<ShiftInDb>(:final item):
          current.removeWhere((s) => s.id == item.id);
          emit(ReadShiftsLoaded(current));
      }
    });
  }

  Future<void> loadShifts([ShiftQueryParams? params]) async {
    if (params != null) _lastParams = params;
    emit(ReadShiftsLoading());
    try {
      final shifts = await shiftsRepository.getAllShifts(_lastParams);
      if (isClosed) return;
      emit(ReadShiftsLoaded(shifts));
    } catch (e) {
      if (isClosed) return;
      emit(ReadShiftsError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _repoSub?.cancel();
    return super.close();
  }
}
