import 'package:kardex_app_front/src/services/dio_http_service.dart';
import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class AdjustEntriesDataSource with HttpService, DioHttpService {
  AdjustEntriesDataSource._();
  static final AdjustEntriesDataSource instance = AdjustEntriesDataSource._();
  factory AdjustEntriesDataSource() => instance;

  final _endpoint = "/adjust-entries";

  Future<Map<String, dynamic>> createAdjustEntry(Map<String, dynamic> data) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(
      uri,
      data,
      headers: headers,
    );
    return res;
  }

  Future<Map<String, dynamic>> getAllAdjustEntries(Map<String, String> query) async {
    final uri = HttpTools.generateUri(_endpoint, queryParameters: query);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(
      uri,
      headers: headers,
    );
    return res;
  }

  Future<Map<String, dynamic>> getAdjustEntryById(String id) async {
    final uri = HttpTools.generateUri("$_endpoint/$id");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(
      uri,
      headers: headers,
    );
    return res;
  }

  Future<Map<String, dynamic>> getAdjustEntryByDocNumber(String docNumber, String branchId) async {
    final uri = HttpTools.generateUri("$_endpoint/$branchId/$docNumber");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(
      uri,
      headers: headers,
    );
    return res;
  }
}
