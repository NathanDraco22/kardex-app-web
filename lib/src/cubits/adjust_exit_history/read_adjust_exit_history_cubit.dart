import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/adjust_exit/adjust_exit_model.dart';
import 'package:kardex_app_front/src/domain/query_params/adjust_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/adjust_exits_repository.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

part 'read_adjust_exit_history_state.dart';

class ReadAdjustExitHistoryCubit extends Cubit<ReadAdjustExitHistoryState> {
  ReadAdjustExitHistoryCubit(this.adjustExitsRepository) : super(ReadAdjustExitHistoryInitial());

  final AdjustExitsRepository adjustExitsRepository;

  AdjustQueryParams params = AdjustQueryParams(
    endDate: DateTime.now().endOfDay().millisecondsSinceEpoch,
  );
  bool _isLastPage = false;

  Future<void> loadAdjustExitsHistory() async {
    emit(ReadAdjustExitHistoryLoading());
    params = params.copyWith(offset: 0, branchId: BranchesTool.getCurrentBranchId());

    try {
      final exits = await adjustExitsRepository.getAllAdjustExits(params);

      _isLastPage = exits.length < (params.limit);

      params = params.copyWith(offset: params.offset + exits.length);

      emit(ReadAdjustExitHistorySuccess(exits));
    } catch (error) {
      emit(ReadAdjustExitHistoryError(error.toString()));
    }
  }

  Future<void> nextPage() async {
    if (_isLastPage) return;
    final currentState = state;
    if (currentState is! ReadAdjustExitHistorySuccess) return;
    if (currentState is FetchingNextPage) return;

    try {
      emit(FetchingNextPage(currentState.exits));
      final exits = await adjustExitsRepository.getAllAdjustExits(params);

      _isLastPage = exits.length < params.limit;

      params = params.copyWith(offset: params.offset + exits.length);

      emit(
        ReadAdjustExitHistorySuccess(
          [...currentState.exits, ...exits],
        ),
      );
    } catch (e) {
      emit(ReadAdjustExitHistoryError(e.toString()));
    }
  }

  void setDefaultParams() {
    params = const AdjustQueryParams();
    _isLastPage = false;
    loadAdjustExitsHistory();
  }
}
