import 'package:kardex_business/src/services/dio_http_service.dart';
import 'package:kardex_business/src/services/http_service.dart';
import 'package:kardex_business/src/tools/http_tool.dart';

class AdjustmentRequestsDataSource with HttpService, DioHttpService {
  AdjustmentRequestsDataSource._();
  static final AdjustmentRequestsDataSource instance = AdjustmentRequestsDataSource._();
  factory AdjustmentRequestsDataSource() => instance;

  final _endpoint = "/adjustment-requests";

  Future<Map<String, dynamic>> createAdjustmentRequest(Map<String, dynamic> data) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, data, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllAdjustmentRequests(Map<String, String> query) async {
    final uri = HttpTools.generateUri(_endpoint, queryParameters: query);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAdjustmentRequestById(String id) async {
    final uri = HttpTools.generateUri("$_endpoint/$id");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> updateAdjustmentRequestById(String id, Map<String, dynamic> data) async {
    final uri = HttpTools.generateUri("$_endpoint/$id");
    final headers = HttpTools.generateAuthHeaders();
    final res = await patchQuery(uri, body: data, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> deleteAdjustmentRequestById(String id) async {
    final uri = HttpTools.generateUri("$_endpoint/$id");
    final headers = HttpTools.generateAuthHeaders();
    final res = await deleteQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> approveAdjustmentRequest(String id, Map<String, dynamic> data) async {
    final uri = HttpTools.generateUri("$_endpoint/$id/approve");
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, data, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> cancelAdjustmentRequest(String id, Map<String, dynamic> data) async {
    final uri = HttpTools.generateUri("$_endpoint/$id/cancel");
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, data, headers: headers);
    return res;
  }
}
