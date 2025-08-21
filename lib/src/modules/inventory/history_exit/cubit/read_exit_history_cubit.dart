import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/exit_history/exit_history_model.dart';
import 'package:kardex_app_front/src/domain/repositories/exit_histories_repository.dart';
import 'package:kardex_app_front/src/tools/constant.dart';

part 'read_exit_history_state.dart';

class ReadExitHistoryCubit extends Cubit<ReadExitHistoryState> {
  ReadExitHistoryCubit({required this.exitHistoriesRepository}) : super(ReadExitHistoryInitial());

  final ExitHistoriesRepository exitHistoriesRepository;

  bool isLastPage = false;
  List<ExitHistoryInDb> _historiesCache = [];

  Future<void> loadPaginatedHistories({
    String? clientId,
    required String branchId,
  }) async {
    emit(ReadExitHistoryLoading());
    try {
      final response = await exitHistoriesRepository.getExitHistories(
        offset: 0,
        limit: paginationItems,
        clientId: clientId,
        branchId: branchId,
      );

      _historiesCache = response.data;
      if (_historiesCache.length >= response.count) {
        isLastPage = true;
      } else {
        isLastPage = false;
      }
      emit(ReadExitHistorySuccess(_historiesCache, response.count));
    } catch (error) {
      emit(ReadExitHistoryError(error.toString()));
    }
  }

  Future<void> getNextPage({
    String? clientId,
    required String branchId,
  }) async {
    if (isLastPage) return;
    try {
      final response = await exitHistoriesRepository.getExitHistories(
        offset: _historiesCache.length,
        limit: paginationItems,
        clientId: clientId,
        branchId: branchId,
      );

      _historiesCache.addAll(response.data);
      if (_historiesCache.length >= response.count) {
        isLastPage = true;
      }
      emit(ReadExitHistorySuccess(_historiesCache, response.count));
    } catch (e) {
      log(e.toString());
    }
  }
}
