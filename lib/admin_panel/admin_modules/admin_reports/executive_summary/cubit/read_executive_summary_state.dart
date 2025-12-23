part of 'read_executive_summary_cubit.dart';

sealed class ReadExecutiveSummaryState {}

final class ReadExecutiveSummaryInitial extends ReadExecutiveSummaryState {}

final class ReadExecutiveSummaryLoading extends ReadExecutiveSummaryState {}

class ReadExecutiveSummarySuccess extends ReadExecutiveSummaryState {
  final List<ExecutiveSummaryInDb> executiveSummaries;

  ReadExecutiveSummarySuccess({required this.executiveSummaries});
}

final class ReadFetchingMore extends ReadExecutiveSummarySuccess {
  ReadFetchingMore({required super.executiveSummaries});
}

final class ReadErrorPagination extends ReadExecutiveSummarySuccess {
  final String message;

  ReadErrorPagination({
    required this.message,
    required super.executiveSummaries,
  });
}

final class ReadExecutiveSummaryFailure extends ReadExecutiveSummaryState {
  final String message;

  ReadExecutiveSummaryFailure({required this.message});
}
