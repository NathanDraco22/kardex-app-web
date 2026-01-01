import 'package:kardex_app_front/src/services/dio_http_service.dart';
import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class AdjustExitsDataSource with HttpService, DioHttpService {
  AdjustExitsDataSource._();
  static final AdjustExitsDataSource instance = AdjustExitsDataSource._();
  factory AdjustExitsDataSource() => instance;

  final _endpoint = "/adjust-exits";

  Future<Map<String, dynamic>> createAdjustExit(Map<String, dynamic> data) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(
      uri,
      data,
      headers: headers,
    );
    return res;
  }

  Future<Map<String, dynamic>> getAllAdjustExits(Map<String, String> query) async {
    final uri = HttpTools.generateUri(_endpoint, queryParameters: query);
    final headers = HttpTools.generateAuthHeaders();

    final res = await getQuery(
      uri,
      headers: headers,
    );
    return res;
  }

  Future<Map<String, dynamic>> getAdjustExitById(String id) async {
    final uri = HttpTools.generateUri("$_endpoint/$id");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(
      uri,
      headers: headers,
    );
    return res;
  }

  Future<Map<String, dynamic>> getAdjustExitByDocNumber(String docNumber, String branchId) async {
    final uri = HttpTools.generateUri("$_endpoint/$branchId/$docNumber");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(
      uri,
      headers: headers,
    );
    return res;
  }
}
