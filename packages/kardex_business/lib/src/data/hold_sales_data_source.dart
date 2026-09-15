import '../services/http_service.dart';
import '../tools/http_tool.dart';

class HoldSalesDataSource with HttpService {
  HoldSalesDataSource._();
  static final HoldSalesDataSource instance = HoldSalesDataSource._();
  factory HoldSalesDataSource() {
    return instance;
  }

  final _endpoint = "/hold-sales";

  Future<Map<String, dynamic>> createHoldSale(Map<String, dynamic> holdSale) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, holdSale, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllHoldSales({
    Map<String, String>? queryParams,
  }) async {
    final uri = HttpTools.generateUri(
      _endpoint,
      queryParameters: queryParams,
    );
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> getHoldSaleById(String holdSaleId) async {
    final uri = HttpTools.generateUri("$_endpoint/$holdSaleId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> updateHoldSaleById(
    String holdSaleId,
    Map<String, dynamic> holdSale,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/$holdSaleId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await patchQuery(uri, body: holdSale, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> deleteHoldSaleById(String holdSaleId) async {
    final uri = HttpTools.generateUri("$_endpoint/$holdSaleId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await deleteQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> deleteAllHoldSalesByBranch(String branchId) async {
    final uri = HttpTools.generateUri("$_endpoint/branch/$branchId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await deleteQuery(uri, headers: headers);
    return res;
  }
}

