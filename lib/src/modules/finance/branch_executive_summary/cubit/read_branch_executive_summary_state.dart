part of 'read_branch_executive_summary_cubit.dart';

sealed class ReadBranchExecutiveSummaryState {}

final class ReadBranchExecutiveSummaryInitial extends ReadBranchExecutiveSummaryState {}

final class ReadBranchExecutiveSummaryLoading extends ReadBranchExecutiveSummaryState {}

class ReadBranchExecutiveSummarySuccess extends ReadBranchExecutiveSummaryState {
  final List<BranchExecutiveSummary> summaries;

  ReadBranchExecutiveSummarySuccess({required this.summaries});
}

final class ReadBranchExecutiveSummaryFetchingMore extends ReadBranchExecutiveSummarySuccess {
  ReadBranchExecutiveSummaryFetchingMore({required super.summaries});
}

final class ReadBranchExecutiveSummaryErrorPagination extends ReadBranchExecutiveSummarySuccess {
  final String message;

  ReadBranchExecutiveSummaryErrorPagination({
    required this.message,
    required super.summaries,
  });
}

final class ReadBranchExecutiveSummaryFailure extends ReadBranchExecutiveSummaryState {
  final String message;

  ReadBranchExecutiveSummaryFailure({required this.message});
}

class BranchExecutiveSummary {
  final int startDate;
  final int year;
  final int month;
  final SummaryType type;
  final CommercialBranchDetail commercialDetail;
  final InventoryBranchDetail? inventoryDetail;

  BranchExecutiveSummary({
    required this.startDate,
    required this.year,
    required this.month,
    required this.type,
    required this.commercialDetail,
    this.inventoryDetail,
  });
}
