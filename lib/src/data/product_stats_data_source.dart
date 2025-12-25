import 'package:kardex_app_front/src/domain/query_params/product_stats_query.dart';
import 'package:kardex_app_front/src/services/dio_http_service.dart';
import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class ProductStatsDataSource with HttpService, DioHttpService {
  ProductStatsDataSource._();
  static final ProductStatsDataSource instance = ProductStatsDataSource._();
  factory ProductStatsDataSource() {
    return instance;
  }

  final _endpoint = "/product-stats";

  Future<Map<String, dynamic>> getAll({String? branchId}) async {
    final params = ReadProductStatQueryParams(branchId: branchId);
    final uri = HttpTools.generateUri(
      _endpoint,
      queryParameters: params.toQueryMap().map((key, value) => MapEntry(key, value.toString())),
    );
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllWithInfo({String? branchId}) async {
    final params = ReadProductStatQueryParams(branchId: branchId);
    final uri = HttpTools.generateUri(
      "$_endpoint/with-info",
      queryParameters: params.toQueryMap(),
    );
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(
      uri,
      headers: headers,
    );
    return res;
  }

  Future<void> estimate(Map<String, String> params) async {
    final uri = HttpTools.generateUri("$_endpoint/estimate");
    final headers = HttpTools.generateAuthHeaders();
    await postQuery(
      uri,
      params,
      headers: headers,
    );
  }
}
