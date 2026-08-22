import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/cubit/write_terminal_invoice_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/widgets/terminal_payment_confirmation_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';

Future<void> startTerminalPayment(BuildContext context) async {
  final viewController = context.read<WriteTerminalInvoiceCubit>().viewController;
  if (viewController.items.isEmpty) return;

  if (viewController.hasItemsWithZeroQuantity) {
    await DialogManager.showInfoDialog(
      context,
      "Hay productos sin cantidad. Revisa la venta antes de cobrar.",
    );
    viewController.requestSearchFocus();
    return;
  }

  if (viewController.hasZeroPriceItems) {
    await DialogManager.showErrorDialog(
      context,
      "No se puede cobrar porque hay productos con precio en 0. Por favor, edita o elimina estos productos.",
    );
    viewController.requestSearchFocus();
    return;
  }

  final createInvoice = viewController.generateCreateInvoice();
  if (createInvoice == null) {
    viewController.requestSearchFocus();
    return;
  }

  final hasCredit = viewController.selectedClient?.isCreditActive ?? false;
  final paymentResult = await showTerminalPaymentConfirmationDialog(
    context,
    createInvoice.total,
    showCredit: hasCredit,
    initialMethod: viewController.selectedPaymentType,
    initialObservations: viewController.description,
  );
  if (paymentResult == null) {
    viewController.requestSearchFocus();
    return;
  }
  if (!context.mounted) return;

  viewController.description = paymentResult.observations ?? '';
  final invoice = viewController.generateCreateInvoice();
  if (invoice == null) return;

  final finalInvoice = invoice.copyWithPaymentMethod(
    paymentResult.method,
    paymentResult.reference,
  );

  context.read<WriteTerminalInvoiceCubit>().createSaleInvoice(finalInvoice);
}
