import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class BranchesDataSource with HttpService {
  BranchesDataSource._();
  static final BranchesDataSource instance = BranchesDataSource._();
  factory BranchesDataSource() {
    return instance;
  }

  final _endpoint = "/branches";

  Future<Map<String, dynamic>> createBranch(Map<String, dynamic> branch) async {
    final uri = HttpTools.generateUri(_endpoint);
    final res = await postQuery(uri, branch);
    return res;
  }

  Future<Map<String, dynamic>> getAllBranches() async {
    final uri = HttpTools.generateUri(_endpoint);
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>?> getBranchById(String branchId) async {
    final uri = HttpTools.generateUri("$_endpoint/$branchId");
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>> searchBranchByKeyword(String keyword) async {
    final uri = HttpTools.generateUri("$_endpoint/search/$keyword");
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>?> updateBranchById(
    String branchId,
    Map<String, dynamic> branch,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/$branchId");
    final res = await patchQuery(uri, body: branch);
    return res;
  }

  Future<Map<String, dynamic>?> deleteBranchById(String branchId) async {
    final uri = HttpTools.generateUri("$_endpoint/$branchId");
    final res = await deleteQuery(uri);
    return res;
  }
}
