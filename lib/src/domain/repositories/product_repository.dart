import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/product/product_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ProductsRepository {
  final ProductsDataSource productsDataSource;

  ProductsRepository(this.productsDataSource);

  List<ProductInDb> _products = [];

  List<ProductInDb> get products => _products;

  Future<ProductInDb> createProduct(CreateProduct createProduct) async {
    final result = await productsDataSource.createProduct(createProduct.toJson());
    final newProduct = ProductInDb.fromJson(result);
    _products = [newProduct, ..._products];
    return newProduct;
  }

  Future<List<ProductInDb>> getAllProducts() async {
    final results = await productsDataSource.getAllProducts();
    final response = ListResponse<ProductInDb>.fromJson(
      results,
      ProductInDb.fromJson,
    );

    _products = response.data;
    _products.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return _products;
  }

  Future<ProductInDb?> getProductById(String productId) async {
    final result = await productsDataSource.getProductById(productId);
    if (result == null) return null;
    return ProductInDb.fromJson(result);
  }

  Future<List<ProductInDb>> searchProductByKeyword(String keyword) async {
    final result = await productsDataSource.searchProductByKeyword(keyword);
    final response = ListResponse<ProductInDb>.fromJson(
      result,
      ProductInDb.fromJson,
    );
    return response.data;
  }

  Future<ProductInDb?> updateProductById(
    String productId,
    UpdateProduct product,
  ) async {
    final result = await productsDataSource.updateProductById(
      productId,
      product.toJson(),
    );
    if (result == null) return null;

    final updatedProduct = ProductInDb.fromJson(result);
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = updatedProduct;
    }
    return updatedProduct;
  }

  Future<ProductInDb?> deleteProductById(String productId) async {
    final result = await productsDataSource.deleteProductById(productId);
    if (result == null) return null;

    final deletedProduct = ProductInDb.fromJson(result);
    _products.removeWhere((p) => p.id == productId);
    return deletedProduct;
  }
}
