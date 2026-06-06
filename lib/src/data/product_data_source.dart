import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/constant.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class ProductsDataSource with HttpService {
  ProductsDataSource._();
  static final ProductsDataSource instance = ProductsDataSource._();
  factory ProductsDataSource() {
    return instance;
  }

  final _endpoint = "/products";

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> product) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, product, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllProducts() async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getPaginatedProducts(int offset) async {
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

  Future<Map<String, dynamic>?> getProductById(String productId) async {
    final uri = HttpTools.generateUri("$_endpoint/$productId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> searchProductByKeyword(String keyword) async {
    final uri = HttpTools.generateUri("$_endpoint/search/$keyword");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> searchProductInBranch(
    String textQuery,
    String branchId,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/branch/$branchId/search/$textQuery");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllProductInBranch(
    Map<String, String> queryParams,
    String branchId,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/branch/$branchId", queryParameters: queryParams);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getProductInBranchById(String productId, String branchId) async {
    final uri = HttpTools.generateUri("$_endpoint/$productId/branch/$branchId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> updateProductById(
    String productId,
    Map<String, dynamic> product,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/$productId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await patchQuery(uri, body: product, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> deleteProductById(String productId) async {
    final uri = HttpTools.generateUri("$_endpoint/$productId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await deleteQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getProductsInBranchByIds(
    String branchId,
    Map<String, dynamic> body,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/branch/$branchId/by-ids");
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, body, headers: headers);
    return res;
  }
}

