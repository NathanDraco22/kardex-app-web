import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/product/product_model.dart';
import 'package:kardex_app_front/src/domain/query_params/product_query_params.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ProductsRepository {
  final ProductsDataSource productsDataSource;

  ProductsRepository(this.productsDataSource);

  Future<ProductInDb> createProduct(CreateProduct createProduct) async {
    final result = await productsDataSource.createProduct(createProduct.toJson());
    final newProduct = ProductInDb.fromJson(result);
    return newProduct;
  }

  Future<List<ProductInDb>> getPaginatedProducts(int offset) async {
    final results = await productsDataSource.getPaginatedProducts(offset);
    final response = ListResponse.fromJson(results, ProductInDb.fromJson);
    return response.data;
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

  Future<List<ProductInDbInBranch>> getAllProductsInBranch(ProductQueryParams queryParams) async {
    final results = await productsDataSource.getAllProductInBranch(queryParams.toQueryParameters());
    final response = ListResponse<ProductInDbInBranch>.fromJson(
      results,
      ProductInDbInBranch.fromJson,
    );
    return response.data;
  }

  Future<ProductInDbInBranch> getProductInBranchById(String productId) async {
    final result = await productsDataSource.getProductInBranchById(productId);
    return ProductInDbInBranch.fromJson(result);
  }

  Future<List<ProductInDbInBranch>> searchProductInBranch(String keyword) async {
    final result = await productsDataSource.searchProductInBranch(keyword);
    final response = ListResponse<ProductInDbInBranch>.fromJson(
      result,
      ProductInDbInBranch.fromJson,
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

    return updatedProduct;
  }

  Future<ProductInDb?> deleteProductById(String productId) async {
    final result = await productsDataSource.deleteProductById(productId);
    if (result == null) return null;

    final deletedProduct = ProductInDb.fromJson(result);
    return deletedProduct;
  }
}
