import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/adjust_entry/adjust_entry_model.dart';
import 'package:kardex_app_front/src/domain/query_params/adjust_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/adjust_entries_repository.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

part 'read_adjust_entry_history_state.dart';

class ReadAdjustEntryHistoryCubit extends Cubit<ReadAdjustEntryHistoryState> {
  ReadAdjustEntryHistoryCubit(this.adjustEntriesRepository) : super(ReadAdjustEntryHistoryInitial());

  final AdjustEntriesRepository adjustEntriesRepository;

  AdjustQueryParams params = AdjustQueryParams(
    endDate: DateTime.now().endOfDay().millisecondsSinceEpoch,
  );
  bool _isLastPage = false;

  Future<void> loadAdjustEntriesHistory() async {
    emit(ReadAdjustEntryHistoryLoading());
    params = params.copyWith(offset: 0, branchId: BranchesTool.getCurrentBranchId());

    try {
      final entries = await adjustEntriesRepository.getAllAdjustEntries(params);
      // AdjustEntriesRepository does not return totals separately like InvoiceRepository

      _isLastPage = entries.length < (params.limit);

      params = params.copyWith(offset: params.offset + entries.length);

      emit(ReadAdjustEntryHistorySuccess(entries));
    } catch (error) {
      emit(ReadAdjustEntryHistoryError(error.toString()));
    }
  }

  Future<void> nextPage() async {
    if (_isLastPage) return;
    final currentState = state;
    if (currentState is! ReadAdjustEntryHistorySuccess) return;
    if (currentState is FetchingNextPage) return;

    try {
      emit(FetchingNextPage(currentState.entries));
      final entries = await adjustEntriesRepository.getAllAdjustEntries(params);

      _isLastPage = entries.length < params.limit;

      params = params.copyWith(offset: params.offset + entries.length);

      emit(
        ReadAdjustEntryHistorySuccess(
          [...currentState.entries, ...entries],
        ),
      );
    } catch (e) {
      emit(ReadAdjustEntryHistoryError(e.toString()));
    }
  }

  void setDefaultParams() {
    params = const AdjustQueryParams();
    _isLastPage = false;
    loadAdjustEntriesHistory();
  }
}
