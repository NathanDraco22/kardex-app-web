import 'package:kardex_app_front/src/data/client_transaction_data_source.dart';
import 'package:kardex_app_front/src/domain/models/client_transaction/client_transaction.dart';
import 'package:kardex_app_front/src/domain/query_params/client_transaction_query_params.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ClientTransactionsRepository {
  final ClientTransactionsDataSource dataSource;

  ClientTransactionsRepository(this.dataSource);

  Future<ListResponse<ClientTransactionInDb>> getAllClientTransactions(ClientTransactionQueryParams params) async {
    final results = await dataSource.getAllClientTransactions(params.toMap());
    final response = ListResponse<ClientTransactionInDb>.fromJson(
      results,
      ClientTransactionInDb.fromJson,
    );
    return response;
  }

  Future<ClientTransactionInDb?> getClientTransactionById(String transactionId) async {
    final result = await dataSource.getClientTransactionById(transactionId);
    if (result == null) return null;
    return ClientTransactionInDb.fromJson(result);
  }
}
