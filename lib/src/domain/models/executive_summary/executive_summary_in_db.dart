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
  final int salesTotalCost;
  final int totalInvoices;
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
    required this.salesTotalCost,
    required this.totalInvoices,
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
      salesTotalCost: json['salesTotalCost'] as int,
      totalInvoices: json['totalInvoices'] as int,
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
  yearly;

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
