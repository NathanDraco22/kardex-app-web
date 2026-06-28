class ReceiptQueryParams {
  String? clientId;
  String? branchId;
  int? startDate;
  int? endDate;
  int offset;
  int limit;

  ReceiptQueryParams({
    this.clientId,
    this.branchId,
    this.startDate,
    this.endDate,
    this.offset = 0,
    this.limit = 50,
  });

  Map<String, String> toMap() {
    return {
      'clientId': ?clientId,
      'branchId': ?branchId,
      'startDate': ?startDate?.toString(),
      'endDate': ?endDate?.toString(),
      'offset': offset.toString(),
      'limit': limit.toString(),
    };
  }
}
