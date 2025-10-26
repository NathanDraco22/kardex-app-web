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
      if (branchId != null) 'branchId': branchId!,
      if (productId != null) 'productId': productId!,
      if (endDate != null) 'endDate': endDate!.toString(),
      if (type != null) 'type': type!,
      if (subtype != null) 'subtype': subtype!,
      'offset': offset.toString(),
      'limit': limit.toString(),
    };
  }
}
