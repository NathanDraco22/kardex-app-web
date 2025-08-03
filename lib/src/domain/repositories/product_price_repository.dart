import 'package:kardex_app_front/src/data/product_price_data_source.dart';
import 'package:kardex_app_front/src/domain/models/product_price/product_price_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ProductPricesRepository {
  final ProductPricesDataSource productPricesDataSource;

  ProductPricesRepository(this.productPricesDataSource);

  List<ProductPriceInDb> _productPrices = [];

  List<ProductPriceInDb> get productPrices => _productPrices;

  Future<ProductPriceInDb> createProductPrice(CreateProductPrice createProductPrice) async {
    final result = await productPricesDataSource.createProductPrice(createProductPrice.toJson());
    final newPrice = ProductPriceInDb.fromJson(result);
    _productPrices = [..._productPrices, newPrice];
    return newPrice;
  }

  Future<List<ProductPriceInDb>> getAllProductPrices() async {
    final results = await productPricesDataSource.getAllProductPrices();
    final response = ListResponse<ProductPriceInDb>.fromJson(
      results,
      ProductPriceInDb.fromJson,
    );

    _productPrices = response.data;
    _productPrices.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return _productPrices;
  }

  Future<ProductPriceInDb?> getProductPriceById(String priceId) async {
    final result = await productPricesDataSource.getProductPriceById(priceId);
    if (result == null) return null;
    return ProductPriceInDb.fromJson(result);
  }

  Future<List<ProductPriceInDb>> searchProductPriceByKeyword(String keyword) async {
    final result = await productPricesDataSource.searchProductPriceByKeyword(keyword);
    final response = ListResponse<ProductPriceInDb>.fromJson(
      result,
      ProductPriceInDb.fromJson,
    );
    return response.data;
  }

  Future<ProductPriceInDb?> updateProductPriceById(
    String priceId,
    UpdateProductPrice price,
  ) async {
    final result = await productPricesDataSource.updateProductPriceById(
      priceId,
      price.toJson(),
    );
    if (result == null) return null;

    final updatedPrice = ProductPriceInDb.fromJson(result);
    final index = _productPrices.indexWhere((p) => p.id == priceId);
    if (index != -1) {
      _productPrices[index] = updatedPrice;
    }
    return updatedPrice;
  }

  Future<ProductPriceInDb?> deleteProductPriceById(String priceId) async {
    final result = await productPricesDataSource.deleteProductPriceById(priceId);
    if (result == null) return null;

    final deletedPrice = ProductPriceInDb.fromJson(result);
    _productPrices.removeWhere((p) => p.id == priceId);
    return deletedPrice;
  }
}
