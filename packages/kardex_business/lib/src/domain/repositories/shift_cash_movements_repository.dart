import '../../data/shift_cash_movements_data_source.dart';
import '../../domain/models/shift_cash_movement_model/shift_cash_movement_model.dart';
import '../../domain/query_params/shift_cash_movement_query_params.dart';
import '../../domain/responses/list_responses.dart';
import '../../tools/reactive_repo/reactive_repository.dart';

class ShiftCashMovementsRepository with ReactiveRepository<ShiftCashMovementInDb> {
  final ShiftCashMovementsDataSource shiftCashMovementsDataSource;

  ShiftCashMovementsRepository(this.shiftCashMovementsDataSource);

  Future<ShiftCashMovementInDb> createShiftCashMovement(
    CreateShiftCashMovement movement,
  ) async {
    final result = await shiftCashMovementsDataSource.createShiftCashMovement(
      movement.toJson(),
    );
    final newMovement = ShiftCashMovementInDb.fromJson(result);
    notifyItemCreated(newMovement);
    return newMovement;
  }

  Future<List<ShiftCashMovementInDb>> getAllShiftCashMovements([
    ShiftCashMovementQueryParams? params,
  ]) async {
    final results = await shiftCashMovementsDataSource.getAllShiftCashMovements(
      queryParams: params?.toMap(),
    );
    final response = ListResponse<ShiftCashMovementInDb>.fromJson(
      results,
      ShiftCashMovementInDb.fromJson,
    );
    return response.data;
  }

  Future<ShiftCashMovementInDb?> getShiftCashMovementById(
    String movementId,
  ) async {
    final result = await shiftCashMovementsDataSource.getShiftCashMovementById(
      movementId,
    );
    if (result == null) return null;
    return ShiftCashMovementInDb.fromJson(result);
  }

  Future<ShiftCashMovementInDb?> deleteShiftCashMovementById(
    String movementId,
  ) async {
    final result = await shiftCashMovementsDataSource.deleteShiftCashMovementById(
      movementId,
    );
    if (result == null) return null;

    final deletedMovement = ShiftCashMovementInDb.fromJson(result);
    notifyItemDeleted(deletedMovement);
    return deletedMovement;
  }
}
