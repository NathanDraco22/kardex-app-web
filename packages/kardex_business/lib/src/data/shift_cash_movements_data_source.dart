import '../services/http_service.dart';
import '../tools/http_tool.dart';

class ShiftCashMovementsDataSource with HttpService {
  ShiftCashMovementsDataSource._();
  static final ShiftCashMovementsDataSource instance = ShiftCashMovementsDataSource._();
  factory ShiftCashMovementsDataSource() {
    return instance;
  }

  final _endpoint = '/shift-cash-movements';

  Future<Map<String, dynamic>> createShiftCashMovement(
    Map<String, dynamic> movement,
  ) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, movement, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllShiftCashMovements({
    Map<String, String>? queryParams,
  }) async {
    final uri = HttpTools.generateUri(_endpoint, queryParameters: queryParams);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> getShiftCashMovementById(
    String movementId,
  ) async {
    final uri = HttpTools.generateUri('$_endpoint/$movementId');
    final headers = HttpTools.generateAuthHeaders();
    final res = await getNullableQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> deleteShiftCashMovementById(
    String movementId,
  ) async {
    final uri = HttpTools.generateUri('$_endpoint/$movementId');
    final headers = HttpTools.generateAuthHeaders();
    final res = await deleteQuery(uri, headers: headers);
    return res;
  }
}
