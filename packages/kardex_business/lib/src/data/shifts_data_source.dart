import '../services/http_service.dart';
import '../tools/http_tool.dart';

class ShiftsDataSource with HttpService {
  ShiftsDataSource._();
  static final ShiftsDataSource instance = ShiftsDataSource._();
  factory ShiftsDataSource() {
    return instance;
  }

  final _endpoint = '/shifts';

  Future<Map<String, dynamic>> createShift(Map<String, dynamic> shift) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, shift, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllShifts({
    Map<String, String>? queryParams,
  }) async {
    final uri = HttpTools.generateUri(_endpoint, queryParameters: queryParams);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> getActiveShiftByUser(String userId) async {
    final uri = HttpTools.generateUri('$_endpoint/active/$userId');
    final headers = HttpTools.generateAuthHeaders();
    final res = await getNullableQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getShiftPreview(String shiftId) async {
    final uri = HttpTools.generateUri('$_endpoint/$shiftId/preview');
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> closeShift(
    String shiftId,
    Map<String, dynamic> body,
  ) async {
    final uri = HttpTools.generateUri('$_endpoint/$shiftId/close');
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, body, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> getShiftById(String shiftId) async {
    final uri = HttpTools.generateUri('$_endpoint/$shiftId');
    final headers = HttpTools.generateAuthHeaders();
    final res = await getNullableQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> updateShiftById(
    String shiftId,
    Map<String, dynamic> shift,
  ) async {
    final uri = HttpTools.generateUri('$_endpoint/$shiftId');
    final headers = HttpTools.generateAuthHeaders();
    final res = await patchQuery(uri, body: shift, headers: headers);
    return res;
  }
}
