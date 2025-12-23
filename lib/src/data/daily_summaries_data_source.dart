import 'package:kardex_app_front/src/services/dio_http_service.dart';
import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class DailySummariesDataSource with HttpService, DioHttpService {
  DailySummariesDataSource._();
  static final DailySummariesDataSource instance = DailySummariesDataSource._();
  factory DailySummariesDataSource() {
    return instance;
  }

  final _endpoint = "/daily-summaries";

  Future<Map<String, dynamic>> getAll({required Map<String, String> queryParams}) async {
    final uri = HttpTools.generateUri(_endpoint, queryParameters: queryParams);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getCachedQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final uri = HttpTools.generateUri("$_endpoint/$id");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getCachedQuery(uri, headers: headers);
    return res;
  }
}
