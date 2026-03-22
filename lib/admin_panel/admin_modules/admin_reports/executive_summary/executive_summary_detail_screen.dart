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
              padding: const EdgeInsets.only(bottom: 64),
              children: [
                _SalesCard(summary: summary),
                const SizedBox(height: 12),
                if (summary.commercialBranches.isNotEmpty) ...[
                  const Text(
                    "Ventas por Sucursal",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _SalesPieChartCard(summary: summary),
                ],
                const SizedBox(height: 24),

                _CashFlowCard(summary: summary),
                const SizedBox(height: 12),
                if (summary.commercialBranches.isNotEmpty) ...[
                  const Text(
                    "Flujo de Caja por Sucursal",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _CashFlowChartCard(summary: summary),
                ],
                const SizedBox(height: 24),

                _OtherStatsCard(summary: summary),
                const SizedBox(height: 12),
                if (summary.inventoryBranches.isNotEmpty) ...[
                  const Text(
                    "Inventario por Sucursal",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _InventoryPieChartCard(summary: summary),
                ],
                const SizedBox(height: 12),
                if (summary.totalPendingBranches.isNotEmpty) ...[
                  const Text(
                    "CxC por Sucursal",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _DebtPieChartCard(summary: summary),
                ],
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

class _DebtPieChartCard extends StatelessWidget {
  const _DebtPieChartCard({required this.summary});

  final ExecutiveSummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    final branches = summary.totalPendingBranches.map((branch) => BranchesTool.getBranchById(branch.branchId)).toList();

    final chartsColor = ColorTool.getChartColors();
    final double totalOwedAllBranches = summary.totalPendingBranches.fold(
      0.0,
      (prev, element) => prev + element.totalOwed,
    );

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
                  sections: List.generate(summary.totalPendingBranches.length, (i) {
                    final branch = summary.totalPendingBranches[i];
                    const fontSize = 16.0;
                    const radius = 50.0;
                    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

                    final percentage = totalOwedAllBranches > 0 ? (branch.totalOwed / totalOwedAllBranches) * 100 : 0.0;

                    return PieChartSectionData(
                      color: chartsColor[i % chartsColor.length],
                      value: branch.totalOwed.toDouble(),
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
                children: List.generate(summary.totalPendingBranches.length, (i) {
                  final branchName = branches[i].name;
                  final branchDetail = summary.totalPendingBranches[i];
                  return PieChartRow(
                    title: branchName,
                    subtitle: NumberFormatter.convertToMoneyLike(branchDetail.totalOwed),
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

  final ExecutiveSummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    final ganancia = summary.salesTotal - summary.salesTotalCost;
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
            _RowInfo("Ventas Totales", NumberFormatter.convertToMoneyLike(summary.salesTotal)),
            const Divider(),
            _RowInfo("Costo Ventas", NumberFormatter.convertToMoneyLike(summary.salesTotalCost)),
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
          children: [
            const Text("Otros Datos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _RowInfo(
              "Valor Inventario Total",
              NumberFormatter.convertToMoneyLike(summary.inventoryTotalCost),
              isHighlight: true,
            ),
            const Divider(),
            _RowInfo(
              "Total Cuentas por Cobrar",
              NumberFormatter.convertToMoneyLike(totalOwed.toInt()),
              isHighlight: true,
            ),
            const Divider(),
            _RowInfo("Facturas Pendientes", summary.totalPendingInvoices.toString()),
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

class _CashFlowChartCard extends StatelessWidget {
  const _CashFlowChartCard({required this.summary});

  final ExecutiveSummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    if (summary.commercialBranches.isEmpty) return const SizedBox();

    final chartsColor = ColorTool.getChartColors();

    double maxVal = 0;
    for (final branch in summary.commercialBranches) {
      final cashFlow = branch.cashSales + branch.totalReceiptCash;
      if (cashFlow > maxVal) maxVal = cashFlow.toDouble();
    }
    if (maxVal == 0) maxVal = 1000;

    final barGroups = <BarChartGroupData>[];
    int index = 0;
    for (final branch in summary.commercialBranches) {
      final cashFlow = (branch.cashSales + branch.totalReceiptCash).toDouble();

      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: cashFlow,
              color: chartsColor[index % chartsColor.length],
              width: 22,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      index++;
    }

    return Card(
      child: SizedBox(
        height: 250,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxVal * 1.2,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => Colors.blueGrey,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final bInfo = BranchesTool.getBranchById(
                            summary.commercialBranches[group.x.toInt()].branchId,
                          );
                          return BarTooltipItem(
                            "${bInfo.name}\n${NumberFormatter.convertToMoneyLike(rod.toY.toInt())}",
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= summary.commercialBranches.length) return const SizedBox();
                            final bName = BranchesTool.getBranchById(summary.commercialBranches[idx].branchId).name;
                            final parts = bName.split(" ");
                            final shortName = parts.isNotEmpty ? parts[0] : bName;

                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                shortName,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: barGroups,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
