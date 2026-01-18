import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_model.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_total.dart';
import 'package:kardex_app_front/src/domain/query_params/history_params.dart';
import 'package:kardex_app_front/src/domain/query_params/receipt_query_params.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ReceiptsRepository {
  final ReceiptsDataSource receiptsDataSource;

  ReceiptsRepository(this.receiptsDataSource);

  Future<ReceiptInDb> createReceipt(CreateReceipt createReceipt) async {
    final result = await receiptsDataSource.createReceipt(createReceipt.toJson());
    return ReceiptInDb.fromJson(result);
  }

  Future<ListResponse<ReceiptInDb>> getAllReceipts(ReceiptQueryParams queryParams) async {
    final results = await receiptsDataSource.getAllReceipts(queryParams.toMap());
    final response = ListResponse<ReceiptInDb>.fromJson(
      results,
      ReceiptInDb.fromJson,
    );
    return response;
  }

  Future<ListResponse<ReceiptInDb>> getAllReceiptsByInvoiceId(String invoiceId) async {
    final results = await receiptsDataSource.getReceiptsByInvoiceId(invoiceId);
    final response = ListResponse<ReceiptInDb>.fromJson(
      results,
      ReceiptInDb.fromJson,
    );
    return response;
  }

  Future<ReceiptTotal> getReceiptTotal(ReceiptQueryParams queryParams) async {
    final results = await receiptsDataSource.getReceiptTotal(queryParams.toMap());
    return ReceiptTotal.fromJson(results);
  }

  Future<ReceiptInDb> getReceiptByDocNumber(String docNumber) async {
    final results = await receiptsDataSource.getReceiptByDocNumber(docNumber);
    return ReceiptInDb.fromJson(results);
  }

  Future<List<ReceiptInDb>> getReceiptHistory(InvoiceQueryParams queryParams) async {
    final results = await receiptsDataSource.getReceiptHistory(queryParams.toMap());
    final response = ListResponse<ReceiptInDb>.fromJson(
      results,
      ReceiptInDb.fromJson,
    );
    return response.data;
  }
}
