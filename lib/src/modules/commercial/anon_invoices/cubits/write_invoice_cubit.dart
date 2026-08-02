import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';
import '../view_controller.dart';

part 'write_invoice_state.dart';

class WriteAnonInvoiceCubit extends Cubit<WriteAnonInvoiceState> {
  WriteAnonInvoiceCubit({
    required this.invoicesRepository,
    required this.viewController,
    this.isOrder = false,
  }) : super(WriteAnonInvoiceInitial());

  final InvoicesRepository invoicesRepository;
  final AnonInvoiceViewController viewController;

  final bool isOrder;

  Future<void> createNewAnonInvoice(CreateInvoice createInvoice) async {
    emit(WriteAnonInvoiceInProgress());
    try {
      if (createInvoice.clientId != kSaleClientId) {
        emit(WriteAnonInvoiceError('El cliente no es válido'));
        return;
      }

      CreateInvoice currentInvoice = createInvoice;
      currentInvoice.ensureCostAndTotal();

      final invoice = await invoicesRepository.createInvoice(currentInvoice);
      emit(WriteAnonInvoiceSuccess(invoice));
      emit(WriteAnonInvoiceInitial());
    } catch (error) {
      emit(WriteAnonInvoiceError(error.toString()));
    }
  }
}
