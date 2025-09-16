import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'read_invoice_state.dart';

class ReadPendingInvoiceCubit extends Cubit<ReadInvoiceState> {
  ReadPendingInvoiceCubit({required this.invoicesRepository}) : super(ReadInvoiceInitial());

  final InvoicesRepository invoicesRepository;

  bool isLastPage = false;
  List<InvoiceInDb> _invoicesCache = [];

  Future<void> loadPaginatedInvoices(String clientId) async {
    emit(ReadInvoiceLoading());
    try {
      final response = await invoicesRepository.getPendingInvoices(
        clientId,
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
}
