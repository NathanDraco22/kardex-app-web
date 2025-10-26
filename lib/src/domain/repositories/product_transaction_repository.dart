import 'package:kardex_app_front/src/data/product_transaction_data_source.dart';
import 'package:kardex_app_front/src/domain/models/product_transaction/product_transaction.dart';
import 'package:kardex_app_front/src/domain/query_params/transaction_query_params.dart';

import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ProductTransactionsRepository {
  final ProductTransactionsDataSource transactionsDataSource;

  ProductTransactionsRepository(this.transactionsDataSource);

  Future<ListResponse<ProductTransactionInDb>> getAllProductTransactions(TransactionQueryParams queryParams) async {
    final results = await transactionsDataSource.getAllProductTransactions(queryParams);
    final response = ListResponse<ProductTransactionInDb>.fromJson(
      results,
      ProductTransactionInDb.fromJson,
    );
    return response;
  }
}
