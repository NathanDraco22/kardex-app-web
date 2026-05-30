import 'package:kardex_app_front/src/data/product_sale_profile_data_source.dart';
import 'package:kardex_app_front/src/domain/models/product_sale_profile/product_sale_profile_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ProductSaleProfilesRepository {
  final ProductSaleProfilesDataSource productSaleProfilesDataSource;

  ProductSaleProfilesRepository(this.productSaleProfilesDataSource);

  Future<ProductSaleProfileInDb> createProductSaleProfile(
    CreateProductSaleProfile profile,
  ) async {
    final result = await productSaleProfilesDataSource.createProductSaleProfile(profile.toJson());
    return ProductSaleProfileInDb.fromJson(result);
  }

  Future<List<ProductSaleProfileInDbWithProduct>> getAllProductSaleProfilesCurrentBranch(String branchId) async {
    final results = await productSaleProfilesDataSource.getAllProductSaleProfilesCurrentBranch(branchId);
    final response = ListResponse<ProductSaleProfileInDbWithProduct>.fromJson(
      results,
      ProductSaleProfileInDbWithProduct.fromJson,
    );
    return response.data;
  }

  Future<ProductSaleProfileInDbWithProduct?> getProductSaleProfileByProductId(String productId, String branchId) async {
    final result = await productSaleProfilesDataSource.getProductSaleProfileByProductId(productId, branchId);
    if (result == null) return null;
    return ProductSaleProfileInDbWithProduct.fromJson(result);
  }

  Future<ProductSaleProfileInDb?> updateProductSaleProfileByProductId(
    String productId,
    UpdateProductSaleProfile profile,
    String branchId,
  ) async {
    final result = await productSaleProfilesDataSource.updateProductSaleProfileByProductId(
      productId,
      profile.toJson(),
      branchId,
    );
    if (result == null) return null;
    return ProductSaleProfileInDb.fromJson(result);
  }
}
