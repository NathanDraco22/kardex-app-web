import 'package:kardex_business/src/services/http_service.dart';
import 'package:kardex_business/src/tools/http_tool.dart';

class InventoriesDataSource with HttpService {
  InventoriesDataSource._();
  static final InventoriesDataSource instance = InventoriesDataSource._();
  factory InventoriesDataSource() {
    return instance;
  }

  final _endpoint = "/inventories";

  Future<Map<String, dynamic>> getAllInventories(String branchId) async {
    final uri = HttpTools.generateUri(
      _endpoint,
      queryParameters: {'branchId': branchId},
    );

    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }
}
