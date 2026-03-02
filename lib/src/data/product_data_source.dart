import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
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
  ) async {
    final currentBranch = BranchesTool.getCurrentBranchId();
    final uri = HttpTools.generateUri("$_endpoint/branch/$currentBranch/search/$textQuery");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllProductInBranch(
    Map<String, String> queryParams,
  ) async {
    final currentBranch = BranchesTool.getCurrentBranchId();
    final uri = HttpTools.generateUri("$_endpoint/branch/$currentBranch", queryParameters: queryParams);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getProductInBranchById(String productId) async {
    final currentBranch = BranchesTool.getCurrentBranchId();
    final uri = HttpTools.generateUri("$_endpoint/$productId/branch/$currentBranch");
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
}
