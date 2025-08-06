import 'package:kardex_app_front/src/services/http_service.dart';
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
    final res = await postQuery(uri, product);
    return res;
  }

  Future<Map<String, dynamic>> getAllProducts() async {
    final uri = HttpTools.generateUri(_endpoint);
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>?> getProductById(String productId) async {
    final uri = HttpTools.generateUri("$_endpoint/$productId");
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>> searchProductByKeyword(String keyword) async {
    final uri = HttpTools.generateUri("$_endpoint/search/$keyword");
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>?> updateProductById(
    String productId,
    Map<String, dynamic> product,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/$productId");
    final res = await patchQuery(uri, body: product);
    return res;
  }

  Future<Map<String, dynamic>?> deleteProductById(String productId) async {
    final uri = HttpTools.generateUri("$_endpoint/$productId");
    final res = await deleteQuery(uri);
    return res;
  }
}
