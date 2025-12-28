import 'package:kardex_app_front/src/domain/models/transfer/transfer_in_db.dart';
import 'package:kardex_app_front/src/services/dio_http_service.dart';
import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class TransfersDataSource with HttpService, DioHttpService {
  TransfersDataSource._();
  static final TransfersDataSource instance = TransfersDataSource._();
  factory TransfersDataSource() => instance;

  final _endpoint = "/transfers";

  Future<Map<String, dynamic>> createTransfer(CreateTransfer transfer) async {
    final uri = HttpTools.generateUri(_endpoint);

    // Convert CreateTransfer to JSON manually since it inherits and doesn't have standard toJson in BaseTransfer
    final data = {
      'origin': transfer.origin,
      'destination': transfer.destination,
      'status': transfer.status.toJson(),
      'items': transfer.items.map((e) => e.toJson()).toList(),
      'createdBy': transfer.createdBy.toJson(),
      // Optional fields if present
      if (transfer.receivedBy != null) 'receivedBy': transfer.receivedBy!.toJson(),
      if (transfer.receivedAt != null) 'receivedAt': transfer.receivedAt,
      if (transfer.cancelledBy != null) 'cancelledBy': transfer.cancelledBy!.toJson(),
      if (transfer.cancelledAt != null) 'cancelledAt': transfer.cancelledAt,
    };

    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(
      uri,
      data,
      headers: headers,
    );
    return res;
  }

  Future<Map<String, dynamic>> getAllTransfers(Map<String, String> query) async {
    final uri = HttpTools.generateUri(_endpoint, queryParameters: query);

    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(
      uri,
      headers: headers,
    );
    return res;
  }
}
