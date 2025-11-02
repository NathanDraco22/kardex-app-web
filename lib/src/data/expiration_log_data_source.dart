import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class ExpirationLogsDataSource with HttpService {
  ExpirationLogsDataSource._();
  static final ExpirationLogsDataSource instance = ExpirationLogsDataSource._();
  factory ExpirationLogsDataSource() {
    return instance;
  }

  final _endpoint = "/expiration-logs";

  Future<Map<String, dynamic>> createExpirationLog(Map<String, dynamic> expirationLog) async {
    final uri = HttpTools.generateUri(_endpoint);
    final header = HttpTools.generateAuthHeaders();
    return await postQuery(uri, expirationLog, headers: header);
  }

  Future<Map<String, dynamic>> getAllExpirationLogs(Map<String, String> params) async {
    final uri = HttpTools.generateUri(_endpoint, queryParameters: params);
    final header = HttpTools.generateAuthHeaders();
    return await getQuery(uri, headers: header);
  }

  Future<Map<String, dynamic>?> getExpirationLogById(String logId) async {
    final uri = HttpTools.generateUri("$_endpoint/$logId");
    final header = HttpTools.generateAuthHeaders();
    return await getQuery(uri, headers: header);
  }

  Future<Map<String, dynamic>?> deleteExpirationLogById(String logId) async {
    final uri = HttpTools.generateUri("$_endpoint/$logId");
    final header = HttpTools.generateAuthHeaders();
    return await deleteQuery(uri, headers: header);
  }

  Future<bool> hasNearExpiration(String branchId) async {
    final uri = HttpTools.generateUri("$_endpoint/near/$branchId");
    final header = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: header);

    return res['hasExpiration'] ?? false;
  }
}
