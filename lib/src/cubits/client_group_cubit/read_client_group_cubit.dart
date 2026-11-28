import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_client_group_state.dart';

class ReadClientGroupCubit extends Cubit<ReadClientGroupState> {
  ReadClientGroupCubit(this._repository) : super(ReadClientGroupInitial()) {
    _subscription = _repository.eventStream.listen(_handleRepoEvent);
  }

  final ClientGroupsRepository _repository;
  StreamSubscription<RepoEvent<ClientGroupInDb>>? _subscription;

  List<ClientGroupInDb> _clientGroups = [];
  int _generation = 0;
  bool _hasLoaded = false;
  bool _isLoading = false;

  void _handleRepoEvent(RepoEvent<ClientGroupInDb> event) {
    if (!_hasLoaded) return;

    switch (event) {
      case RepoItemCreated(:final item):
        final groups = [item, ..._clientGroups.where((group) => group.id != item.id)];
        _emitSuccess(groups);
      case RepoItemUpdated(:final item):
        final exists = _clientGroups.any((group) => group.id == item.id);
        final groups = exists
            ? _clientGroups.map((group) => group.id == item.id ? item : group).toList()
            : [item, ..._clientGroups];
        _emitSuccess(groups);
      case RepoItemDeleted(:final item):
        final groups = _clientGroups.where((group) => group.id != item.id).toList();
        _emitSuccess(groups);
    }
  }

  Future<void> ensureLoaded() async {
    if (_hasLoaded || _isLoading) return;
    await loadAllClientGroups();
  }

  Future<void> loadAllClientGroups() async {
    final generation = ++_generation;
    _isLoading = true;
    emit(ReadClientGroupLoading());

    try {
      final groups = await _repository.getAllClientGroups();
      if (isClosed || generation != _generation) return;

      _clientGroups = _sorted(groups);
      _hasLoaded = true;
      _isLoading = false;
      emit(ReadClientGroupSuccess(List.unmodifiable(_clientGroups)));
    } catch (error) {
      if (isClosed || generation != _generation) return;

      _isLoading = false;
      emit(ClientGroupReadError(error.toString()));
    }
  }

  void clear() {
    _generation++;
    _hasLoaded = false;
    _isLoading = false;
    _clientGroups = [];
    if (!isClosed) {
      emit(ReadClientGroupInitial());
    }
  }

  List<ClientGroupInDb> _sorted(List<ClientGroupInDb> groups) {
    final sortedGroups = List<ClientGroupInDb>.from(groups);
    sortedGroups.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return sortedGroups;
  }

  void _emitSuccess(List<ClientGroupInDb> groups) {
    _clientGroups = _sorted(groups);
    if (!isClosed) {
      emit(ReadClientGroupSuccess(List.unmodifiable(_clientGroups)));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
