class ExpenseQueryParams {
  int offset = 0;
  int limit = 50;
  String? status;
  int? startDate;
  int? endDate;
  String? createdBy;
  String? branchId;
  String? category;
  String? docNumber;
  int? minAmount;
  int? maxAmount;

  Map<String, String> toMap() {
    return {
      'offset': offset.toString(),
      'limit': limit.toString(),
      'status': ?status,
      'startDate': ?startDate?.toString(),
      'endDate': ?endDate?.toString(),
      'createdBy': ?createdBy,
      'branchId': ?branchId,
      'category': ?category,
      'docNumber': ?docNumber,
      'minAmount': ?minAmount?.toString(),
      'maxAmount': ?maxAmount?.toString(),
    };
  }
}
