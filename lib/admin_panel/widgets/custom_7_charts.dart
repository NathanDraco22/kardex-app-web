import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

class CustomChartData {
  double value;

  CustomChartData({
    required this.value,
  });
}

class Custom7DaysLineChart extends StatelessWidget {
  const Custom7DaysLineChart({
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
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => Colors.blueAccent.withValues(alpha: 0.8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    "C\$ ${spot.y.toStringAsFixed(2)}",
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }).toList();
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
              color: Colors.teal,
              spots: List.generate(
                data.length,
                (index) => FlSpot(index.toDouble(), data[index].value),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.teal.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
