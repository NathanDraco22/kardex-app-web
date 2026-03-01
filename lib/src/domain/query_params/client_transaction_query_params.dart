import 'package:kardex_app_front/src/domain/models/client_transaction/client_transaction.dart';

class ClientTransactionQueryParams {
  String? branchId;
  String? clientId;
  int? endDate;
  int? startDate;
  TransactionType? type;
  TransactionSubType? subtype;
  int offset;
  int limit;

  ClientTransactionQueryParams({
    this.branchId,
    this.clientId,
    this.endDate,
    this.startDate,
    this.type,
    this.subtype,
    this.offset = 0,
    this.limit = 50,
  });

  Map<String, String> toMap() {
    return {
      if (branchId != null) 'branchId': branchId!,
      if (clientId != null) 'clientId': clientId!,
      if (endDate != null) 'endDate': endDate!.toString(),
      if (startDate != null) 'startDate': startDate!.toString(),
      if (type != null) 'type': type!.name,
      if (subtype != null) 'subtype': subtype!.name,
      'offset': offset.toString(),
      'limit': limit.toString(),
    };
  }
}
