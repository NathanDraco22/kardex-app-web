import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class ProductPricesDataSource with HttpService {
  ProductPricesDataSource._();
  static final ProductPricesDataSource instance = ProductPricesDataSource._();
  factory ProductPricesDataSource() {
    return instance;
  }

  final _endpoint = "/product-prices";

  Future<Map<String, dynamic>> createProductPrice(Map<String, dynamic> productPrice) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, productPrice, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllProductPrices() async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> getProductPriceById(String productPriceId) async {
    final uri = HttpTools.generateUri("$_endpoint/$productPriceId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> searchProductPriceByKeyword(String keyword) async {
    final uri = HttpTools.generateUri("$_endpoint/search/$keyword");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> updateProductPriceById(
    String productPriceId,
    Map<String, dynamic> productPrice,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/$productPriceId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await patchQuery(uri, body: productPrice, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> deleteProductPriceById(String productPriceId) async {
    final uri = HttpTools.generateUri("$_endpoint/$productPriceId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await deleteQuery(uri, headers: headers);
    return res;
  }
}
