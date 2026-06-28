class InvoiceQueryParams {
  int offset = 0;
  int limit = 50;
  String? clientId;
  String? branchId;
  DateTime? startDate;
  DateTime? endDate;
  String? createdBy;

  Map<String, String> toMap() {
    final map = {
      'clientId': ?clientId,
      'branchId': ?branchId,
      'startDate': ?startDate?.millisecondsSinceEpoch.toString(),
      'endDate': ?endDate?.millisecondsSinceEpoch.toString(),
      'offset': offset.toString(),
      'limit': limit.toString(),
      'createdBy': ?createdBy,
    };
    return map;
  }
}
