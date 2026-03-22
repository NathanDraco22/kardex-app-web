import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kardex_app_front/admin_panel/widgets/pie_chart_row.dart';
import 'package:kardex_app_front/src/domain/models/daily_summary/daily_summary_in_db.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/color_tool.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

class DailySummaryDetailScreen extends StatelessWidget {
  const DailySummaryDetailScreen({super.key, required this.summary});

  final DailySummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Resumen: ${DateTimeTool.formatddMM(
            DateTime.fromMillisecondsSinceEpoch(summary.startDate),
          )}",
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 64),
            children: [
              _SalesCard(summary: summary),
              const SizedBox(height: 12),
              const Text(
                "Ventas por Sucursal",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (summary.branches.isNotEmpty)
                PieChartCard(summary: summary)
              else
                const Center(child: Text("No hay datos de sucursales")),
              const SizedBox(height: 12),
              _CashFlowCard(summary: summary),
              const SizedBox(height: 12),
              _OtherStatsCard(summary: summary),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class PieChartCard extends StatelessWidget {
  const PieChartCard({
    super.key,
    required this.summary,
  });

  final DailySummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    final branches = summary.branches
        .map(
          (branch) => BranchesTool.getBranchById(branch.branchId),
        )
        .toList();

    final chartsColor = ColorTool.getChartColors();
    return Card(
      child: SizedBox(
        height: 250,
        child: Row(
          children: [
            Flexible(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: List.generate(summary.branches.length, (i) {
                    final branch = summary.branches[i];
                    const fontSize = 16.0;
                    const radius = 50.0;
                    const shadows = [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 2,
                      ),
                    ];
                    return PieChartSectionData(
                      color: chartsColor[i % chartsColor.length],
                      value: branch.total.toDouble(),
                      title: '${((branch.total / summary.total) * 100).toStringAsFixed(1)}%',
                      radius: radius,
                      titleStyle: const TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: shadows,
                      ),
                    );
                  }),
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: List.generate(summary.branches.length, (i) {
                  final branch = branches[i];
                  final branchDetail = summary.branches[i];
                  return PieChartRow(
                    title: branch.name,
                    subtitle: NumberFormatter.convertToMoneyLike(branchDetail.total),
                    color: chartsColor[i % chartsColor.length],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SalesCard extends StatelessWidget {
  const _SalesCard({required this.summary});

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
          children: [
            const Text("Resumen de Ventas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _RowInfo("Ventas al Contado", NumberFormatter.convertToMoneyLike(summary.cashSales)),
            const Divider(),
            _RowInfo("Ventas a Crédito", NumberFormatter.convertToMoneyLike(summary.creditSales)),
            const Divider(),
            _RowInfo("Total Ventas", NumberFormatter.convertToMoneyLike(summary.total)),
            const Divider(),
            _RowInfo("Costo Ventas", NumberFormatter.convertToMoneyLike(summary.totalCost)),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Ganancia Estimada", style: TextStyle(fontSize: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isProfit ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      NumberFormatter.convertToMoneyLike(ganancia),
                      style: TextStyle(
                        fontSize: 16,
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

class _CashFlowCard extends StatelessWidget {
  const _CashFlowCard({required this.summary});

  final DailySummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    final totalIngresoCaja = summary.cashSales + summary.totalReceiptCash;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Flujo de Caja", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _RowInfo("Ventas al Contado", NumberFormatter.convertToMoneyLike(summary.cashSales)),
            const Divider(),
            _RowInfo("Recaudación Efectivo (Recibos)", NumberFormatter.convertToMoneyLike(summary.totalReceiptCash)),
            const Divider(),
            _RowInfo(
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

class _OtherStatsCard extends StatelessWidget {
  const _OtherStatsCard({required this.summary});

  final DailySummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Otros Datos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _RowInfo("Total de Abonos (Facturas)", NumberFormatter.convertToMoneyLike(summary.totalPaid)),
            const Divider(),
            _RowInfo(
              "CxC Generado",
              NumberFormatter.convertToMoneyLike(summary.totalOwed),
              isHighlight: true,
            ),
            const Divider(),
            _RowInfo("Total en Recibos", NumberFormatter.convertToMoneyLike(summary.totalReceipts)),
            const Divider(),
            _RowInfo(
              "Devoluciones Aplicadas (Recibos)",
              NumberFormatter.convertToMoneyLike(summary.totalReceiptDevolutions),
            ),
            const Divider(),
            _RowInfo("Total Facturas Emitidas", summary.totalInvoices.toString()),
            const Divider(),
            _RowInfo("Cantidad Recibos Emitidos", summary.receiptCount.toString()),
          ],
        ),
      ),
    );
  }
}

class _RowInfo extends StatelessWidget {
  const _RowInfo(this.label, this.value, {this.isHighlight = false});

  final String label;
  final String value;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
