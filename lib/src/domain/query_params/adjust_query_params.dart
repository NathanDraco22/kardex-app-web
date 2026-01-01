class AdjustQueryParams {
  final int offset;
  final int limit;
  final String? branchId;
  final int? endDate;

  const AdjustQueryParams({
    this.offset = 0,
    this.limit = 50,
    this.branchId,
    this.endDate,
  });

  AdjustQueryParams copyWith({
    int? offset,
    int? limit,
    String? branchId,
    int? endDate,
  }) {
    return AdjustQueryParams(
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      branchId: branchId ?? this.branchId,
      endDate: endDate ?? this.endDate,
    );
  }

  Map<String, String> toMap() {
    return {
      'offset': offset.toString(),
      'limit': limit.toString(),
      'branchId': ?branchId,
      'endDate': endDate.toString(),
    };
  }

  factory AdjustQueryParams.fromMap(Map<String, dynamic> map) {
    return AdjustQueryParams(
      offset: map['offset'] ?? 0,
      limit: map['limit'] ?? 50,
      branchId: map['branchId'],
      endDate: map['endDate'],
    );
  }
}
