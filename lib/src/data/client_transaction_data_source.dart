import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class ClientTransactionsDataSource with HttpService {
  ClientTransactionsDataSource._();
  static final ClientTransactionsDataSource instance = ClientTransactionsDataSource._();
  factory ClientTransactionsDataSource() {
    return instance;
  }

  final _endpoint = "/client-transactions";

  Future<Map<String, dynamic>> getAllClientTransactions(Map<String, String> params) async {
    final uri = HttpTools.generateUri(
      _endpoint,
      queryParameters: params,
    );
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>?> getClientTransactionById(String transactionId) async {
    final uri = HttpTools.generateUri("$_endpoint/$transactionId");
    final res = await getQuery(uri);
    return res;
  }
}
