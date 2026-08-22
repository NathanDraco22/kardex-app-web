import 'package:flutter/material.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/range_executive_report/widgets/report_row_info.dart';
import 'package:kardex_business/kardex_business.dart';

class DailySalesSummaryCard extends StatelessWidget {
  const DailySalesSummaryCard({
    super.key,
    required this.summary,
  });

  final DailySummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    final ganancia = summary.total - summary.totalCost;
    final isProfit = ganancia >= 0;

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
                Icon(Icons.point_of_sale_rounded, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  "Resumen de Ventas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ReportRowInfo("Ventas al Contado", NumberFormatter.convertToMoneyLike(summary.cashSales)),
            const Divider(),
            ReportRowInfo("Ventas a Crédito", NumberFormatter.convertToMoneyLike(summary.creditSales)),
            const Divider(),
            ReportRowInfo("Total Ventas", NumberFormatter.convertToMoneyLike(summary.total)),
            const Divider(),
            ReportRowInfo("Costo Ventas", NumberFormatter.convertToMoneyLike(summary.totalCost)),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Ganancia Estimada", style: TextStyle(fontSize: 15)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isProfit
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      NumberFormatter.convertToMoneyLike(ganancia),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isProfit ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
