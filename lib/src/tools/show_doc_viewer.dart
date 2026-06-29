import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/adjust_entry_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/adjust_exit_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/devolution_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/invoice_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/transfer_viewer.dart';

Future<void> showDocumentViewer(BuildContext context, ProductTransactionInDb currentTransaction) async {
  switch (currentTransaction.subtype) {
    case TransactionSubType.entry:
      break;
    case TransactionSubType.exit:
      break;
    case TransactionSubType.invoice:
      await showInvoiceViewerDialogFromDocNumber(context, currentTransaction.docNumber);
      break;
    case TransactionSubType.devolution:
      showDevolutionViewerDialogFromId(context, currentTransaction.documentId);
      break;
    case TransactionSubType.transfer:
      showTransferViewerDialogFromId(context, currentTransaction.documentId);
      break;
    case TransactionSubType.adjustment:
      if (currentTransaction.type == .exit) {
        showAdjustExitViewerDialogFromId(context, currentTransaction.documentId);
      } else {
        showAdjustEntryViewerDialogFromId(context, currentTransaction.documentId);
      }
      break;
    case TransactionSubType.loss:
      showAdjustExitViewerDialogFromId(context, currentTransaction.documentId);
      break;
  }
}
