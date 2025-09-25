import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/constant.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class ExitDocsDataSource with HttpService {
  ExitDocsDataSource._();
  static final ExitDocsDataSource instance = ExitDocsDataSource._();
  factory ExitDocsDataSource() {
    return instance;
  }

  final _endpoint = "/exit-docs";

  Future<Map<String, dynamic>> createExitDoc(Map<String, dynamic> exitDoc) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, exitDoc, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllExitDocs() async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getPaginatedExitDocs(int offset) async {
    final uri = HttpTools.generateUri(
      "$_endpoint/paginated",
      queryParameters: {
        "offset": offset.toString(),
        "limit": paginationItems.toString(),
      },
    );
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> getExitDocById(String docId) async {
    final uri = HttpTools.generateUri("$_endpoint/$docId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> searchExitDocByKeyword(String keyword) async {
    final uri = HttpTools.generateUri("$_endpoint/search/$keyword");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }
}
