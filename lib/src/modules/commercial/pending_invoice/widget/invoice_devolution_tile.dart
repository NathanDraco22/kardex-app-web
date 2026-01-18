import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

class InvoiceDevolutionTile extends StatelessWidget {
  const InvoiceDevolutionTile({
    super.key,
    required this.invoice,
    required this.devolutions,
    required this.isSelected,
    required this.onChanged,
    required this.onViewInvoice,
    required this.onViewDevolutions,
    required this.onViewReceipts,
    this.tileColor,
  });

  final InvoiceInDb invoice;
  final List<DevolutionInDb> devolutions;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onViewInvoice;
  final VoidCallback onViewDevolutions;
  final VoidCallback onViewReceipts;
  final Color? tileColor;

  @override
  Widget build(BuildContext context) {
    final targetDevolution = devolutions.where((d) => d.originalInvoiceId == invoice.id).toList();
    final bool hasOpenDevolutions = targetDevolution.any((d) => d.status == DevolutionStatus.open);
    final bool hasConfirmedDevolutions =
        targetDevolution.isNotEmpty && targetDevolution.every((d) => d.status == DevolutionStatus.confirmed);
    final bool isDisabled = hasOpenDevolutions;

    final int devolutionsTotal = targetDevolution.fold(0, (sum, d) => sum + d.total);
    final int adjustedTotal = invoice.totalRemaining - devolutionsTotal;

    return Ink(
      color: tileColor,

      child: InkWell(
        onTap: isDisabled ? null : () => onChanged(!isSelected),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: isSelected,
              onChanged: isDisabled ? null : onChanged,
            ),
            Column(
              children: [
                TextButton(
                  onPressed: onViewInvoice,
                  child: const Text("Ver factura"),
                ),

                Builder(
                  builder: (context) {
                    void Function()? onPressed;

                    if (hasOpenDevolutions || hasConfirmedDevolutions) {
                      onPressed = () => onViewDevolutions();
                    }

                    return TextButton(
                      onPressed: onPressed,
                      child: const Text("Devoluciones"),
                    );
                  },
                ),
                Builder(
                  builder: (context) {
                    void Function()? onPressed;

                    if (invoice.amountPaid > 0) {
                      onPressed = () => onViewReceipts();
                    }

                    return TextButton(
                      onPressed: onPressed,
                      child: const Text("Recibos"),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(width: 16),

            // --- Contenido Principal (antes 'title' y 'subtitle') ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Fact#${invoice.docNumber}",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  if (targetDevolution.isNotEmpty)
                    Text(
                      '${NumberFormatter.convertToMoneyLike(invoice.totalRemaining)} - ${NumberFormatter.convertToMoneyLike(devolutionsTotal)} = ${NumberFormatter.convertToMoneyLike(adjustedTotal)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Text(
                      NumberFormatter.convertToMoneyLike(invoice.totalRemaining),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // --- Checkbox (antes el 'trailing') ---
          ],
        ),
      ),
    );
  }
}
