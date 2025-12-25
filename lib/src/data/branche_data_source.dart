import 'package:kardex_app_front/src/services/dio_http_service.dart';
import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class BranchesDataSource with HttpService, DioHttpService {
  BranchesDataSource._();
  static final BranchesDataSource instance = BranchesDataSource._();
  factory BranchesDataSource() {
    return instance;
  }

  final _endpoint = "/branches";

  Future<Map<String, dynamic>> createBranch(Map<String, dynamic> branch) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri(_endpoint);
    final res = await postQuery(uri, branch, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllBranches() async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri(_endpoint);
    final res = await getCachedQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> getBranchById(String branchId) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri("$_endpoint/$branchId");
    final res = await getCachedQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> searchBranchByKeyword(String keyword) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri("$_endpoint/search/$keyword");
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> updateBranchById(
    String branchId,
    Map<String, dynamic> branch,
  ) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri("$_endpoint/$branchId");
    final res = await patchQuery(uri, body: branch, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> deleteBranchById(String branchId) async {
    final headers = HttpTools.generateAuthHeaders();
    final uri = HttpTools.generateUri("$_endpoint/$branchId");
    final res = await deleteQuery(uri, headers: headers);
    return res;
  }
}
