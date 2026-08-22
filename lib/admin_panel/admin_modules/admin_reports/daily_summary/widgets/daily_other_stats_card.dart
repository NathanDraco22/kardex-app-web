import 'package:flutter/material.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/range_executive_report/widgets/report_row_info.dart';
import 'package:kardex_business/kardex_business.dart';

class DailyOtherStatsCard extends StatelessWidget {
  const DailyOtherStatsCard({
    super.key,
    required this.summary,
  });

  final DailySummaryInDb summary;

  @override
  Widget build(BuildContext context) {
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
                Icon(Icons.query_stats_rounded, color: Colors.indigo.shade600),
                const SizedBox(width: 8),
                const Text(
                  "Otros Datos y Métricas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ReportRowInfo("Total de Abonos (Facturas)", NumberFormatter.convertToMoneyLike(summary.totalPaid)),
            const Divider(),
            ReportRowInfo(
              "CxC Generado",
              NumberFormatter.convertToMoneyLike(summary.totalOwed),
              isHighlight: true,
            ),
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
