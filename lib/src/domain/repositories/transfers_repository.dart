import 'package:kardex_app_front/src/data/transfers_data_source.dart';
import 'package:kardex_app_front/src/domain/models/transfer/transfer_in_db.dart';
import 'package:kardex_app_front/src/domain/query_params/transfer_query_params.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class TransfersRepository {
  final TransfersDataSource dataSource;

  TransfersRepository(this.dataSource);

  Future<TransferInDb> createTransfer(CreateTransfer transfer) async {
    final res = await dataSource.createTransfer(transfer.toJson());

    final model = TransferInDb.fromJson(res);

    return model;
  }

  Future<List<TransferInDb>> getAllTransfers(TransferQueryParams queryParams) async {
    final res = await dataSource.getAllTransfers(queryParams.toQueryMap());

    final response = ListResponse<TransferInDb>.fromJson(res, TransferInDb.fromJson);
    return response.data;
  }

  Future<TransferInDb> receiveTransfer(String id, ReceiveTransferIntent intent) async {
    final res = await dataSource.receiveTransfer(id, intent.toJson());
    return TransferInDb.fromJson(res);
  }

  Future<TransferInDb> cancelTransfer(String id, CancelTransferIntent intent) async {
    final res = await dataSource.cancelTransfer(id, intent.toJson());
    return TransferInDb.fromJson(res);
  }

  Future<TransferInDb> getTransferById(String id) async {
    final res = await dataSource.getTransferById(id);
    return TransferInDb.fromJson(res);
  }
}
