import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class ClientsDataSource with HttpService {
  final _clientEndpoint = "/clients";

  Future<Map<String, dynamic>> createClient(Map<String, dynamic> client) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri(_clientEndpoint);
    final res = await postQuery(uri, client, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> createMultipleInitialBalance(Map<String, dynamic> payload) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri("$_clientEndpoint/multi-initial-balance");
    final res = await postQuery(uri, payload, headers: headers);
    return res;
  }


  Future<Map<String, dynamic>> getAllClients() async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri(_clientEndpoint);
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getClients(Map<String, String> params) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri(_clientEndpoint, queryParameters: params);
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getClientsWithBalance(Map<String, String> queryParams) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri(
      "$_clientEndpoint/balance",
      queryParameters: queryParams,
    );
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> getClientById(String clientId) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri("$_clientEndpoint/$clientId");
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getClientByCardId(String cardId) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri("$_clientEndpoint/card/$cardId");
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> searchClientByKeyword(String keyword) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri("$_clientEndpoint/search/$keyword");
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> searchClientWithBalance(String keyword) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri("$_clientEndpoint/search/balance/$keyword");
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> updateClientById(
    String clientId,
    Map<String, dynamic> client,
  ) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri("$_clientEndpoint/$clientId");
    final res = await patchQuery(uri, body: client, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> deleteClientById(
    String clientId,
  ) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri("$_clientEndpoint/$clientId");
    final res = await deleteQuery(uri, headers: headers);
    return res;
  }
}
