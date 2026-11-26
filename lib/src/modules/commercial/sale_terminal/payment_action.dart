import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/core/access_manager.dart';
import 'package:kardex_app_front/src/core/shift_guard.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/cubit/write_terminal_invoice_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/widgets/terminal_payment_confirmation_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_business/kardex_business.dart';

Future<void> startTerminalPayment(BuildContext context) async {
  final viewController = context.read<WriteTerminalInvoiceCubit>().viewController;
  if (viewController.items.isEmpty) return;

  if (viewController.hasItemsWithZeroBaseQuantity) {
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

  if (!await ShiftGuard.ensureShiftReady(context)) {
    viewController.requestSearchFocus();
    return;
  }
  if (!context.mounted) return;

  final canCredit = AccessManager().hasCurrentCapability(
    RoleCapability.allowCreditInvoicing,
  );
  final hasCredit = (viewController.selectedClient?.isCreditActive ?? false) && canCredit;
  final initialMethod = (!hasCredit && viewController.selectedPaymentType == PaymentType.credit)
      ? PaymentType.cash
      : viewController.selectedPaymentType;
  final paymentResult = await showTerminalPaymentConfirmationDialog(
    context,
    createInvoice.total,
    showCredit: hasCredit,
    initialMethod: initialMethod,
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
    paymentDetail: paymentResult.paymentDetail,
  );

  context.read<WriteTerminalInvoiceCubit>().createSaleInvoice(finalInvoice);
}
