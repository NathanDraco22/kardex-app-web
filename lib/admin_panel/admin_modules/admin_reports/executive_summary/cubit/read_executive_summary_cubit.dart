import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/executive_summary/executive_summary_in_db.dart';
import 'package:kardex_app_front/src/domain/query_params/daily_summary_params.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

part 'read_executive_summary_state.dart';

class ReadExecutiveSummaryCubit extends Cubit<ReadExecutiveSummaryState> {
  ReadExecutiveSummaryCubit({
    required this.executiveSummariesRepository,
  }) : super(ReadExecutiveSummaryInitial());

  final ExecutiveSummariesRepository executiveSummariesRepository;

  DailySummaryQueryParams _params = DailySummaryQueryParams();
  bool isLastPage = false;

  Future<void> getExecutiveSummary({DailySummaryQueryParams? params}) async {
    emit(ReadExecutiveSummaryLoading());
    _params = params ?? _params;
    _params.endDate = DateTimeTool.getTodayMidnight().add(const Duration(days: 1)).millisecondsSinceEpoch;
    try {
      final executiveSummaries = await executiveSummariesRepository.getAll(_params);

      if (executiveSummaries.length < _params.limit) {
        isLastPage = true;
      }

      _params.offset += executiveSummaries.length;

      emit(ReadExecutiveSummarySuccess(executiveSummaries: executiveSummaries));
    } catch (e) {
      emit(ReadExecutiveSummaryFailure(message: e.toString()));
    }
  }

  Future<void> getNextPage() async {
    if (isLastPage) return;
    final currentState = state;
    if (currentState is! ReadExecutiveSummarySuccess) return;

    emit(ReadFetchingMore(executiveSummaries: currentState.executiveSummaries));

    try {
      final executiveSummaries = await executiveSummariesRepository.getAll(_params);

      if (executiveSummaries.length < _params.limit) {
        isLastPage = true;
      }

      _params.offset += executiveSummaries.length;

      emit(ReadExecutiveSummarySuccess(executiveSummaries: executiveSummaries));
    } catch (e) {
      emit(
        ReadErrorPagination(
          message: e.toString(),
          executiveSummaries: currentState.executiveSummaries,
        ),
      );
    }
  }
}
