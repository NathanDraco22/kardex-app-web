import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/entry_history/entry_history_model.dart';
import 'package:kardex_app_front/src/domain/repositories/entry_histories_repository.dart';

part 'read_entry_history_state.dart';

class ReadEntryHistoryCubit extends Cubit<ReadEntryHistoryState> {
  ReadEntryHistoryCubit({required this.entryHistoriesRepository}) : super(ReadEntryHistoryInitial());

  final EntryHistoriesRepository entryHistoriesRepository;

  bool isLastPage = false;
  List<EntryHistoryInDb> _historiesCache = [];

  String? supplierId;
  int? startDate;
  int? endDate;

  Future<void> loadPaginatedHistories() async {
    emit(ReadEntryHistoryLoading());
    try {
      final response = await entryHistoriesRepository.getEntryHistories(
        offset: 0,
        supplierId: supplierId,
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
      emit(ReadEntryHistorySuccess(_historiesCache, response.count));
    } catch (error) {
      if (isClosed) return;
      emit(ReadEntryHistoryError(error.toString()));
    }
  }

  Future<void> getNextPage() async {
    if (isLastPage) return;
    try {
      final response = await entryHistoriesRepository.getEntryHistories(
        offset: _historiesCache.length,
        supplierId: supplierId,
        startDate: startDate,
        endDate: endDate,
      );

      _historiesCache.addAll(response.data);
      if (_historiesCache.length >= response.count) {
        isLastPage = true;
      }
      if (isClosed) return;
      emit(ReadEntryHistorySuccess(_historiesCache, response.count));
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> clearFilterParams() async {
    if (supplierId == null && startDate == null && endDate == null) return;

    supplierId = null;
    startDate = null;
    endDate = null;
    _historiesCache = [];
    loadPaginatedHistories();
  }
}
