import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_entry_history_state.dart';

class ReadEntryHistoryCubit extends Cubit<ReadEntryHistoryState> {
  ReadEntryHistoryCubit({required this.entryHistoriesRepository}) : super(ReadEntryHistoryInitial());

  final EntryHistoriesRepository entryHistoriesRepository;

  bool isLastPage = false;
  List<EntryHistoryInDb> _historiesCache = [];

  String? _lastBranchId;
  String? supplierId;
  int? startDate;
  int? endDate;

  Future<void> loadPaginatedHistories(String branchId) async {
    _lastBranchId = branchId;
    emit(ReadEntryHistoryLoading());
    try {
      final response = await entryHistoriesRepository.getEntryHistories(
        branchId: branchId,
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

  Future<void> getNextPage(String branchId) async {
    if (isLastPage) return;
    try {
      final response = await entryHistoriesRepository.getEntryHistories(
        branchId: branchId,
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
    if (_lastBranchId != null) {
      loadPaginatedHistories(_lastBranchId!);
    }
  }
}
