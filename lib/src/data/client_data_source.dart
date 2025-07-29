import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/tool.dart';

class ClientsDataSource with HttpService {
  final _clientEndpoint = "/clients";

  Future<Map<String, dynamic>> createClient(Map<String, dynamic> client) async {
    final uri = HttpTools.generateUri(_clientEndpoint);
    final res = await postQuery(uri, client);
    return res;
  }

  Future<Map<String, dynamic>> getAllClients() async {
    final uri = HttpTools.generateUri(_clientEndpoint);
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>?> getClientById(String clientId) async {
    throw UnimplementedError();
  }

  Future<Map<String, dynamic>?> updateClientById(
    String clientId,
    Map<String, dynamic> client,
  ) async {
    final uri = HttpTools.generateUri("$_clientEndpoint/$clientId");
    final res = await patchQuery(uri, body: client);
    return res;
  }
}
