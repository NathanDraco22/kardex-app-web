class ProductQueryParams {
  final int offset;
  final int limit;
  final String? branchId;

  ProductQueryParams({
    required this.offset,
    required this.limit,
    this.branchId,
  });

  Map<String, String> toQueryParameters() {
    return {
      "offset": offset.toString(),
      "limit": limit.toString(),
      if (branchId != null) "branchId": branchId!,
    };
  }
}
