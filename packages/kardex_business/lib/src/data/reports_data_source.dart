import 'package:kardex_business/src/services/http_service.dart';
import 'package:kardex_business/src/tools/http_tool.dart';

class ReportsDataSource with HttpService {
  ReportsDataSource._();
  static final ReportsDataSource instance = ReportsDataSource._();
  factory ReportsDataSource() {
    return instance;
  }

  final _endpoint = "/reports";

  Future<Map<String, dynamic>> getTotalResultsByDateRange(Map<String, String> params) async {
    final uri = HttpTools.generateUri(
      "$_endpoint/total-results-by-date-range",
      queryParameters: params,
    );
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getGeneralReport(Map<String, String> params) async {
    final uri = HttpTools.generateUri(
      "$_endpoint/general-report",
      queryParameters: params,
    );
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }
}
