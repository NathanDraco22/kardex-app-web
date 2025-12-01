import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';

class InvoicePayAtQueryParams {
  int offset = 0;
  int limit = 50;
  String? clientId;
  String? branchId;
  DateTime? startDate;
  DateTime? endDate;
  bool byPaidAt = false;
  InvoiceStatus? status;

  Map<String, String> toMap() {
    return {
      'offset': offset.toString(),
      'limit': limit.toString(),
      'clientId': ?clientId,
      'branchId': ?branchId,
      'startDate': ?(startDate?.millisecondsSinceEpoch.toString()),
      'endDate': ?(endDate?.millisecondsSinceEpoch.toString()),
      'byPaidAt': byPaidAt.toString(),
      'status': ?(status?.name),
    };
  }
}
