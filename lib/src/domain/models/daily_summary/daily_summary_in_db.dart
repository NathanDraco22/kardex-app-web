import 'package:kardex_app_front/src/domain/models/common/branches_detail.dart';

class DailySummaryInDb {
  final String id;
  final String dateId;
  final int startDate;
  final int endDate;
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
  final List<CommercialBranchDetail> branches;
  final int createdAt;

  DailySummaryInDb({
    required this.id,
    required this.dateId,
    required this.startDate,
    required this.endDate,
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
    required this.branches,
    required this.createdAt,
  });

  factory DailySummaryInDb.fromJson(Map<String, dynamic> json) {
    return DailySummaryInDb(
      id: json['id'] as String,
      dateId: json['dateId'] as String,
      startDate: json['startDate'] as int,
      endDate: json['endDate'] as int,
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
      branches: (json['branches'] as List<dynamic>)
          .map((e) => CommercialBranchDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as int,
    );
  }
}
