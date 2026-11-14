import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

import 'write_shift_cash_movements_state.dart';

class WriteShiftCashMovementsCubit extends Cubit<WriteShiftCashMovementsState> {
  final ShiftCashMovementsRepository repository;

  WriteShiftCashMovementsCubit({required this.repository})
      : super(WriteShiftCashMovementsInitial());

  Future<ShiftCashMovementInDb?> createMovement(
    CreateShiftCashMovement movement,
  ) async {
    emit(WriteShiftCashMovementsLoading());
    try {
      final created = await repository.createShiftCashMovement(movement);
      if (isClosed) return created;
      emit(ShiftCashMovementCreated(created));
      return created;
    } catch (e) {
      if (isClosed) return null;
      emit(WriteShiftCashMovementsError(e.toString()));
      return null;
    }
  }

  Future<ShiftCashMovementInDb?> deleteMovement(String movementId) async {
    emit(WriteShiftCashMovementsLoading());
    try {
      final deleted = await repository.deleteShiftCashMovementById(movementId);
      if (isClosed) return deleted;
      if (deleted != null) {
        emit(ShiftCashMovementDeleted(deleted));
      }
      return deleted;
    } catch (e) {
      if (isClosed) return null;
      emit(WriteShiftCashMovementsError(e.toString()));
      return null;
    }
  }
}
