part of 'read_daily_summary_cubit.dart';

sealed class ReadDailySummaryState {}

final class ReadDailySummaryInitial extends ReadDailySummaryState {}

final class ReadDailySummaryLoading extends ReadDailySummaryState {}

class ReadDailySummarySuccess extends ReadDailySummaryState {
  final List<DailySummaryInDb> dailySummaries;

  ReadDailySummarySuccess({required this.dailySummaries});
}

final class ReadFetchingMore extends ReadDailySummarySuccess {
  ReadFetchingMore({required super.dailySummaries});
}

final class ReadErrorPagination extends ReadDailySummarySuccess {
  final String message;

  ReadErrorPagination({
    required this.message,
    required super.dailySummaries,
  });
}

final class ReadDailySummaryFailure extends ReadDailySummaryState {
  final String message;

  ReadDailySummaryFailure({required this.message});
}
