import 'package:kardex_app_front/src/domain/models/order/order_model.dart';

class OrderQueryParams {
  final int skip;
  final int limit;
  final OrderStatus? status;
  final OrderStatus? neStatus;
  final String? clientId;
  final String? branchId;
  final int? startDate;
  final int? endDate;
  String? createdBy;

  OrderQueryParams({
    this.skip = 0,
    this.limit = 50,
    this.status,
    this.neStatus,
    this.clientId,
    this.branchId,
    this.startDate,
    this.endDate,
  });

  Map<String, String> toQueryParameters() {
    return {
      "skip": skip.toString(),
      "limit": limit.toString(),
      "status": ?status?.name,
      "neStatus": ?neStatus?.name,
      "clientId": ?clientId,
      "branchId": ?branchId,
      "startDate": ?startDate?.toString(),
      "endDate": ?endDate?.toString(),
    };
  }
}
