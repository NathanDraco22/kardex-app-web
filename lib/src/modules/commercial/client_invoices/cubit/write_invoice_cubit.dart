import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/models/common/client_info.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/models/order/order_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';

part 'write_invoice_state.dart';

class WriteInvoiceCubit extends Cubit<WriteInvoiceState> {
  WriteInvoiceCubit({
    required this.invoicesRepository,
    required this.ordersRepository,
    this.isOrder = false,
  }) : super(WriteInvoiceInitial());

  final InvoicesRepository invoicesRepository;
  final OrdersRepository ordersRepository;

  final bool isOrder;

  Future<void> createNewInvoice(CreateInvoice createInvoice, ClientInDb client) async {
    emit(WriteInvoiceInProgress());
    try {
      CreateInvoice currentInvoice = createInvoice;
      if (createInvoice.paymentType == PaymentType.cash) {
        final refreshedData = createInvoice.toJson();
        refreshedData['amountPaid'] = createInvoice.total;
        refreshedData['status'] = InvoiceStatus.paid.name;

        currentInvoice = CreateInvoice.fromJson(refreshedData);
      }

      if (isOrder) {
        final createOrder = CreateOrder(
          branchId: BranchesTool.getCurrentBranchId(),
          clientId: createInvoice.clientId,
          clientInfo: ClientInfo(
            name: client.name,
          ),
          description: createInvoice.description,
          saleItems: createInvoice.saleItems,
          paymentType: createInvoice.paymentType,
          totalCost: createInvoice.totalCost,
          total: createInvoice.total,
          status: OrderStatus.open,
          amountPaid: createInvoice.amountPaid,
        );

        await ordersRepository.createOrder(createOrder);
        emit(WriteInvoiceSuccess());
        emit(WriteInvoiceInitial());
        return;
      }

      await invoicesRepository.createInvoice(currentInvoice);
      emit(WriteInvoiceSuccess());
      emit(WriteInvoiceInitial());
    } catch (error) {
      emit(WriteInvoiceError(error.toString()));
    }
  }

  Future<void> updateInvoice(String invoiceId, UpdateInvoice updateInvoice) async {
    emit(WriteInvoiceInProgress());
    try {
      await invoicesRepository.updateInvoiceById(invoiceId, updateInvoice);
      emit(WriteInvoiceSuccess());
      emit(WriteInvoiceInitial());
    } catch (error) {
      emit(WriteInvoiceError(error.toString()));
    }
  }
}
