import 'package:kardex_app_front/src/services/dio_http_service.dart';
import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class ProductAccountsDataSource with HttpService, DioHttpService {
  ProductAccountsDataSource._();
  static final ProductAccountsDataSource instance = ProductAccountsDataSource._();
  factory ProductAccountsDataSource() {
    return instance;
  }

  final _endpoint = "/product-accounts";

  Future<Map<String, dynamic>> getProductAccountsByProduct(String productId) async {
    final uri = HttpTools.generateUri("$_endpoint/products/$productId/accounts");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> addProductAccount(String productId, String branchId, Map<String, dynamic> body) async {
    final uri = HttpTools.generateUri("$_endpoint/products/$productId/branches/$branchId/add");
    final headers = HttpTools.generateAuthHeaders();
    final res = await patchQuery(uri, headers: headers, body: body);
    return res;
  }

  Future<Map<String, dynamic>> substractProductAccount(String productId, String branchId, Map<String, dynamic> body) async {
    final uri = HttpTools.generateUri("$_endpoint/products/$productId/branches/$branchId/substract");
    final headers = HttpTools.generateAuthHeaders();
    final res = await patchQuery(uri, headers: headers, body: body);
    return res;
  }
}
