import 'package:kardex_business/src/domain/models/shift_cash_movement_model/shift_cash_movement_model.dart';

class ShiftCashMovementQueryParams {
  int offset;
  int limit;
  String? shiftId;
  String? branchId;
  CashMovementType? type;
  int? startDate;
  int? endDate;

  ShiftCashMovementQueryParams({
    this.offset = 0,
    this.limit = 100,
    this.shiftId,
    this.branchId,
    this.type,
    this.startDate,
    this.endDate,
  });

  Map<String, String> toMap() {
    return {
      'offset': offset.toString(),
      'limit': limit.toString(),
      'shiftId': ?shiftId,
      'branchId': ?branchId,
      'type': ?(type?.apiValue),
      'startDate': ?startDate?.toString(),
      'endDate': ?endDate?.toString(),
    };
  }
}
