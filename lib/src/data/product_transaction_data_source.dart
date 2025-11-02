import 'package:kardex_app_front/src/domain/query_params/transaction_query_params.dart';
import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class ProductTransactionsDataSource with HttpService {
  ProductTransactionsDataSource._();
  static final ProductTransactionsDataSource instance = ProductTransactionsDataSource._();
  factory ProductTransactionsDataSource() {
    return instance;
  }

  final _endpoint = "/product-transactions";

  Future<Map<String, dynamic>> getAllProductTransactions(TransactionQueryParams queryParams) async {
    final uri = HttpTools.generateUri(
      _endpoint,
      queryParameters: queryParams.toMap(),
    );
    final header = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: header);
    return res;
  }
}
