import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class DevolutionsDataSource with HttpService {
  DevolutionsDataSource._();
  static final DevolutionsDataSource instance = DevolutionsDataSource._();
  factory DevolutionsDataSource() {
    return instance;
  }

  final _endpoint = "/devolutions";

  Future<Map<String, dynamic>> createDevolution(Map<String, dynamic> devolution) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    return await postQuery(uri, devolution, headers: headers);
  }

  Future<Map<String, dynamic>> getAllDevolutions(Map<String, String> params) async {
    final uri = HttpTools.generateUri(_endpoint, queryParameters: params);
    final headers = HttpTools.generateAuthHeaders();
    return await getQuery(uri, headers: headers);
  }

  Future<Map<String, dynamic>?> getDevolutionById(String devolutionId) async {
    final uri = HttpTools.generateUri("$_endpoint/$devolutionId");
    final header = HttpTools.generateAuthHeaders();
    return await getQuery(uri, headers: header);
  }

  Future<Map<String, dynamic>?> confirmDevolutionById(String devolutionId) async {
    final uri = HttpTools.generateUri("$_endpoint/confirm/$devolutionId");
    final header = HttpTools.generateAuthHeaders();
    return await patchQuery(uri, headers: header);
  }

  Future<Map<String, dynamic>?> confirmAnonDevolutionById(String devolutionId) async {
    final uri = HttpTools.generateUri("$_endpoint/confirm-anon/$devolutionId");
    final header = HttpTools.generateAuthHeaders();
    return await patchQuery(uri, headers: header);
  }

  Future<Map<String, dynamic>?> cancelDevolutionById(String devolutionId) async {
    final uri = HttpTools.generateUri("$_endpoint/cancel/$devolutionId");
    final header = HttpTools.generateAuthHeaders();
    return await patchQuery(uri, headers: header);
  }

  Future<Map<String, dynamic>?> deleteDevolutionById(String devolutionId) async {
    final uri = HttpTools.generateUri("$_endpoint/$devolutionId");
    final header = HttpTools.generateAuthHeaders();
    return await deleteQuery(uri, headers: header);
  }

  Future<Map<String, dynamic>> getDevolutionHistory(Map<String, String> params) async {
    final uri = HttpTools.generateUri("$_endpoint/history", queryParameters: params);
    final headers = HttpTools.generateAuthHeaders();
    return await getQuery(uri, headers: headers);
  }

  Future<Map<String, dynamic>> getDevolutionByDocNumber(String docNumber) async {
    final uri = HttpTools.generateUri("$_endpoint/doc/$docNumber");
    final headers = HttpTools.generateAuthHeaders();
    return await getQuery(uri, headers: headers);
  }
}
