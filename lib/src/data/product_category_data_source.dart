import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class ProductCategoriesDataSource with HttpService {
  ProductCategoriesDataSource._();
  static final ProductCategoriesDataSource instance = ProductCategoriesDataSource._();
  factory ProductCategoriesDataSource() {
    return instance;
  }

  final _endpoint = "/product-categories";

  Future<Map<String, dynamic>> createProductCategory(Map<String, dynamic> productCategory) async {
    final uri = HttpTools.generateUri(_endpoint);
    final res = await postQuery(uri, productCategory);
    return res;
  }

  Future<Map<String, dynamic>> getAllProductCategories() async {
    final uri = HttpTools.generateUri(_endpoint);
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>?> getProductCategoryById(String productCategoryId) async {
    final uri = HttpTools.generateUri("$_endpoint/$productCategoryId");
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>> searchProductCategoryByKeyword(String keyword) async {
    final uri = HttpTools.generateUri("$_endpoint/search/$keyword");
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>?> updateProductCategoryById(
    String productCategoryId,
    Map<String, dynamic> productCategory,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/$productCategoryId");
    final res = await patchQuery(uri, body: productCategory);
    return res;
  }

  Future<Map<String, dynamic>?> deleteProductCategoryById(String productCategoryId) async {
    final uri = HttpTools.generateUri("$_endpoint/$productCategoryId");
    final res = await deleteQuery(uri);
    return res;
  }
}
