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
            children: [
              _SummaryCard(summary: summary),
              const SizedBox(height: 12),
              const Text(
                "Distribución por Sucursal",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (summary.branches.isNotEmpty)
                PieChartCard(summary: summary)
              else
                const Center(child: Text("No hay datos de sucursales")),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final DailySummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _RowInfo("Ventas Totales", NumberFormatter.convertToMoneyLike(summary.total)),
            const Divider(),
            _RowInfo("Costo Total", NumberFormatter.convertToMoneyLike(summary.totalCost)),
            const Divider(),
            _RowInfo("Ganancia", NumberFormatter.convertToMoneyLike(summary.total - summary.totalCost)),
            const Divider(),
            _RowInfo("Total Facturas", summary.totalInvoices.toString()),
          ],
        ),
      ),
    );
  }
}

class _RowInfo extends StatelessWidget {
  const _RowInfo(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
