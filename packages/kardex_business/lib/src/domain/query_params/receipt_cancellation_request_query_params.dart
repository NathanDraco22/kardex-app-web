class ReceiptCancellationRequestQueryParams {
  int offset;
  int limit;
  String? branchId;
  String? status;
  String? receiptId;
  String? requestedById;
  int? startDate;
  int? endDate;

  ReceiptCancellationRequestQueryParams({
    this.offset = 0,
    this.limit = 50,
    this.branchId,
    this.status,
    this.receiptId,
    this.requestedById,
    this.startDate,
    this.endDate,
  });

  Map<String, String> toMap() {
    final data = <String, dynamic>{
      'offset': offset.toString(),
      'limit': limit.toString(),
      'branchId': branchId,
      'status': status,
      'receiptId': receiptId,
      'requestedById': requestedById,
      'startDate': startDate?.toString(),
      'endDate': endDate?.toString(),
    };

    data.removeWhere((_, value) => value == null);
    return data.cast<String, String>();
  }
}
