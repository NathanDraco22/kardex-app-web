class HoldSaleFilterParams {
  int offset = 0;
  int limit = 50;
  String? branchId;
  String? createdBy;
  DateTime? startDate;
  DateTime? endDate;
  String? search;

  HoldSaleFilterParams({
    this.offset = 0,
    this.limit = 50,
    this.branchId,
    this.createdBy,
    this.startDate,
    this.endDate,
    this.search,
  });

  Map<String, String> toMap() {
    final map = {
      'branchId': ?branchId,
      'createdBy': ?createdBy,
      'startDate': ?startDate?.millisecondsSinceEpoch.toString(),
      'endDate': ?endDate?.millisecondsSinceEpoch.toString(),
      'search': ?search,
      'offset': offset.toString(),
      'limit': limit.toString(),
    };
    return map;
  }

  Map<String, String> toQueryParameters() => toMap();
}
