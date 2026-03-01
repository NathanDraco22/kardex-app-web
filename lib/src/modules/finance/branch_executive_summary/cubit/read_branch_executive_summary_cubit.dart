import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/common/branches_detail.dart';
import 'package:kardex_app_front/src/domain/models/executive_summary/executive_summary_in_db.dart';
import 'package:kardex_app_front/src/domain/query_params/daily_summary_params.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';

part 'read_branch_executive_summary_state.dart';

class ReadBranchExecutiveSummaryCubit extends Cubit<ReadBranchExecutiveSummaryState> {
  ReadBranchExecutiveSummaryCubit({
    required this.executiveSummariesRepository,
  }) : super(ReadBranchExecutiveSummaryInitial());

  final ExecutiveSummariesRepository executiveSummariesRepository;

  DailySummaryQueryParams _params = DailySummaryQueryParams();
  bool isLastPage = false;
  final String currentBranchId = BranchesTool.getCurrentBranchId();

  Future<void> getExecutiveSummary({DailySummaryQueryParams? params}) async {
    emit(ReadBranchExecutiveSummaryLoading());
    _params = params ?? _params;
    try {
      final executiveSummaries = await executiveSummariesRepository.getAll(_params);

      if (executiveSummaries.length < _params.limit) {
        isLastPage = true;
      }

      _params.offset += executiveSummaries.length;

      final branchSummaries = _mapToBranchSummaries(executiveSummaries);
      emit(ReadBranchExecutiveSummarySuccess(summaries: branchSummaries));
    } catch (e) {
      emit(ReadBranchExecutiveSummaryFailure(message: e.toString()));
    }
  }

  Future<void> getNextPage() async {
    if (isLastPage) return;
    final currentState = state;
    if (currentState is! ReadBranchExecutiveSummarySuccess) return;

    emit(ReadBranchExecutiveSummaryFetchingMore(summaries: currentState.summaries));

    try {
      final executiveSummaries = await executiveSummariesRepository.getAll(_params);

      if (executiveSummaries.length < _params.limit) {
        isLastPage = true;
      }

      _params.offset += executiveSummaries.length;

      final newSummaries = _mapToBranchSummaries(executiveSummaries);
      emit(
        ReadBranchExecutiveSummarySuccess(
          summaries: [...currentState.summaries, ...newSummaries],
        ),
      );
    } catch (e) {
      emit(
        ReadBranchExecutiveSummaryErrorPagination(
          message: e.toString(),
          summaries: currentState.summaries,
        ),
      );
    }
  }

  List<BranchExecutiveSummary> _mapToBranchSummaries(List<ExecutiveSummaryInDb> source) {
    final List<BranchExecutiveSummary> result = [];
    for (final summary in source) {
      try {
        final commercialData = summary.commercialBranches.firstWhere((b) => b.branchId == currentBranchId);
        InventoryBranchDetail? inventoryData;
        try {
          inventoryData = summary.inventoryBranches.firstWhere((b) => b.branchId == currentBranchId);
        } catch (e) {
          // It's possible inventory is not available for the branch
        }

        result.add(
          BranchExecutiveSummary(
            startDate: summary.startDate,
            year: summary.year,
            month: summary.month,
            type: summary.type,
            commercialDetail: commercialData,
            inventoryDetail: inventoryData,
          ),
        );
      } catch (e) {
        // En caso de que no haya datos para esta sucursal en este periodo, lo saltamos
      }
    }
    return result;
  }
}
