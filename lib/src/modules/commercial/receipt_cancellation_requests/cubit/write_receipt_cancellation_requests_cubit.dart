import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

import 'write_receipt_cancellation_requests_state.dart';

class WriteReceiptCancellationRequestsCubit
    extends Cubit<WriteReceiptCancellationRequestsState> {
  final ReceiptCancellationRequestsRepository _repository;

  WriteReceiptCancellationRequestsCubit(this._repository)
      : super(const WriteReceiptCancellationRequestsInitial());

  Future<void> approveRequest(
    String id,
    UserInfo reviewedBy, {
    String reviewNotes = '',
  }) async {
    emit(const WriteReceiptCancellationRequestsLoading());
    try {
      final result = await _repository.approveRequest(
        id,
        reviewedBy,
        reviewNotes: reviewNotes,
      );
      emit(
        WriteReceiptCancellationRequestsSuccess(
          result,
          'Solicitud aprobada y recibo anulado.',
        ),
      );
    } catch (e) {
      emit(WriteReceiptCancellationRequestsError(e.toString()));
    }
  }

  Future<void> rejectRequest(
    String id,
    UserInfo reviewedBy, {
    required String reviewNotes,
  }) async {
    emit(const WriteReceiptCancellationRequestsLoading());
    try {
      final result = await _repository.rejectRequest(
        id,
        reviewedBy,
        reviewNotes: reviewNotes,
      );
      emit(
        WriteReceiptCancellationRequestsSuccess(
          result,
          'Solicitud rechazada.',
        ),
      );
    } catch (e) {
      emit(WriteReceiptCancellationRequestsError(e.toString()));
    }
  }

  Future<void> cancelRequest(String id, UserInfo cancelledBy) async {
    emit(const WriteReceiptCancellationRequestsLoading());
    try {
      final result = await _repository.cancelRequest(id, cancelledBy);
      emit(
        WriteReceiptCancellationRequestsSuccess(
          result,
          'Solicitud cancelada.',
        ),
      );
    } catch (e) {
      emit(WriteReceiptCancellationRequestsError(e.toString()));
    }
  }
}
