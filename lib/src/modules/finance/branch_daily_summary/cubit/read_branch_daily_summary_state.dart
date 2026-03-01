part of 'read_branch_daily_summary_cubit.dart';

sealed class ReadBranchDailySummaryState {}

final class ReadBranchDailySummaryInitial extends ReadBranchDailySummaryState {}

final class ReadBranchDailySummaryLoading extends ReadBranchDailySummaryState {}

class ReadBranchDailySummarySuccess extends ReadBranchDailySummaryState {
  final List<BranchDailySummary> summaries;

  ReadBranchDailySummarySuccess({required this.summaries});
}

final class ReadBranchDailySummaryFetchingMore extends ReadBranchDailySummarySuccess {
  ReadBranchDailySummaryFetchingMore({required super.summaries});
}

final class ReadBranchDailySummaryErrorPagination extends ReadBranchDailySummarySuccess {
  final String message;

  ReadBranchDailySummaryErrorPagination({
    required this.message,
    required super.summaries,
  });
}

final class ReadBranchDailySummaryFailure extends ReadBranchDailySummaryState {
  final String message;

  ReadBranchDailySummaryFailure({required this.message});
}

class BranchDailySummary {
  final int startDate;
  final CommercialBranchDetail detail;

  BranchDailySummary({
    required this.startDate,
    required this.detail,
  });
}
