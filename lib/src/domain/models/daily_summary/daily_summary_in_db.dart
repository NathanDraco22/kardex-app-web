import 'package:kardex_app_front/src/domain/models/common/branches_detail.dart';

class DailySummaryInDb {
  final String id;
  final String dateId;
  final int startDate;
  final int endDate;
  final int total;
  final int totalCost;
  final int totalInvoices;
  final List<CommercialBranchDetail> branches;
  final int createdAt;

  DailySummaryInDb({
    required this.id,
    required this.dateId,
    required this.startDate,
    required this.endDate,
    required this.total,
    required this.totalCost,
    required this.totalInvoices,
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
      totalInvoices: json['totalInvoices'] as int,
      branches: (json['branches'] as List<dynamic>)
          .map((e) => CommercialBranchDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as int,
    );
  }
}
