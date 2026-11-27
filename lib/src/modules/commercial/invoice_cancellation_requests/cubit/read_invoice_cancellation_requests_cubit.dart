import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

import 'read_invoice_cancellation_requests_state.dart';

class ReadInvoiceCancellationRequestsCubit
    extends Cubit<ReadInvoiceCancellationRequestsState> {
  final InvoiceCancellationRequestsRepository _repository;
  StreamSubscription<RepoEvent<InvoiceCancellationRequestInDb>>?
      _subscription;

  String? _branchId;
  InvoiceCancellationRequestStatus? _statusFilter =
      InvoiceCancellationRequestStatus.pending;

  ReadInvoiceCancellationRequestsCubit(this._repository)
      : super(const ReadInvoiceCancellationRequestsInitial()) {
    _subscription = _repository.eventStream.listen((event) {
      if (state is! ReadInvoiceCancellationRequestsSuccess) return;
      final current =
          List<InvoiceCancellationRequestInDb>.from(
            (state as ReadInvoiceCancellationRequestsSuccess).requests,
          );
      switch (event) {
        case RepoItemCreated<InvoiceCancellationRequestInDb>(:final item):
          if (_statusFilter == null || item.status == _statusFilter) {
            current.insert(0, item);
          }
          break;
        case RepoItemUpdated<InvoiceCancellationRequestInDb>(:final item):
          final idx = current.indexWhere((e) => e.id == item.id);
          if (_statusFilter != null && item.status != _statusFilter) {
            if (idx != -1) current.removeAt(idx);
          } else if (idx != -1) {
            current[idx] = item;
          } else {
            current.insert(0, item);
          }
          break;
        case RepoItemDeleted<InvoiceCancellationRequestInDb>(:final item):
          current.removeWhere((e) => e.id == item.id);
          break;
      }
      emit(
        ReadInvoiceCancellationRequestsSuccess(
          requests: current,
          statusFilter: _statusFilter,
        ),
      );
    });
  }

  InvoiceCancellationRequestStatus? get statusFilter => _statusFilter;

  Future<void> loadRequests({
    String? branchId,
    InvoiceCancellationRequestStatus? status,
    bool updateStatusFilter = false,
  }) async {
    _branchId = branchId ?? _branchId;
    if (updateStatusFilter) {
      _statusFilter = status;
    }

    emit(const ReadInvoiceCancellationRequestsLoading());
    try {
      final items = await _repository.getAllRequests(
        InvoiceCancellationRequestQueryParams(
          branchId: _branchId,
          status: _statusFilter?.name,
          limit: 100,
        ),
      );
      emit(
        ReadInvoiceCancellationRequestsSuccess(
          requests: items,
          statusFilter: _statusFilter,
        ),
      );
    } catch (e) {
      emit(ReadInvoiceCancellationRequestsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
