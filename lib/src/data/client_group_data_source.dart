import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class ClientGroupDataSource with HttpService {
  ClientGroupDataSource._();
  static final ClientGroupDataSource instance = ClientGroupDataSource._();
  factory ClientGroupDataSource() {
    return instance;
  }

  final _endpoint = "/client-groups";

  Future<Map<String, dynamic>> createClientGroup(Map<String, dynamic> group) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, group, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllClientGroups() async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> getClientGroupById(String groupId) async {
    final uri = HttpTools.generateUri("$_endpoint/$groupId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> updateClientGroupById(
    String groupId,
    Map<String, dynamic> group,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/$groupId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await patchQuery(uri, body: group, headers: headers);
    return res as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> deleteClientGroupById(String groupId) async {
    final uri = HttpTools.generateUri("$_endpoint/$groupId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await deleteQuery(uri, headers: headers);
    return res as Map<String, dynamic>?;
  }
}
