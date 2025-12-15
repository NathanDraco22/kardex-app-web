import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

class Custom7DaysLineChart extends StatelessWidget {
  const Custom7DaysLineChart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          lineTouchData: const LineTouchData(
            enabled: true,
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
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 27000),
                const FlSpot(1, 32000),
                const FlSpot(2, 25000),
                const FlSpot(3, 28000),
                const FlSpot(4, 30000),
                const FlSpot(5, 22000),
                const FlSpot(6, 27000),
              ],
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
