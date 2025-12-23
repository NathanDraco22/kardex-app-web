class DailySummaryQueryParams {
  int offset;
  int limit;
  String? dateId;
  int? startDate;
  int? endDate;

  DailySummaryQueryParams({
    this.offset = 0,
    this.limit = 50,
    this.dateId,
    this.startDate,
    this.endDate,
  });

  Map<String, String> toQueryParams() {
    return {
      'offset': offset.toString(),
      'limit': limit.toString(),
      if (dateId != null) 'dateId': dateId!,
      if (startDate != null) 'startDate': startDate.toString(),
      if (endDate != null) 'endDate': endDate.toString(),
    };
  }
}
