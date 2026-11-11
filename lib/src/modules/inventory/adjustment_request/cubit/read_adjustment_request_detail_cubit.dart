import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

import 'read_adjustment_requests_cubit.dart' show mapAdjustmentRequestErrorMessage;

part 'read_adjustment_request_detail_state.dart';

/// Cubit de detalle de una solicitud de ajuste.
///
/// Carga por id y escucha el [ReactiveRepository.eventStream] para refrescar
/// únicamente el documento abierto cuando se aprueba, edita o cancela.
class ReadAdjustmentRequestDetailCubit extends Cubit<ReadAdjustmentRequestDetailState> {
  ReadAdjustmentRequestDetailCubit({
    required this.repository,
    required this.requestId,
  }) : super(ReadAdjustmentRequestDetailInitial()) {
    _subscription = repository.eventStream.listen(_handleRepoEvent);
  }

  final AdjustmentRequestsRepository repository;
  final String requestId;

  StreamSubscription<RepoEvent<AdjustmentRequestInDb>>? _subscription;

  Future<void> load({AdjustmentRequestInDb? initialRequest}) async {
    if (initialRequest != null) {
      emit(ReadAdjustmentRequestDetailSuccess(initialRequest));
    } else {
      emit(ReadAdjustmentRequestDetailLoading());
    }

    try {
      final request = await repository.getAdjustmentRequestById(requestId);
      if (isClosed) return;
      emit(ReadAdjustmentRequestDetailSuccess(request));
    } catch (error) {
      if (isClosed) return;
      if (state is ReadAdjustmentRequestDetailSuccess) return;
      emit(ReadAdjustmentRequestDetailError(mapAdjustmentRequestErrorMessage(error)));
    }
  }

  Future<void> refresh() => load();

  void _handleRepoEvent(RepoEvent<AdjustmentRequestInDb> event) {
    if (isClosed) return;

    switch (event) {
      case RepoItemCreated(:final item):
        _apply(item);
      case RepoItemUpdated(:final item):
        _apply(item);
      case RepoItemDeleted(:final item):
        if (item.id != requestId) return;
        emit(const ReadAdjustmentRequestDetailError('La solicitud de ajuste fue eliminada.'));
    }
  }

  void _apply(AdjustmentRequestInDb item) {
    if (item.id != requestId) return;
    emit(ReadAdjustmentRequestDetailSuccess(item));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
