import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ReceiptsRepository {
  final ReceiptsDataSource receiptsDataSource;

  ReceiptsRepository(this.receiptsDataSource);

  Future<ReceiptInDb> createReceipt(CreateReceipt createReceipt) async {
    final result = await receiptsDataSource.createReceipt(createReceipt.toJson());
    return ReceiptInDb.fromJson(result);
  }

  Future<List<ReceiptInDb>> getAllReceiptsByClientId(String clientId) async {
    final results = await receiptsDataSource.getAllReceiptsByClientId(clientId);
    final response = ListResponse<ReceiptInDb>.fromJson(
      results,
      ReceiptInDb.fromJson,
    );
    return response.data;
  }
}
