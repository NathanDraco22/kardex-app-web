class CommercialBranchDetail {
  final String branchId;
  final int total;
  final int totalCost;
  final int totalInvoices;

  CommercialBranchDetail({
    required this.branchId,
    required this.total,
    required this.totalCost,
    required this.totalInvoices,
  });

  factory CommercialBranchDetail.fromJson(Map<String, dynamic> json) {
    return CommercialBranchDetail(
      branchId: json['branchId'] as String,
      total: json['total'] as int,
      totalCost: json['totalCost'] as int,
      totalInvoices: json['totalInvoices'] as int,
    );
  }
}

class InventoryBranchDetail {
  final String branchId;
  final int inventoryTotalCost;

  InventoryBranchDetail({
    required this.branchId,
    required this.inventoryTotalCost,
  });

  factory InventoryBranchDetail.fromJson(Map<String, dynamic> json) {
    return InventoryBranchDetail(
      branchId: json['branchId'] as String,
      inventoryTotalCost: json['inventoryTotalCost'] as int,
    );
  }
}
