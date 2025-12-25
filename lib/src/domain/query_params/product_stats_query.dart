class ProductStatQueryParams {
  final int startDate;
  final int endDate;
  final int daysAnalysis;

  ProductStatQueryParams({
    required this.startDate,
    required this.endDate,
    required this.daysAnalysis,
  });

  Map<String, String> toQueryMap() {
    return {
      'startDate': startDate.toString(),
      'endDate': endDate.toString(),
      'daysAnalysis': daysAnalysis.toString(),
    };
  }
}

class ReadProductStatQueryParams {
  final String? branchId;

  ReadProductStatQueryParams({
    this.branchId,
  });

  Map<String, String> toQueryMap() {
    return {
      if (branchId != null) 'branchId': branchId!,
    };
  }
}
