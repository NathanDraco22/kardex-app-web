import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/client_transaction/client_transaction.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/widgets/dialogs/devolution_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/invoice_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/receipt_viewer.dart';

class MovementMobileRow extends StatelessWidget {
  const MovementMobileRow({
    super.key,
    required this.currentTransaction,
    required this.rowColor,
  });

  final ClientTransactionInDb currentTransaction;
  final Color rowColor;

  @override
  Widget build(BuildContext context) {
    final amount = NumberFormatter.convertToMoneyLike(currentTransaction.amount);
    final balance = NumberFormatter.convertToMoneyLike(currentTransaction.resultBalance);

    final date = DateTimeTool.formatddMMyy(currentTransaction.createdAt);
    final time = DateTimeTool.formatHHmm(currentTransaction.createdAt);

    Widget icon = switch (currentTransaction.type) {
      (TransactionType.debit) => const Icon(
        FluentIcons.arrow_up_right_12_filled,
        color: Colors.red,
        size: 16,
      ),
      (TransactionType.credit) => const Icon(
        FluentIcons.arrow_down_left_12_filled,
        color: Colors.green,
        size: 16,
      ),
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        hoverColor: Colors.amber.shade100,
        onTap: () {
          switch (currentTransaction.subtype) {
            case TransactionSubType.invoice:
              showInvoiceViewerDialogFromId(context, currentTransaction.documentId);
              break;
            case TransactionSubType.receipt:
              showReceiptViewerDialogFromDocNumber(context, currentTransaction.docNumber);
              break;
            case TransactionSubType.devolution:
              showDevolutionViewerDialogFromId(context, currentTransaction.documentId);
              break;
            case TransactionSubType.discount:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Visor de descuentos no disponible")),
              );
              break;
          }
        },
        child: Ink(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: rowColor,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  spacing: 4,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    icon,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentTransaction.subtype.value, // Using extension equivalent or name
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "#${currentTransaction.docNumber}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  amount,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: currentTransaction.type == TransactionType.debit ? Colors.red : Colors.green,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  balance,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _TransactionSubTypeExt on TransactionSubType {
  String get value {
    switch (this) {
      case TransactionSubType.invoice:
        return "Factura";
      case TransactionSubType.receipt:
        return "Recibo";
      case TransactionSubType.devolution:
        return "Devolución";
      case TransactionSubType.discount:
        return "Descuento";
    }
  }
}
