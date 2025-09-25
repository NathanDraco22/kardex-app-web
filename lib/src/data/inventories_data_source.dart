import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class InventoriesDataSource with HttpService {
  InventoriesDataSource._();
  static final InventoriesDataSource instance = InventoriesDataSource._();
  factory InventoriesDataSource() {
    return instance;
  }

  final _endpoint = "/inventories";

  Future<Map<String, dynamic>> getAllInventories() async {
    final currentBranch = BranchesTool.getCurrentBranchId();

    final uri = HttpTools.generateUri(
      _endpoint,
      queryParameters: {'branchId': currentBranch},
    );

    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }
}
