import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/constant.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class EntryDocsDataSource with HttpService {
  EntryDocsDataSource._();
  static final EntryDocsDataSource instance = EntryDocsDataSource._();
  factory EntryDocsDataSource() {
    return instance;
  }

  final _endpoint = "/entry-docs";

  Future<Map<String, dynamic>> createEntryDoc(Map<String, dynamic> entryDoc) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, entryDoc, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllEntryDocs() async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getPaginatedEntryDocs(int offset) async {
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

  Future<Map<String, dynamic>?> getEntryDocById(String docId) async {
    final uri = HttpTools.generateUri("$_endpoint/$docId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> searchEntryDocByKeyword(String keyword) async {
    final uri = HttpTools.generateUri("$_endpoint/search/$keyword");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }
}
