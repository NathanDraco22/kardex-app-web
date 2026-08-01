import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/cubit/write_terminal_invoice_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/invoice_viewer.dart';
import 'package:kardex_business/kardex_business.dart';

Future<void> handleTerminalSaleCompletion(BuildContext context, InvoiceInDb invoice) async {
  await showInvoiceViewerDialog(context, invoice);

  if (!context.mounted) return;
  context.read<WriteTerminalInvoiceCubit>().viewController.clear();
}
