class ResetInventoryResult {
  final String message;
  final String branchId;
  final String docNumber;
  final String adjustExitId;
  final int adjustedProductsCount;
  final int totalQuantityRemoved;

  const ResetInventoryResult({
    required this.message,
    required this.branchId,
    required this.docNumber,
    required this.adjustExitId,
    required this.adjustedProductsCount,
    required this.totalQuantityRemoved,
  });

  factory ResetInventoryResult.fromJson(Map<String, dynamic> json) {
    return ResetInventoryResult(
      message: json['message'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      docNumber: json['docNumber'] as String? ?? '',
      adjustExitId: json['adjustExitId'] as String? ?? '',
      adjustedProductsCount: json['adjustedProductsCount'] as int? ?? 0,
      totalQuantityRemoved: json['totalQuantityRemoved'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'branchId': branchId,
      'docNumber': docNumber,
      'adjustExitId': adjustExitId,
      'adjustedProductsCount': adjustedProductsCount,
      'totalQuantityRemoved': totalQuantityRemoved,
    };
  }
}
