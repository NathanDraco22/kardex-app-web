import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/models/order/order_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

import '../view_controller.dart';

part 'write_invoice_state.dart';

enum CommercialDocumentType {
  invoice,
  order,
  quote,
}

class WriteInvoiceCubit extends Cubit<WriteInvoiceState> {
  WriteInvoiceCubit({
    required this.invoicesRepository,
    required this.ordersRepository,
    this.documentType = CommercialDocumentType.invoice,
    required this.viewController,
  }) : super(WriteInvoiceInitial());

  final InvoicesRepository invoicesRepository;
  final OrdersRepository ordersRepository;

  final CommercialDocumentType documentType;

  final ClientInvoiceViewController viewController;

  bool get isOrder => documentType == CommercialDocumentType.order || documentType == CommercialDocumentType.quote;

  Future<void> createNewInvoice(
    CreateInvoice createInvoice,
    ClientInDb client,
  ) async {
    emit(WriteInvoiceInProgress());
    try {
      CreateInvoice currentInvoice = createInvoice;
      currentInvoice.ensureCostAndTotal();
      if (createInvoice.paymentType == PaymentType.cash) {
        final refreshedData = createInvoice.toJson();
        refreshedData['amountPaid'] = createInvoice.total;
        refreshedData['status'] = InvoiceStatus.paid.name;

        currentInvoice = CreateInvoice.fromJson(refreshedData);
      }

      if (isOrder) {
        final status = documentType == CommercialDocumentType.quote ? OrderStatus.draft : OrderStatus.open;
        final createOrder = CreateOrder(
          branchId: createInvoice.branchId,
          clientId: createInvoice.clientId,
          clientInfo: createInvoice.clientInfo,
          description: createInvoice.description,
          saleItems: createInvoice.saleItems,
          paymentType: createInvoice.paymentType,
          totalCost: createInvoice.totalCost,
          total: createInvoice.total,
          status: status,
          amountPaid: createInvoice.amountPaid,
          createdBy: createInvoice.createdBy,
        );

        await ordersRepository.createOrder(createOrder);
        emit(WriteInvoiceSuccess(null));
        emit(WriteInvoiceInitial());
        return;
      }

      final createdInvoice = await invoicesRepository.createInvoice(currentInvoice);
      emit(WriteInvoiceSuccess(createdInvoice));
      emit(WriteInvoiceInitial());
    } catch (error) {
      emit(WriteInvoiceError(error.toString()));
    }
  }

  Future<void> updateInvoice(String invoiceId, UpdateInvoice updateInvoice) async {
    emit(WriteInvoiceInProgress());
    try {
      final updatedInvoice = await invoicesRepository.updateInvoiceById(invoiceId, updateInvoice);
      emit(WriteInvoiceSuccess(updatedInvoice));
      emit(WriteInvoiceInitial());
    } catch (error) {
      emit(WriteInvoiceError(error.toString()));
    }
  }
}
