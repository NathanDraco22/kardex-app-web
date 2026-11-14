class ReceiptQueryParams {
  String? clientId;
  String? branchId;
  int? startDate;
  int? endDate;
  String? shiftId;
  int offset;
  int limit;

  ReceiptQueryParams({
    this.clientId,
    this.branchId,
    this.startDate,
    this.endDate,
    this.shiftId,
    this.offset = 0,
    this.limit = 50,
  });

  Map<String, String> toMap() {
    return {
      'clientId': ?clientId,
      'branchId': ?branchId,
      'startDate': ?startDate?.toString(),
      'endDate': ?endDate?.toString(),
      'shiftId': ?shiftId,
      'offset': offset.toString(),
      'limit': limit.toString(),
    };
  }
}
