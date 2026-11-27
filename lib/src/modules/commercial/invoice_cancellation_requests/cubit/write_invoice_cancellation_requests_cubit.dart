import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

import 'write_invoice_cancellation_requests_state.dart';

class WriteInvoiceCancellationRequestsCubit
    extends Cubit<WriteInvoiceCancellationRequestsState> {
  final InvoiceCancellationRequestsRepository _repository;

  WriteInvoiceCancellationRequestsCubit(this._repository)
      : super(const WriteInvoiceCancellationRequestsInitial());

  Future<void> approveRequest(
    String id,
    UserInfo reviewedBy, {
    String reviewNotes = '',
  }) async {
    emit(const WriteInvoiceCancellationRequestsLoading());
    try {
      final result = await _repository.approveRequest(
        id,
        reviewedBy,
        reviewNotes: reviewNotes,
      );
      emit(
        WriteInvoiceCancellationRequestsSuccess(
          result,
          'Solicitud aprobada y factura anulada.',
        ),
      );
    } catch (e) {
      emit(WriteInvoiceCancellationRequestsError(e.toString()));
    }
  }

  Future<void> rejectRequest(
    String id,
    UserInfo reviewedBy, {
    required String reviewNotes,
  }) async {
    emit(const WriteInvoiceCancellationRequestsLoading());
    try {
      final result = await _repository.rejectRequest(
        id,
        reviewedBy,
        reviewNotes: reviewNotes,
      );
      emit(
        WriteInvoiceCancellationRequestsSuccess(
          result,
          'Solicitud rechazada.',
        ),
      );
    } catch (e) {
      emit(WriteInvoiceCancellationRequestsError(e.toString()));
    }
  }

  Future<void> cancelRequest(String id, UserInfo cancelledBy) async {
    emit(const WriteInvoiceCancellationRequestsLoading());
    try {
      final result = await _repository.cancelRequest(id, cancelledBy);
      emit(
        WriteInvoiceCancellationRequestsSuccess(
          result,
          'Solicitud cancelada.',
        ),
      );
    } catch (e) {
      emit(WriteInvoiceCancellationRequestsError(e.toString()));
    }
  }
}
