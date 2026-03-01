import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/common/branches_detail.dart';
import 'package:kardex_app_front/src/domain/models/daily_summary/daily_summary_in_db.dart';
import 'package:kardex_app_front/src/domain/query_params/daily_summary_params.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

part 'read_branch_daily_summary_state.dart';

class ReadBranchDailySummaryCubit extends Cubit<ReadBranchDailySummaryState> {
  ReadBranchDailySummaryCubit({
    required this.dailySummariesRepository,
  }) : super(ReadBranchDailySummaryInitial());

  final DailySummariesRepository dailySummariesRepository;

  DailySummaryQueryParams _params = DailySummaryQueryParams();
  bool isLastPage = false;
  final String currentBranchId = BranchesTool.getCurrentBranchId();

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
