import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'read_invoice_state.dart';

class ReadInvoiceCubit extends Cubit<ReadInvoiceState> {
  ReadInvoiceCubit({required this.invoicesRepository}) : super(ReadInvoiceInitial());

  final InvoicesRepository invoicesRepository;

  bool isLastPage = false;
  List<InvoiceInDb> _invoicesCache = [];

  String? clientId;
  String? startDate;
  String? endDate;

  Future<void> loadPaginatedInvoices() async {
    emit(ReadInvoiceLoading());
    try {
      final response = await invoicesRepository.getInvoicesByClientId(
        clientId ?? '',
      );

      _invoicesCache = response.data;
      if (_invoicesCache.length >= response.count) {
        isLastPage = true;
      } else {
        isLastPage = false;
      }
      if (isClosed) return;
      emit(ReadInvoiceSuccess(_invoicesCache, response.count));
    } catch (error) {
      if (isClosed) return;
      emit(ReadInvoiceError(error.toString()));
    }
  }

  Future<void> getNextPage() async {
    if (isLastPage) return;
    try {
      final response = await invoicesRepository.getInvoicesByClientId(clientId ?? '');

      _invoicesCache.addAll(response.data);
      if (_invoicesCache.length >= response.count) {
        isLastPage = true;
      }
      if (isClosed) return;
      emit(ReadInvoiceSuccess(_invoicesCache, response.count));
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> setFilterParams({
    String? clientId,
    String? startDate,
    String? endDate,
  }) async {
    this.clientId = clientId;
    this.startDate = startDate;
    this.endDate = endDate;
    _invoicesCache = [];
    isLastPage = false;
  }

  Future<void> clearFilterParams() async {
    clientId = null;
    startDate = null;
    endDate = null;
    _invoicesCache = [];
    isLastPage = false;
    loadPaginatedInvoices();
  }
}
