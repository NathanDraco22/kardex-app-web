import 'package:kardex_app_front/src/data/product_accounts_data_source.dart';
import 'package:kardex_app_front/src/domain/models/product_account/product_account.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ProductAccountsRepository {
  final ProductAccountsDataSource dataSource;

  ProductAccountsRepository(this.dataSource);

  Future<List<ProductAccountInDb>> getProductAccountsByProduct(String productId) async {
    final res = await dataSource.getProductAccountsByProduct(productId);
    final response = ListResponse<ProductAccountInDb>.fromJson(res, ProductAccountInDb.fromJson);
    return response.data;
  }

  Future<ProductAccountInDb> addProductAccount(String productId, String branchId, {required int currentStock, required int averageCost}) async {
    final res = await dataSource.addProductAccount(productId, branchId, {
      "currentStock": currentStock,
      "averageCost": averageCost,
    });
    return ProductAccountInDb.fromJson(res);
  }

  Future<ProductAccountInDb> substractProductAccount(String productId, String branchId, {required int currentStock}) async {
    final res = await dataSource.substractProductAccount(productId, branchId, {
      "currentStock": currentStock,
    });
    return ProductAccountInDb.fromJson(res);
  }
}
