import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/exit_history/exit_history_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'read_exit_history_state.dart';

class ReadExitHistoryCubit extends Cubit<ReadExitHistoryState> {
  ReadExitHistoryCubit({required this.exitHistoriesRepository}) : super(ReadExitHistoryInitial());

  final ExitHistoriesRepository exitHistoriesRepository;

  bool isLastPage = false;
  List<ExitHistoryInDb> _historiesCache = [];

  String? _lastBranchId;
  String? clientId;
  int? startDate;
  int? endDate;

  Future<void> loadPaginatedHistories(String branchId) async {
    _lastBranchId = branchId;
    emit(ReadExitHistoryLoading());
    try {
      final response = await exitHistoriesRepository.getExitHistories(
        branchId: branchId,
        offset: 0,
        clientId: clientId,
        startDate: startDate,
        endDate: endDate,
      );

      _historiesCache = response.data;
      if (_historiesCache.length >= response.count) {
        isLastPage = true;
      } else {
        isLastPage = false;
      }
      if (isClosed) return;
      emit(ReadExitHistorySuccess(_historiesCache, response.count));
    } catch (error) {
      if (isClosed) return;
      emit(ReadExitHistoryError(error.toString()));
    }
  }

  Future<void> getNextPage(String branchId) async {
    if (isLastPage) return;
    try {
      final response = await exitHistoriesRepository.getExitHistories(
        branchId: branchId,
        offset: _historiesCache.length,
        clientId: clientId,
        startDate: startDate,
        endDate: endDate,
      );

      _historiesCache.addAll(response.data);
      if (_historiesCache.length >= response.count) {
        isLastPage = true;
      }
      if (isClosed) return;
      emit(ReadExitHistorySuccess(_historiesCache, response.count));
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> clearFilterParams() async {
    clientId = null;
    startDate = null;
    endDate = null;
    _historiesCache = [];
    isLastPage = false;
    if (_lastBranchId != null) {
      loadPaginatedHistories(_lastBranchId!);
    }
  }
}
