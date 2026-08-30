import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/core/terminal_draft_manager.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/cubit/read_terminal_product_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/cubit/write_terminal_invoice_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/invoice_viewer.dart';
import 'package:kardex_business/kardex_business.dart';

Future<void> handleTerminalSaleCompletion(BuildContext context, InvoiceInDb invoice) async {
  final viewController = context.read<WriteTerminalInvoiceCubit>().viewController;
  final draftId = viewController.currentDraftId;
  final authState = getIt<AuthCubit>().state;

  if (draftId != null && authState is Authenticated) {
    await SaleTerminalDraftManager().removeDraft(authState.branch.id, draftId);
  }

  if (context.mounted) {
    context.read<ReadTerminalProductCubit>().loadProducts();
    if (Scaffold.of(context).hasEndDrawer) {
      Scaffold.of(context).closeEndDrawer();
    }
  }

  if (!context.mounted) return;
  await showInvoiceViewerDialog(context, invoice);

  viewController.clear();
}
