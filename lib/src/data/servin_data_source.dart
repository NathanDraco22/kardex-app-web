import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class ServinDataSource with HttpService {
  final _activatorEndpoint = '/api/v1/activators';

  Future<Map<String, dynamic>> getActiveServin(String apiKey, String nickname) async {
    const originServer = String.fromEnvironment("ORIGIN_SERVER_URL", defaultValue: '');

    if (originServer.isEmpty) {
      throw Exception('ORIGIN_SERVER_URL is empty');
    }

    final url = Uri.parse('$originServer$_activatorEndpoint/$nickname');

    final res = await getQuery(url, headers: {'X-API-KEY': apiKey});

    return res;
  }

  final _endpoint = "/auths/servin-status";

  Future<Map<String, dynamic>> getServinStatus() async {
    final uri = HttpTools.generateUri(_endpoint);
    final res = await getQuery(uri);
    return res;
  }
}
