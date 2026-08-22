import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'report_row_info.dart';

class CashFlowSummaryCard extends StatelessWidget {
  const CashFlowSummaryCard({
    super.key,
    required this.summary,
  });

  final ExecutiveSummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    final totalIngresoCaja = summary.cashSales + summary.totalReceiptCash;

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
                Icon(Icons.payments_rounded, color: Colors.green.shade700),
                const SizedBox(width: 8),
                const Text(
                  "Flujo de Caja",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ReportRowInfo("Ventas al Contado", NumberFormatter.convertToMoneyLike(summary.cashSales)),
            const Divider(),
            ReportRowInfo(
              "Recaudación Efectivo (Recibos)",
              NumberFormatter.convertToMoneyLike(summary.totalReceiptCash),
            ),
            const Divider(),
            ReportRowInfo(
              "Total Ingreso en Caja",
              NumberFormatter.convertToMoneyLike(totalIngresoCaja),
              isHighlight: true,
            ),
          ],
        ),
      ),
    );
  }
}
