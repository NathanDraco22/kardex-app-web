import 'package:kardex_app_front/src/services/dio_http_service.dart';
import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class ExecutiveSummariesDataSource with HttpService, DioHttpService {
  ExecutiveSummariesDataSource._();
  static final ExecutiveSummariesDataSource instance = ExecutiveSummariesDataSource._();
  factory ExecutiveSummariesDataSource() {
    return instance;
  }

  final _endpoint = "/executive-summaries";

  Future<Map<String, dynamic>> getAll({required Map<String, String> queryParams}) async {
    final uri = HttpTools.generateUri(_endpoint, queryParameters: queryParams);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getCachedQuery(
      uri,
      headers: headers,
      maxStale: const Duration(days: 1),
    );
    return res;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final uri = HttpTools.generateUri("$_endpoint/$id");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getCachedQuery(uri, headers: headers);
    return res;
  }
}
