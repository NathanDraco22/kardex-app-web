import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'report_row_info.dart';

class OtherStatsCard extends StatelessWidget {
  const OtherStatsCard({
    super.key,
    required this.summary,
  });

  final ExecutiveSummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    final double totalOwed = summary.totalPendingBranches.fold(
      0.0,
      (prev, element) => prev + element.totalOwed,
    );

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2_rounded, color: Colors.indigo.shade600),
                const SizedBox(width: 8),
                const Text(
                  "Otros Datos y Métricas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ReportRowInfo(
              "Valor Inventario Total",
              NumberFormatter.convertToMoneyLike(summary.inventoryTotalCost),
              isHighlight: true,
            ),
            const Divider(),
            ReportRowInfo(
              "Total Cuentas por Cobrar",
              NumberFormatter.convertToMoneyLike(totalOwed.toInt()),
              isHighlight: true,
            ),
            const Divider(),
            ReportRowInfo("Facturas Pendientes", summary.totalPendingInvoices.toString()),
            const Divider(),
            ReportRowInfo("Total en Recibos", NumberFormatter.convertToMoneyLike(summary.totalReceipts)),
            const Divider(),
            ReportRowInfo(
              "Devoluciones Aplicadas (Recibos)",
              NumberFormatter.convertToMoneyLike(summary.totalReceiptDevolutions),
            ),
            const Divider(),
            ReportRowInfo("Total Facturas Emitidas", summary.totalInvoices.toString()),
            const Divider(),
            ReportRowInfo("Cantidad Recibos Emitidos", summary.receiptCount.toString()),
          ],
        ),
      ),
    );
  }
}
