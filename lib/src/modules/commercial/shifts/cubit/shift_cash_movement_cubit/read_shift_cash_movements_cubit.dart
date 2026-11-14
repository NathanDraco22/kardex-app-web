import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

import 'read_shift_cash_movements_state.dart';

class ReadShiftCashMovementsCubit extends Cubit<ReadShiftCashMovementsState> {
  final ShiftCashMovementsRepository repository;
  final String? shiftId;

  StreamSubscription<RepoEvent<ShiftCashMovementInDb>>? _repoSub;

  ReadShiftCashMovementsCubit({
    required this.repository,
    this.shiftId,
  }) : super(ReadShiftCashMovementsInitial()) {
    _repoSub = repository.eventStream.listen((event) {
      if (state is! ReadShiftCashMovementsLoaded) return;
      final list = List<ShiftCashMovementInDb>.from(
        (state as ReadShiftCashMovementsLoaded).movements,
      );

      switch (event) {
        case RepoItemCreated<ShiftCashMovementInDb>(:final item):
          if (shiftId != null && item.shiftId != shiftId) return;
          if (!list.any((m) => m.id == item.id)) {
            list.insert(0, item);
            emit(ReadShiftCashMovementsLoaded(list));
          }
        case RepoItemDeleted<ShiftCashMovementInDb>(:final item):
          list.removeWhere((m) => m.id == item.id);
          emit(ReadShiftCashMovementsLoaded(list));
        case RepoItemUpdated<ShiftCashMovementInDb>(:final item):
          final updated = list.map((m) => m.id == item.id ? item : m).toList();
          emit(ReadShiftCashMovementsLoaded(updated));
      }
    });
  }

  Future<void> loadMovements({String? overrideShiftId}) async {
    final targetShiftId = overrideShiftId ?? shiftId;
    emit(ReadShiftCashMovementsLoading());
    try {
      final movements = await repository.getAllShiftCashMovements(
        ShiftCashMovementQueryParams(shiftId: targetShiftId),
      );
      if (isClosed) return;
      emit(ReadShiftCashMovementsLoaded(movements));
    } catch (e) {
      if (isClosed) return;
      emit(ReadShiftCashMovementsError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _repoSub?.cancel();
    return super.close();
  }
}
