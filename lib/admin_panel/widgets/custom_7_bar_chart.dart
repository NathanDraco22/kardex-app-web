import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'custom_7_charts.dart';

class Custom7DaysBarChart extends StatelessWidget {
  const Custom7DaysBarChart({
    super.key,
    required this.data,
  });

  final List<CustomChartData> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("No hay datos disponibles"));
    }

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (touchedBarGroup) => Colors.blueAccent.withValues(alpha: 0.8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  "C\$ ${rod.toY.toStringAsFixed(2)}",
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          gridData: const FlGridData(
            show: true,
            verticalInterval: 1,
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1.0,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final todayMidnight = DateTimeTool.getTodayMidnight();
                  final lastWeek = todayMidnight.subtract(const Duration(days: 7));
                  final date = lastWeek.add(Duration(days: value.toInt()));
                  String label = DateTimeTool.formatddMM(date);
                  if (value.toInt() == 6) {
                    label = "Ayer";
                  }
                  return Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: List.generate(
            data.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data[index].value,
                  color: Colors.teal,
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
