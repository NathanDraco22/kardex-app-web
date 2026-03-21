class CommercialBranchDetail {
  final String branchId;
  final int total;
  final int totalCost;
  final int totalPaid;
  final int totalOwed;
  final int creditSales;
  final int cashSales;
  final int totalInvoices;
  final int totalReceiptCash;
  final int totalReceiptDevolutions;
  final int totalReceipts;
  final int receiptCount;

  CommercialBranchDetail({
    required this.branchId,
    required this.total,
    required this.totalCost,
    required this.totalPaid,
    required this.totalOwed,
    required this.creditSales,
    required this.cashSales,
    required this.totalInvoices,
    required this.totalReceiptCash,
    required this.totalReceiptDevolutions,
    required this.totalReceipts,
    required this.receiptCount,
  });

  factory CommercialBranchDetail.fromJson(Map<String, dynamic> json) {
    return CommercialBranchDetail(
      branchId: json['branchId'] as String,
      total: json['total'] as int,
      totalCost: json['totalCost'] as int,
      totalPaid: (json['totalPaid'] as int?) ?? 0,
      totalOwed: (json['totalOwed'] as int?) ?? 0,
      creditSales: (json['creditSales'] as int?) ?? 0,
      cashSales: (json['cashSales'] as int?) ?? 0,
      totalInvoices: json['totalInvoices'] as int,
      totalReceiptCash: (json['totalReceiptCash'] as int?) ?? 0,
      totalReceiptDevolutions: (json['totalReceiptDevolutions'] as int?) ?? 0,
      totalReceipts: (json['totalReceipts'] as int?) ?? 0,
      receiptCount: (json['receiptCount'] as int?) ?? 0,
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

class PendingInvoiceTotalsByBranch {
  final String branchId;
  final int total;
  final int totalCost;
  final int amountPaid;
  final int totalOwed;
  final int count;

  PendingInvoiceTotalsByBranch({
    required this.branchId,
    required this.total,
    required this.totalCost,
    required this.amountPaid,
    required this.totalOwed,
    required this.count,
  });

  factory PendingInvoiceTotalsByBranch.fromJson(Map<String, dynamic> json) {
    return PendingInvoiceTotalsByBranch(
      branchId: json['branchId'] as String,
      total: json['total'] as int,
      totalCost: json['totalCost'] as int,
      amountPaid: json['amountPaid'] as int,
      totalOwed: json['totalOwed'] as int,
      count: json['count'] as int,
    );
  }
}
