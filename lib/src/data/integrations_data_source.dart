import 'package:kardex_app_front/src/services/dio_http_service.dart';
import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class IntegrationsDataSource with HttpService, DioHttpService {
  IntegrationsDataSource._();
  static final IntegrationsDataSource instance = IntegrationsDataSource._();
  factory IntegrationsDataSource() {
    return instance;
  }

  final _endpoint = "/integrations";

  Future<Map<String, dynamic>> getAllIntegrations() async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri(_endpoint);
    final res = await getCachedQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> getIntegrationById(String integrationId) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri("$_endpoint/$integrationId");
    final res = await getCachedQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> updateIntegrationById(
    String integrationId,
    Map<String, dynamic> body,
  ) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri("$_endpoint/$integrationId");
    final res = await patchQuery(uri, body: body, headers: headers);
    return res;
  }

  Future<void> sendTelegramTestNotification() async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri("$_endpoint/telegram/test");
    await postQuery(uri, {}, headers: headers);
  }
}
