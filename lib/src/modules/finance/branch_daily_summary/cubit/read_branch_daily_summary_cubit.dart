import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_branch_daily_summary_state.dart';

class ReadBranchDailySummaryCubit extends Cubit<ReadBranchDailySummaryState> {
  ReadBranchDailySummaryCubit({
    required this.dailySummariesRepository,
    required this.currentBranchId,
  }) : super(ReadBranchDailySummaryInitial());

  final DailySummariesRepository dailySummariesRepository;
  final String currentBranchId;

  DailySummaryQueryParams _params = DailySummaryQueryParams();
  bool isLastPage = false;

  Future<void> getDailySummary({DailySummaryQueryParams? params}) async {
    _params.endDate = DateTimeTool.getTodayMidnight().add(const Duration(days: 1)).millisecondsSinceEpoch;
    emit(ReadBranchDailySummaryLoading());
    _params = params ?? _params;
    try {
      final dailySummaries = await dailySummariesRepository.getAll(_params);

      if (dailySummaries.length < _params.limit) {
        isLastPage = true;
      }

      _params.offset += dailySummaries.length;

      final branchSummaries = _mapToBranchSummaries(dailySummaries);
      emit(ReadBranchDailySummarySuccess(summaries: branchSummaries));
    } catch (e) {
      emit(ReadBranchDailySummaryFailure(message: e.toString()));
    }
  }

  Future<void> getNextPage() async {
    if (isLastPage) return;
    final currentState = state;
    if (currentState is! ReadBranchDailySummarySuccess) return;

    emit(ReadBranchDailySummaryFetchingMore(summaries: currentState.summaries));

    try {
      final dailySummaries = await dailySummariesRepository.getAll(_params);

      if (dailySummaries.length < _params.limit) {
        isLastPage = true;
      }

      _params.offset += dailySummaries.length;

      final newSummaries = _mapToBranchSummaries(dailySummaries);
      emit(
        ReadBranchDailySummarySuccess(
          summaries: [...currentState.summaries, ...newSummaries],
        ),
      );
    } catch (e) {
      emit(
        ReadBranchDailySummaryErrorPagination(
          message: e.toString(),
          summaries: currentState.summaries,
        ),
      );
    }
  }

  List<BranchDailySummary> _mapToBranchSummaries(List<DailySummaryInDb> source) {
    final List<BranchDailySummary> result = [];
    for (final summary in source) {
      try {
        final branchData = summary.branches.firstWhere((b) => b.branchId == currentBranchId);
        result.add(BranchDailySummary(startDate: summary.startDate, detail: branchData));
      } catch (e) {
        // En caso de que no haya datos para esta sucursal en este día, lo saltamos
      }
    }
    return result;
  }
}
