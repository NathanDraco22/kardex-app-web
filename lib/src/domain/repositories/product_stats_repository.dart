import 'package:kardex_app_front/src/data/product_stats_data_source.dart';
import 'package:kardex_app_front/src/domain/models/product_stat/product_stat_in_db.dart';
import 'package:kardex_app_front/src/domain/query_params/product_stats_query.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ProductStatsRepository {
  final ProductStatsDataSource dataSource;

  ProductStatsRepository(this.dataSource);

  Future<List<ProductStatInDb>> getAll({String? branchId}) async {
    final res = await dataSource.getAll(branchId: branchId);
    final response = ListResponse<ProductStatInDb>.fromJson(res, ProductStatInDb.fromJson);
    return response.data;
  }

  Future<List<ProductStatInDbWithInfo>> getAllWithInfo({String? branchId}) async {
    final res = await dataSource.getAllWithInfo(branchId: branchId);
    final response = ListResponse<ProductStatInDbWithInfo>.fromJson(res, ProductStatInDbWithInfo.fromJson);
    return response.data;
  }

  Future<List<ProductStatInDbWithAccount>> getAllWithAccount({String? branchId}) async {
    final res = await dataSource.getAllWithAccount(branchId: branchId);
    final response = ListResponse<ProductStatInDbWithAccount>.fromJson(res, ProductStatInDbWithAccount.fromJson);
    return response.data;
  }

  Future<void> generateExcel(int projectionDays) async {
    await dataSource.generateExcel(projectionDays);
  }

  Future<void> estimate(ProductStatQueryParams params) async {
    await dataSource.estimate(params.toQueryMap());
  }
}
