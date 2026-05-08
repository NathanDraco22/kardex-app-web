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

  Widget _buildDetailRow(String label, int amount, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w400, color: Colors.grey[700]),
          ),
          Text(
            NumberFormatter.convertToMoneyLike(amount),
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetDevolution = devolutions.where((d) => d.originalInvoiceId == invoice.id).toList();
    final bool hasOpenDevolutions = targetDevolution.any((d) => d.status == DevolutionStatus.open);
    final bool hasConfirmedDevolutions =
        targetDevolution.isNotEmpty && targetDevolution.every((d) => d.status == DevolutionStatus.confirmed);
    final bool isDisabled = hasOpenDevolutions;

    final int devolutionsTotal = targetDevolution.fold(0, (sum, d) => sum + d.total);
    final int adjustedTotal = invoice.totalRemaining - devolutionsTotal;

    String docNumber = "#${invoice.docNumber}";
    if (docNumber.length > 12) {
      docNumber = docNumber.substring(0, 10);
    }

    Color? currentTileColor;

    if (isSelected) {
      currentTileColor = Colors.amber.shade100;
    } else {
      currentTileColor = tileColor;
    }

    return Ink(
      color: currentTileColor,
      child: InkWell(
        onLongPress: isDisabled ? null : () => onChanged(true),
        onTap: isDisabled ? null : () => onChanged(false),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: isSelected,
                onChanged: isDisabled ? null : onChanged,
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Factura $docNumber",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        PopupMenuButton<int>(
                          icon: const Icon(Icons.more_vert),
                          tooltip: "Ver detalles",
                          onSelected: (value) async {
                            if (value == 0) onViewInvoice();
                            if (value == 1) onViewDevolutions();
                            if (value == 2) onViewReceipts();
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 0,
                              child: Text("Ver Factura"),
                            ),
                            if (hasOpenDevolutions || hasConfirmedDevolutions)
                              const PopupMenuItem(
                                value: 1,
                                child: Text("Ver Devoluciones"),
                              ),
                            if (invoice.amountPaid > 0)
                              const PopupMenuItem(
                                value: 2,
                                child: Text("Ver Recibos"),
                              ),
                          ],
                        ),
                      ],
                    ),

                    _buildDetailRow("Total Factura:", invoice.total),
                    _buildDetailRow("Abonos:", invoice.amountPaid),
                    if (targetDevolution.isNotEmpty) _buildDetailRow("Devoluciones:", devolutionsTotal),

                    const Divider(height: 16),

                    _buildDetailRow(
                      "Restante a Pagar:",
                      adjustedTotal,
                      isBold: true,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
