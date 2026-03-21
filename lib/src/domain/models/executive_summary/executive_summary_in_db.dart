import 'package:kardex_app_front/src/domain/models/common/branches_detail.dart';

final class ExecutiveSummaryInDb {
  final String id;
  final String dateId;
  final SummaryType type;
  final int year;
  final int month;
  final int startDate;
  final int endDate;
  final int salesTotal;
  final int creditSales;
  final int cashSales;
  final int salesTotalCost;
  final int totalInvoices;
  final int totalPendingInvoices;
  final List<PendingInvoiceTotalsByBranch> totalPendingBranches;
  final int totalReceiptCash;
  final int totalReceiptDevolutions;
  final int totalReceipts;
  final int receiptCount;
  final List<CommercialBranchDetail> commercialBranches;
  final int inventoryTotalCost;
  final List<InventoryBranchDetail> inventoryBranches;
  final int createdAt;

  ExecutiveSummaryInDb({
    required this.id,
    required this.dateId,
    required this.type,
    required this.year,
    required this.month,
    required this.startDate,
    required this.endDate,
    required this.salesTotal,
    required this.creditSales,
    required this.cashSales,
    required this.salesTotalCost,
    required this.totalInvoices,
    required this.totalPendingInvoices,
    required this.totalPendingBranches,
    required this.totalReceiptCash,
    required this.totalReceiptDevolutions,
    required this.totalReceipts,
    required this.receiptCount,
    required this.commercialBranches,
    required this.inventoryTotalCost,
    required this.inventoryBranches,
    required this.createdAt,
  });

  factory ExecutiveSummaryInDb.fromJson(Map<String, dynamic> json) {
    return ExecutiveSummaryInDb(
      id: json['id'] as String,
      dateId: json['dateId'] as String,
      type: SummaryType.values.byName(json['type'] as String),
      year: json['year'] as int,
      month: json['month'] as int,
      startDate: json['startDate'] as int,
      endDate: json['endDate'] as int,
      salesTotal: json['salesTotal'] as int,
      creditSales: (json['creditSales'] as int?) ?? 0,
      cashSales: (json['cashSales'] as int?) ?? 0,
      salesTotalCost: json['salesTotalCost'] as int,
      totalInvoices: json['totalInvoices'] as int,
      totalPendingInvoices: (json['totalPendingInvoices'] as int?) ?? 0,
      totalPendingBranches: (json['totalPendingBranches'] as List<dynamic>?)
              ?.map((e) => PendingInvoiceTotalsByBranch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalReceiptCash: (json['totalReceiptCash'] as int?) ?? 0,
      totalReceiptDevolutions: (json['totalReceiptDevolutions'] as int?) ?? 0,
      totalReceipts: (json['totalReceipts'] as int?) ?? 0,
      receiptCount: (json['receiptCount'] as int?) ?? 0,
      commercialBranches: (json['commercialBranches'] as List<dynamic>)
          .map((e) => CommercialBranchDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      inventoryTotalCost: json['inventoryTotalCost'] as int,
      inventoryBranches: (json['inventoryBranches'] as List<dynamic>)
          .map((e) => InventoryBranchDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as int,
    );
  }
}

enum SummaryType {
  weekly,
  monthly,
  yearly
  ;

  String get label {
    switch (this) {
      case SummaryType.weekly:
        return "Semanal";
      case SummaryType.monthly:
        return "Mensual";
      case SummaryType.yearly:
        return "Anual";
    }
  }
}
