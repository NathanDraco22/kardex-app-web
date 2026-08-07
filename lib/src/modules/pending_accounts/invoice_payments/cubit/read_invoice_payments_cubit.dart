import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_invoice_payments_state.dart';

class ReadInvoicePaymentsCubit extends Cubit<ReadInvoicePaymentsState> {
  ReadInvoicePaymentsCubit({required this.invoicesRepository})
    : super(ReadInvoicePaymentsInitial());

  final InvoicesRepository invoicesRepository;

  static const int pageSize = 100;

  String? _clientId;
  int _offset = 0;
  bool _isLastPage = false;
  bool _isFetching = false;

  Future<void> loadInvoices(String? clientId, String branchId) async {
    _clientId = clientId;
    _offset = 0;
    _isLastPage = false;

    if (clientId == null) {
      emit(ReadInvoicePaymentsInitial());
      return;
    }

    final currentState = state;
    if (currentState is ReadInvoicePaymentsSuccess) {
      emit(ReadInvoicePaymentsSearching(currentState.invoices, currentState.totalCount));
    } else {
      emit(ReadInvoicePaymentsLoading());
    }

    try {
      final result = await invoicesRepository.getAllInvoices(
        InvoiceQueryParams()
          ..clientId = clientId
          ..branchId = branchId
          ..offset = _offset
          ..limit = pageSize,
      );
      _offset += result.data.length;
      if (result.data.length < pageSize) {
        _isLastPage = true;
      }
      emit(ReadInvoicePaymentsSuccess(result.data, result.count));
    } catch (error) {
      emit(ReadInvoicePaymentsError(error.toString()));
    }
  }

  Future<void> nextPage(String branchId) async {
    final clientId = _clientId;
    if (clientId == null || _isLastPage || _isFetching) return;

    final currentState = state;
    if (currentState is! ReadInvoicePaymentsSuccess) return;
    if (currentState is ReadInvoicePaymentsSearching) return;

    _isFetching = true;
    emit(ReadInvoicePaymentsSearching(currentState.invoices, currentState.totalCount));
    try {
      final result = await invoicesRepository.getAllInvoices(
        InvoiceQueryParams()
          ..clientId = clientId
          ..branchId = branchId
          ..offset = _offset
          ..limit = pageSize,
      );
      _offset += result.data.length;
      if (result.data.length < pageSize) {
        _isLastPage = true;
      }
      emit(
        ReadInvoicePaymentsSuccess(
          [...currentState.invoices, ...result.data],
          result.count,
        ),
      );
    } catch (error) {
      emit(ReadInvoicePaymentsError(error.toString()));
    } finally {
      _isFetching = false;
    }
  }
}
