import 'package:kardex_app_front/src/services/http_service.dart';
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
    final res = await postQuery(uri, exitDoc);
    return res;
  }

  Future<Map<String, dynamic>> getAllExitDocs() async {
    final uri = HttpTools.generateUri(_endpoint);
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>?> getExitDocById(String docId) async {
    final uri = HttpTools.generateUri("$_endpoint/$docId");
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>> searchExitDocByKeyword(String keyword) async {
    final uri = HttpTools.generateUri("$_endpoint/search/$keyword");
    final res = await getQuery(uri);
    return res;
  }
}
