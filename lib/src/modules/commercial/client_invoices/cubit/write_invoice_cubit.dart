import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'write_invoice_state.dart';

class WriteInvoiceCubit extends Cubit<WriteInvoiceState> {
  WriteInvoiceCubit({required this.invoicesRepository}) : super(WriteInvoiceInitial());

  final InvoicesRepository invoicesRepository;

  Future<void> createNewInvoice(CreateInvoice createInvoice) async {
    emit(WriteInvoiceInProgress());
    try {
      final invoice = await invoicesRepository.createInvoice(createInvoice);
      emit(WriteInvoiceSuccess(invoice));
      emit(WriteInvoiceInitial());
    } catch (error) {
      emit(WriteInvoiceError(error.toString()));
    }
  }

  Future<void> updateInvoice(String invoiceId, UpdateInvoice updateInvoice) async {
    emit(WriteInvoiceInProgress());
    try {
      final invoice = await invoicesRepository.updateInvoiceById(invoiceId, updateInvoice);
      emit(WriteInvoiceSuccess(invoice!));
      emit(WriteInvoiceInitial());
    } catch (error) {
      emit(WriteInvoiceError(error.toString()));
    }
  }
}
