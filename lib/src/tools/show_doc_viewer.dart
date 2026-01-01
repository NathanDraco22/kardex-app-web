import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/product_transaction/product_transaction.dart';
import 'package:kardex_app_front/widgets/dialogs/adjust_entry_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/adjust_exit_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/devolution_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/entry_history_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/exit_history_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/invoice_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/transfer_viewer.dart';

Future<void> showDocumentViewer(BuildContext context, ProductTransactionInDb currentTransaction) async {
  switch (currentTransaction.subtype) {
    case TransactionSubType.entry:
      await showEntryHistoryViewerDialogFromId(context, currentTransaction.documentId);
      break;
    case TransactionSubType.exit:
      await showExitHistoryViewerDialogFromId(context, currentTransaction.documentId);
      break;
    case TransactionSubType.invoice:
      await showInvoiceViewerDialogFromId(context, currentTransaction.documentId);
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
