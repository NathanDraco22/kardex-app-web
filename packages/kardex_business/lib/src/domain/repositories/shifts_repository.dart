import '../../data/shifts_data_source.dart';
import '../../domain/models/shift_model/shift_model.dart';
import '../../domain/query_params/shift_query_params.dart';
import '../../domain/responses/list_responses.dart';
import '../../tools/reactive_repo/reactive_repository.dart';

class ShiftsRepository with ReactiveRepository<ShiftInDb> {
  final ShiftsDataSource shiftsDataSource;

  ShiftsRepository(this.shiftsDataSource);

  Future<ShiftInDb> createShift(CreateShift createShift) async {
    final result = await shiftsDataSource.createShift(createShift.toJson());
    final newShift = ShiftInDb.fromJson(result);
    notifyItemCreated(newShift);
    return newShift;
  }

  Future<List<ShiftInDb>> getAllShifts([ShiftQueryParams? params]) async {
    final results = await shiftsDataSource.getAllShifts(
      queryParams: params?.toMap(),
    );
    final response = ListResponse<ShiftInDb>.fromJson(
      results,
      ShiftInDb.fromJson,
    );
    return response.data;
  }

  Future<ShiftInDb?> getActiveShiftByUser(String userId) async {
    final result = await shiftsDataSource.getActiveShiftByUser(userId);
    if (result == null) return null;
    return ShiftInDb.fromJson(result);
  }

  Future<ShiftPreview> getShiftPreview(String shiftId) async {
    final result = await shiftsDataSource.getShiftPreview(shiftId);
    return ShiftPreview.fromJson(result);
  }

  Future<ShiftInDb> closeShift(
    String shiftId,
    CloseShiftRequest request,
  ) async {
    final result = await shiftsDataSource.closeShift(
      shiftId,
      request.toJson(),
    );
    final closedShift = ShiftInDb.fromJson(result);
    notifyItemUpdated(closedShift);
    return closedShift;
  }

  Future<ShiftInDb?> getShiftById(String shiftId) async {
    final result = await shiftsDataSource.getShiftById(shiftId);
    if (result == null) return null;
    return ShiftInDb.fromJson(result);
  }

  Future<ShiftInDb?> updateShiftById(
    String shiftId,
    UpdateShift shift,
  ) async {
    final result = await shiftsDataSource.updateShiftById(
      shiftId,
      shift.toJson(),
    );
    if (result == null) return null;

    final updatedShift = ShiftInDb.fromJson(result);
    notifyItemUpdated(updatedShift);
    return updatedShift;
  }
}
