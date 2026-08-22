import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'report_row_info.dart';

class ExpensesSummaryCard extends StatelessWidget {
  const ExpensesSummaryCard({
    super.key,
    required this.summary,
  });

  final ExecutiveSummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.withValues(alpha: 0.05),
              Colors.orange.withValues(alpha: 0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.trending_down_rounded, color: Colors.orange.shade800),
                const SizedBox(width: 8),
                const Text(
                  "Resumen de Gastos / Egresos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ReportRowInfo("Gastos Totales", NumberFormatter.convertToMoneyLike(summary.expensesTotal)),
            const Divider(),
            ReportRowInfo("Gastos Pagados", NumberFormatter.convertToMoneyLike(summary.expensesPaid)),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Gastos Pendientes (Por Pagar)", style: TextStyle(fontSize: 15)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      NumberFormatter.convertToMoneyLike(summary.expensesOwed),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[900],
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
