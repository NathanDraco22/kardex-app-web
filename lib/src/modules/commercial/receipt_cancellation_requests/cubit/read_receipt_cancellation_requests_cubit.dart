import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

import 'read_receipt_cancellation_requests_state.dart';

class ReadReceiptCancellationRequestsCubit
    extends Cubit<ReadReceiptCancellationRequestsState> {
  final ReceiptCancellationRequestsRepository _repository;
  StreamSubscription<RepoEvent<ReceiptCancellationRequestInDb>>?
      _subscription;

  String? _branchId;
  ReceiptCancellationRequestStatus? _statusFilter =
      ReceiptCancellationRequestStatus.pending;

  ReadReceiptCancellationRequestsCubit(this._repository)
      : super(const ReadReceiptCancellationRequestsInitial()) {
    _subscription = _repository.eventStream.listen((event) {
      if (state is! ReadReceiptCancellationRequestsSuccess) return;
      final current = List<ReceiptCancellationRequestInDb>.from(
        (state as ReadReceiptCancellationRequestsSuccess).requests,
      );
      switch (event) {
        case RepoItemCreated<ReceiptCancellationRequestInDb>(:final item):
          if (_statusFilter == null || item.status == _statusFilter) {
            current.insert(0, item);
          }
          break;
        case RepoItemUpdated<ReceiptCancellationRequestInDb>(:final item):
          final idx = current.indexWhere((e) => e.id == item.id);
          if (_statusFilter != null && item.status != _statusFilter) {
            if (idx != -1) current.removeAt(idx);
          } else if (idx != -1) {
            current[idx] = item;
          } else {
            current.insert(0, item);
          }
          break;
        case RepoItemDeleted<ReceiptCancellationRequestInDb>(:final item):
          current.removeWhere((e) => e.id == item.id);
          break;
      }
      emit(
        ReadReceiptCancellationRequestsSuccess(
          requests: current,
          statusFilter: _statusFilter,
        ),
      );
    });
  }

  ReceiptCancellationRequestStatus? get statusFilter => _statusFilter;

  Future<void> loadRequests({
    String? branchId,
    ReceiptCancellationRequestStatus? status,
    bool updateStatusFilter = false,
  }) async {
    _branchId = branchId ?? _branchId;
    if (updateStatusFilter) {
      _statusFilter = status;
    }

    emit(const ReadReceiptCancellationRequestsLoading());
    try {
      final items = await _repository.getAllRequests(
        ReceiptCancellationRequestQueryParams(
          branchId: _branchId,
          status: _statusFilter?.name,
          limit: 100,
        ),
      );
      emit(
        ReadReceiptCancellationRequestsSuccess(
          requests: items,
          statusFilter: _statusFilter,
        ),
      );
    } catch (e) {
      emit(ReadReceiptCancellationRequestsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
