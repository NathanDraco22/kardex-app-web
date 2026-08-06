import 'package:kardex_business/src/services/dio_http_service.dart';
import 'package:kardex_business/src/services/http_service.dart';
import 'package:kardex_business/src/tools/http_tool.dart';

class ApiKeysDataSource with HttpService, DioHttpService {
  ApiKeysDataSource._();
  static final ApiKeysDataSource instance = ApiKeysDataSource._();
  factory ApiKeysDataSource() {
    return instance;
  }

  final _endpoint = "/api-keys";

  Future<List<dynamic>> getAllApiKeys() async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri(_endpoint);
    final res = await getCachedQuery(uri, headers: headers);
    if (res is List) {
      return res;
    }
    return (res as Map<String, dynamic>)['data'] ?? [];
  }

  Future<Map<String, dynamic>> createApiKey(Map<String, dynamic> body) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri(_endpoint);
    final res = await postQuery(uri, body, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> toggleApiKeyStatus(String keyId, bool isActive) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri("$_endpoint/$keyId/toggle");
    final res = await patchQuery(uri, body: {'isActive': isActive}, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> deleteApiKey(String keyId) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri("$_endpoint/$keyId");
    final res = await deleteQuery(uri, headers: headers);
    return res;
  }
}
