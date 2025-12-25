import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/daily_summary/daily_summary_in_db.dart';
import 'package:kardex_app_front/src/domain/query_params/daily_summary_params.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

part 'read_daily_summary_state.dart';

class ReadDailySummaryCubit extends Cubit<ReadDailySummaryState> {
  ReadDailySummaryCubit({
    required this.dailySummariesRepository,
  }) : super(ReadDailySummaryInitial());

  final DailySummariesRepository dailySummariesRepository;

  DailySummaryQueryParams _params = DailySummaryQueryParams();
  bool isLastPage = false;

  Future<void> getDailySummary({DailySummaryQueryParams? params}) async {
    _params.endDate = DateTimeTool.getTodayMidnight().add(const Duration(days: 1)).millisecondsSinceEpoch;
    emit(ReadDailySummaryLoading());
    _params = params ?? _params;
    try {
      final dailySummaries = await dailySummariesRepository.getAll(_params);

      if (dailySummaries.length < _params.limit) {
        isLastPage = true;
      }

      _params.offset += dailySummaries.length;

      emit(ReadDailySummarySuccess(dailySummaries: dailySummaries));
    } catch (e) {
      emit(ReadDailySummaryFailure(message: e.toString()));
    }
  }

  Future<void> getNextPage() async {
    if (isLastPage) return;
    final currentState = state;
    if (currentState is! ReadDailySummarySuccess) return;

    emit(ReadFetchingMore(dailySummaries: currentState.dailySummaries));

    try {
      final dailySummaries = await dailySummariesRepository.getAll(_params);

      if (dailySummaries.length < _params.limit) {
        isLastPage = true;
      }

      _params.offset += dailySummaries.length;

      emit(ReadDailySummarySuccess(dailySummaries: dailySummaries));
    } catch (e) {
      emit(
        ReadErrorPagination(
          message: e.toString(),
          dailySummaries: currentState.dailySummaries,
        ),
      );
    }
  }
}
