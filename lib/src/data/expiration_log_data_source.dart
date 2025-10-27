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
    return await postQuery(uri, expirationLog);
  }

  Future<Map<String, dynamic>> getAllExpirationLogs(Map<String, String> params) async {
    final uri = HttpTools.generateUri(_endpoint, queryParameters: params);
    return await getQuery(uri);
  }

  Future<Map<String, dynamic>?> getExpirationLogById(String logId) async {
    final uri = HttpTools.generateUri("$_endpoint/$logId");
    return await getQuery(uri);
  }

  Future<Map<String, dynamic>?> deleteExpirationLogById(String logId) async {
    final uri = HttpTools.generateUri("$_endpoint/$logId");
    return await deleteQuery(uri);
  }

  Future<bool> hasNearExpiration(String branchId) async {
    final uri = HttpTools.generateUri("$_endpoint/near/$branchId");
    final res = await getQuery(uri);

    return res['hasExpiration'] ?? false;
  }
}
