import 'package:kardex_business/src/domain/models/shift_model/shift_model.dart';

class ShiftQueryParams {
  int offset;
  int limit;
  String? branchId;
  String? userId;
  ShiftStatus? status;
  int? startDate;
  int? endDate;

  ShiftQueryParams({
    this.offset = 0,
    this.limit = 50,
    this.branchId,
    this.userId,
    this.status,
    this.startDate,
    this.endDate,
  });

  Map<String, String> toMap() {
    return {
      'offset': offset.toString(),
      'limit': limit.toString(),
      'branchId': ?branchId,
      'userId': ?userId,
      'status': ?(status?.name),
      'startDate': ?startDate?.toString(),
      'endDate': ?endDate?.toString(),
    };
  }
}
