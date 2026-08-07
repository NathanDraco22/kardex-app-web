import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

import '../view_controller.dart';

part 'write_terminal_invoice_state.dart';

class WriteTerminalInvoiceCubit extends Cubit<WriteTerminalInvoiceState> {
  WriteTerminalInvoiceCubit({
    required this.invoicesRepository,
    required this.viewController,
  }) : super(WriteTerminalInvoiceInitial());

  final InvoicesRepository invoicesRepository;
  final SaleTerminalViewController viewController;

  Future<void> createSaleInvoice(CreateInvoice createInvoice) async {
    emit(WriteTerminalInvoiceInProgress());
    try {
      CreateInvoice currentInvoice = createInvoice;
      currentInvoice.ensureCostAndTotal();
      if (createInvoice.paymentType != PaymentType.credit) {
        final refreshedData = createInvoice.toJson();
        refreshedData['amountPaid'] = createInvoice.total;
        refreshedData['status'] = InvoiceStatus.paid.name;
        currentInvoice = CreateInvoice.fromJson(refreshedData);
      }

      final invoice = await invoicesRepository.createInvoice(currentInvoice);
      emit(WriteTerminalInvoiceSuccess(invoice));
      emit(WriteTerminalInvoiceInitial());
    } catch (error) {
      emit(WriteTerminalInvoiceError(error.toString()));
    }
  }
}
