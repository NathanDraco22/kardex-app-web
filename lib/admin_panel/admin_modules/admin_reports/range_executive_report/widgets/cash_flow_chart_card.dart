import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/tools/color_tool.dart';
import 'package:kardex_business/kardex_business.dart';

class CashFlowChartCard extends StatelessWidget {
  const CashFlowChartCard({
    super.key,
    required this.summary,
  });

  final ExecutiveSummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    if (summary.commercialBranches.isEmpty) {
      return const SizedBox.shrink();
    }

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
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart_rounded, color: Colors.green.shade700),
                const SizedBox(width: 8),
                const Text(
                  "Flujo de Caja por Sucursal",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxVal * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.blueGrey.shade800,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final bInfo = getIt<AuthCubit>().getBranchById(
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
                          if (idx < 0 || idx >= summary.commercialBranches.length) {
                            return const SizedBox();
                          }
                          final bName = getIt<AuthCubit>()
                              .getBranchById(summary.commercialBranches[idx].branchId)
                              .name;
                          final parts = bName.split(" ");
                          final shortName = parts.isNotEmpty ? parts[0] : bName;

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              shortName,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
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
    );
  }
}
