import 'package:kardex_app_front/src/services/dio_http_service.dart';
import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class AdminPanelDataSource with HttpService, DioHttpService {
  AdminPanelDataSource._();
  static final AdminPanelDataSource instance = AdminPanelDataSource._();
  factory AdminPanelDataSource() {
    return instance;
  }

  final _endpoint = "/admin-panels";

  Future<Map<String, dynamic>> getAdminCharts({required int endDate}) async {
    final uri = HttpTools.generateUri(
      "$_endpoint/charts",
      queryParameters: {"endDate": endDate.toString()},
    );
    final headers = HttpTools.generateAuthHeaders();
    final res = await getCachedQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAdminChartsByBranch({
    required String branchId,
    required int endDate,
  }) async {
    final uri = HttpTools.generateUri(
      "$_endpoint/charts/$branchId",
      queryParameters: {"endDate": endDate.toString()},
    );
    final headers = HttpTools.generateAuthHeaders();
    final res = await getCachedQuery(uri, headers: headers);
    return res;
  }
}
