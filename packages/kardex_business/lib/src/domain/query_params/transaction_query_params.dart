class TransactionQueryParams {
  String? branchId;
  String? productId;
  int? endDate;
  String? type;
  String? subtype;
  int offset;
  int limit;

  TransactionQueryParams({
    this.branchId,
    this.productId,
    this.endDate,
    this.type,
    this.subtype,
    this.offset = 0,
    this.limit = 50,
  });

  Map<String, String> toMap() {
    return {
      'branchId': ?branchId,
      'productId': ?productId,
      'endDate': ?endDate?.toString(),
      'type': ?type,
      'subtype': ?subtype,
      'offset': offset.toString(),
      'limit': limit.toString(),
    };
  }
}
