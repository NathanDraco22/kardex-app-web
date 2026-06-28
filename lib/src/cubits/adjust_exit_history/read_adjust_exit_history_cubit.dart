import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_adjust_exit_history_state.dart';

class ReadAdjustExitHistoryCubit extends Cubit<ReadAdjustExitHistoryState> {
  ReadAdjustExitHistoryCubit(this.adjustExitsRepository) : super(ReadAdjustExitHistoryInitial());

  final AdjustExitsRepository adjustExitsRepository;

  AdjustQueryParams params = AdjustQueryParams(
    endDate: DateTime.now().endOfDay().millisecondsSinceEpoch,
  );
  bool _isLastPage = false;

  Future<void> loadAdjustExitsHistory(String branchId) async {
    emit(ReadAdjustExitHistoryLoading());
    params = params.copyWith(offset: 0, branchId: branchId);

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

  void setDefaultParams(String branchId) {
    params = const AdjustQueryParams();
    _isLastPage = false;
    loadAdjustExitsHistory(branchId);
  }
}
