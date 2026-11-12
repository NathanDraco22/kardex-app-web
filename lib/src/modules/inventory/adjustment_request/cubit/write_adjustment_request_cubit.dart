import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

import 'read_adjustment_requests_cubit.dart' show mapAdjustmentRequestErrorMessage;

part 'write_adjustment_request_state.dart';

/// Canal de escritura de solicitudes de ajuste.
///
/// Recibe únicamente DTOs; nunca conoce el ViewController de la pantalla.
class WriteAdjustmentRequestCubit extends Cubit<WriteAdjustmentRequestState> {
  WriteAdjustmentRequestCubit({required this.repository}) : super(WriteAdjustmentRequestInitial());

  final AdjustmentRequestsRepository repository;

  Future<void> create(CreateAdjustmentRequest request) async {
    emit(WritingAdjustmentRequest());
    try {
      final item = await repository.createAdjustmentRequest(request);
      if (isClosed) return;
      emit(AdjustmentRequestCreated(item));
      emit(WriteAdjustmentRequestInitial());
    } catch (error) {
      if (isClosed) return;
      emit(WriteAdjustmentRequestError(mapAdjustmentRequestErrorMessage(error)));
    }
  }

  Future<void> update(String id, UpdateAdjustmentRequest request) async {
    emit(WritingAdjustmentRequest());
    try {
      final item = await repository.updateAdjustmentRequest(id, request);
      if (isClosed) return;
      emit(AdjustmentRequestUpdated(item));
      emit(WriteAdjustmentRequestInitial());
    } catch (error) {
      if (isClosed) return;
      emit(WriteAdjustmentRequestError(mapAdjustmentRequestErrorMessage(error)));
    }
  }

  Future<void> approve(String id, UserInfo approvedBy) async {
    emit(WritingAdjustmentRequest());
    try {
      final item = await repository.approveAdjustmentRequest(id, approvedBy);
      if (isClosed) return;
      emit(AdjustmentRequestApproved(item));
      emit(WriteAdjustmentRequestInitial());
    } catch (error) {
      if (isClosed) return;
      emit(WriteAdjustmentRequestError(mapAdjustmentRequestErrorMessage(error)));
    }
  }

  Future<void> cancel(
    String id,
    UserInfo cancelledBy, {
    String? reason,
  }) async {
    emit(WritingAdjustmentRequest());
    try {
      final item = await repository.cancelAdjustmentRequest(
        id,
        cancelledBy,
        reason: reason?.trim().isEmpty == true ? null : reason?.trim(),
      );
      if (isClosed) return;
      emit(AdjustmentRequestCancelled(item));
      emit(WriteAdjustmentRequestInitial());
    } catch (error) {
      if (isClosed) return;
      emit(WriteAdjustmentRequestError(mapAdjustmentRequestErrorMessage(error)));
    }
  }
}
