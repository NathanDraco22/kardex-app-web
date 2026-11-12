class AdjustmentRequestQueryParams {
  int offset;
  int limit;
  String? branchId;
  /// Use the `name` of an `AdjustmentRequestStatus` value as the query value.
  String? status;
  String? createdBy;
  String? docNumber;
  int? startDate;
  int? endDate;

  AdjustmentRequestQueryParams({
    this.offset = 0,
    this.limit = 50,
    this.branchId,
    this.status,
    this.createdBy,
    this.docNumber,
    this.startDate,
    this.endDate,
  });

  Map<String, String> toMap() {
    final data = <String, dynamic>{
      'offset': offset.toString(),
      'limit': limit.toString(),
      'branchId': branchId,
      'status': status,
      'createdBy': createdBy,
      'docNumber': docNumber,
      'startDate': startDate?.toString(),
      'endDate': endDate?.toString(),
    };

    data.removeWhere((_, value) => value == null);

    return data.cast<String, String>();
  }
}
