import 'package:kardex_business/src/data/product_accounts_data_source.dart';
import 'package:kardex_business/src/domain/models/product_account/product_account.dart';
import 'package:kardex_business/src/domain/responses/list_responses.dart';

class ProductAccountsRepository {
  final ProductAccountsDataSource dataSource;

  ProductAccountsRepository(this.dataSource);

  Future<List<ProductAccountInDb>> getProductAccountsByProduct(String productId) async {
    final res = await dataSource.getProductAccountsByProduct(productId);
    final response = ListResponse<ProductAccountInDb>.fromJson(res, ProductAccountInDb.fromJson);
    return response.data;
  }
}
