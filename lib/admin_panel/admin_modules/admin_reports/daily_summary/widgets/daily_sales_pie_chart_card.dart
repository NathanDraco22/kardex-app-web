import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kardex_app_front/admin_panel/widgets/pie_chart_row.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/tools/color_tool.dart';
import 'package:kardex_business/kardex_business.dart';

class DailySalesPieChartCard extends StatelessWidget {
  const DailySalesPieChartCard({
    super.key,
    required this.summary,
  });

  final DailySummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    if (summary.branches.isEmpty) {
      return const SizedBox.shrink();
    }

    final branches = summary.branches
        .map(
          (branch) => getIt<AuthCubit>().getBranchById(branch.branchId),
        )
        .toList();

    final chartsColor = ColorTool.getChartColors();

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
                Icon(Icons.pie_chart_rounded, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  "Ventas por Sucursal",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: Row(
                children: [
                  Flexible(
                    flex: 5,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 36,
                        sections: List.generate(summary.branches.length, (i) {
                          final branch = summary.branches[i];
                          const fontSize = 14.0;
                          const radius = 48.0;
                          const shadows = [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 3,
                            ),
                          ];

                          final percentage = summary.total > 0
                              ? (branch.total / summary.total) * 100
                              : 0.0;

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
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 5,
                    child: ListView(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
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
          ],
        ),
      ),
    );
  }
}
