import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kardex_app_front/admin_panel/widgets/pie_chart_row.dart';
import 'package:kardex_app_front/src/domain/models/executive_summary/executive_summary_in_db.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/color_tool.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

class ExecutiveSummaryDetailScreen extends StatelessWidget {
  const ExecutiveSummaryDetailScreen({super.key, required this.summary});

  final ExecutiveSummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Resumen Ejecutivo: ${DateTimeTool.formatddMM(
            DateTime.fromMillisecondsSinceEpoch(summary.startDate),
          )}",
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                _SummaryCard(summary: summary),
                const SizedBox(height: 12),

                // Sección Ventas
                const Text(
                  "Distribución de Ventas por Sucursal",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (summary.commercialBranches.isNotEmpty)
                  _SalesPieChartCard(summary: summary)
                else
                  const Center(child: Text("No hay datos de ventas por sucursal")),

                const SizedBox(height: 24),

                // Sección Inventario
                const Text(
                  "Distribución de Inventario por Sucursal",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (summary.inventoryBranches.isNotEmpty)
                  _InventoryPieChartCard(summary: summary)
                else
                  const Center(child: Text("No hay datos de inventario por sucursal")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SalesPieChartCard extends StatelessWidget {
  const _SalesPieChartCard({required this.summary});

  final ExecutiveSummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    final branches = summary.commercialBranches.map((branch) => BranchesTool.getBranchById(branch.branchId)).toList();

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
                  sections: List.generate(summary.commercialBranches.length, (i) {
                    final branch = summary.commercialBranches[i];
                    const fontSize = 16.0;
                    const radius = 50.0;
                    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

                    final percentage = summary.salesTotal > 0 ? (branch.total / summary.salesTotal) * 100 : 0.0;

                    return PieChartSectionData(
                      color: chartsColor[i % chartsColor.length],
                      value: branch.total.toDouble(),
                      title: '${percentage.toStringAsFixed(1)}%',
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
                children: List.generate(summary.commercialBranches.length, (i) {
                  final branchName = branches[i].name;
                  final branchDetail = summary.commercialBranches[i];
                  return PieChartRow(
                    title: branchName,
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

class _InventoryPieChartCard extends StatelessWidget {
  const _InventoryPieChartCard({required this.summary});

  final ExecutiveSummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    final branches = summary.inventoryBranches.map((branch) => BranchesTool.getBranchById(branch.branchId)).toList();

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
                  sections: List.generate(summary.inventoryBranches.length, (i) {
                    final branch = summary.inventoryBranches[i];
                    const fontSize = 16.0;
                    const radius = 50.0;
                    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

                    final percentage = summary.inventoryTotalCost > 0
                        ? (branch.inventoryTotalCost / summary.inventoryTotalCost) * 100
                        : 0.0;

                    return PieChartSectionData(
                      color: chartsColor[i % chartsColor.length],
                      value: branch.inventoryTotalCost.toDouble(),
                      title: '${percentage.toStringAsFixed(1)}%',
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
                children: List.generate(summary.inventoryBranches.length, (i) {
                  final branchName = branches[i].name;
                  final branchDetail = summary.inventoryBranches[i];
                  return PieChartRow(
                    title: branchName,
                    subtitle: NumberFormatter.convertToMoneyLike(branchDetail.inventoryTotalCost),
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

  final ExecutiveSummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _RowInfo("Ventas Totales", NumberFormatter.convertToMoneyLike(summary.salesTotal)),
            const Divider(),
            _RowInfo("Costo Ventas", NumberFormatter.convertToMoneyLike(summary.salesTotalCost)),
            const Divider(),
            _RowInfo("Ganancia", NumberFormatter.convertToMoneyLike(summary.salesTotal - summary.salesTotalCost)),
            const Divider(),
            _RowInfo("Valor Inventario", NumberFormatter.convertToMoneyLike(summary.inventoryTotalCost)),
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
