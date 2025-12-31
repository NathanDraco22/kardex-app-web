class AdjustQueryParams {
  final int offset;
  final int limit;
  final String? branchId;

  const AdjustQueryParams({
    this.offset = 0,
    this.limit = 50,
    this.branchId,
  });

  AdjustQueryParams copyWith({
    int? offset,
    int? limit,
    String? branchId,
  }) {
    return AdjustQueryParams(
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      branchId: branchId ?? this.branchId,
    );
  }

  Map<String, String> toMap() {
    return {
      'offset': offset.toString(),
      'limit': limit.toString(),
      'branchId': ?branchId,
    };
  }

  factory AdjustQueryParams.fromMap(Map<String, dynamic> map) {
    return AdjustQueryParams(
      offset: map['offset'] ?? 0,
      limit: map['limit'] ?? 50,
      branchId: map['branchId'],
    );
  }
}
