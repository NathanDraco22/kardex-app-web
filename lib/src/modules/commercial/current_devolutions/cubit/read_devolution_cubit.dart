import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_devolution_state.dart';

class ReadDevolutionCubit extends Cubit<ReadDevolutionState> {
  ReadDevolutionCubit({
    required this.devolutionsRepository,
    this.branchId,
    DevolutionStatus? initialStatus = DevolutionStatus.open,
  }) : status = initialStatus,
       super(ReadDevolutionInitial()) {
    _subscription = devolutionsRepository.eventStream.listen(_handleRepoEvent);
  }

  final DevolutionsRepository devolutionsRepository;

  StreamSubscription<RepoEvent<DevolutionInDb>>? _subscription;

  List<DevolutionInDb> _devolutionsCache = [];
  final Set<String> _newDevolutionIds = {};
  final Set<String> _updatedDevolutionIds = {};

  String? branchId;
  DevolutionStatus? status;
  String? clientId;
  String searchKeyword = '';

  Future<void> loadAllDevolutions({String? branchId}) async {
    if (branchId != null) {
      this.branchId = branchId;
    }
    emit(ReadDevolutionLoading());
    try {
      final params = DevolutionQueryParams()
        ..branchId = this.branchId
        ..clientId = clientId
        ..status = status;

      final devolutions = await devolutionsRepository.getAllDevolutions(params);
      _devolutionsCache = List<DevolutionInDb>.from(devolutions);
      _newDevolutionIds.clear();
      _updatedDevolutionIds.clear();

      if (isClosed) return;
      _emitVisibleList();
    } catch (error) {
      if (isClosed) return;
      emit(ReadDevolutionError(error.toString()));
    }
  }

  Future<void> applyFilters({
    DevolutionStatus? status,
    bool clearStatus = false,
    String? clientId,
    bool clearClient = false,
  }) async {
    if (clearStatus) {
      this.status = null;
    } else if (status != null) {
      this.status = status;
    }

    if (clearClient) {
      this.clientId = null;
    } else if (clientId != null) {
      this.clientId = clientId;
    }

    await loadAllDevolutions();
  }

  Future<void> clearFilters() async {
    status = DevolutionStatus.open;
    clientId = null;
    searchKeyword = '';
    await loadAllDevolutions();
  }

  void searchDevolution(String keyword) {
    searchKeyword = keyword;
    if (state is! ReadDevolutionSuccess) return;
    _emitVisibleList();
  }

  Future<void> putDevolutionFirst(DevolutionInDb devolution) async {
    if (!_matchesBackendFilters(devolution)) return;
    final exists = _devolutionsCache.any((d) => d.id == devolution.id);
    if (!exists) {
      _devolutionsCache = [devolution, ..._devolutionsCache];
    }
    _updatedDevolutionIds.remove(devolution.id);
    _newDevolutionIds.add(devolution.id);

    if (isClosed || state is! ReadDevolutionSuccess) return;
    _emitVisibleList();
  }

  Future<void> markDevolutionUpdated(DevolutionInDb devolution) async {
    final index = _devolutionsCache.indexWhere((d) => d.id == devolution.id);
    final matches = _matchesBackendFilters(devolution);

    if (!matches) {
      if (index == -1) return;
      _devolutionsCache = _devolutionsCache.where((d) => d.id != devolution.id).toList();
      _newDevolutionIds.remove(devolution.id);
      _updatedDevolutionIds.remove(devolution.id);
      if (isClosed || state is! ReadDevolutionSuccess) return;
      _emitVisibleList();
      return;
    }

    if (index == -1) {
      _devolutionsCache = [devolution, ..._devolutionsCache];
    } else {
      final updatedList = List<DevolutionInDb>.from(_devolutionsCache);
      updatedList[index] = devolution;
      _devolutionsCache = updatedList;
    }
    _newDevolutionIds.remove(devolution.id);
    _updatedDevolutionIds.add(devolution.id);

    if (isClosed || state is! ReadDevolutionSuccess) return;
    _emitVisibleList();
  }

  Future<void> removeDevolution(DevolutionInDb devolution) async {
    _devolutionsCache = _devolutionsCache.where((d) => d.id != devolution.id).toList();
    _newDevolutionIds.remove(devolution.id);
    _updatedDevolutionIds.remove(devolution.id);
    if (isClosed || state is! ReadDevolutionSuccess) return;
    _emitVisibleList();
  }

  void _handleRepoEvent(RepoEvent<DevolutionInDb> event) {
    if (isClosed || state is! ReadDevolutionSuccess) return;

    switch (event) {
      case RepoItemCreated<DevolutionInDb>(:final item):
        if (!_matchesBackendFilters(item)) return;
        if (_devolutionsCache.any((d) => d.id == item.id)) return;
        _devolutionsCache = [item, ..._devolutionsCache];
        _updatedDevolutionIds.remove(item.id);
        _newDevolutionIds.add(item.id);
        _emitVisibleList();

      case RepoItemUpdated<DevolutionInDb>(:final item):
        markDevolutionUpdated(item);

      case RepoItemDeleted<DevolutionInDb>(:final item):
        if (!_devolutionsCache.any((d) => d.id == item.id)) return;
        removeDevolution(item);
    }
  }

  bool _matchesBackendFilters(DevolutionInDb item) {
    if (branchId != null && item.branchId != branchId) return false;
    if (clientId != null && item.clientId != clientId) return false;
    if (status != null && item.status != status) return false;
    return true;
  }

  void _emitVisibleList() {
    final query = searchKeyword.trim().toLowerCase();
    final visible = query.isEmpty
        ? _devolutionsCache
        : _devolutionsCache.where((devolution) {
            return devolution.clientInfo.name.toLowerCase().contains(query) ||
                devolution.docNumber.toLowerCase().contains(query);
          }).toList();

    var totalAmount = 0;
    for (final item in visible) {
      totalAmount += item.total;
    }

    emit(
      ReadDevolutionSuccess(
        List<DevolutionInDb>.unmodifiable(visible),
        totalAmount: totalAmount,
        newDevolutionIds: Set<String>.unmodifiable(_newDevolutionIds),
        updatedDevolutionIds: Set<String>.unmodifiable(_updatedDevolutionIds),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
