import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

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
      return const SizedBox(
        height: 220,
        child: Center(child: Text("No hay datos disponibles")),
      );
    }

    final todayMidnight = DateTimeTool.getTodayMidnight();
    final lastWeek = todayMidnight.subtract(const Duration(days: 7));

    return SizedBox(
      height: 230,
      child: LineChart(
        LineChartData(
          minY: 0,
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => const Color(0xFF0F172A),
              tooltipBorderRadius: BorderRadius.circular(8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    "${NumberFormatter.currencySymbol} ${spot.y.toStringAsFixed(2)}",
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => const FlLine(
              color: AppThemeTokens.borderLight,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1.0,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final date = lastWeek.add(Duration(days: value.toInt()));
                  final label = value.toInt() == 6 ? "Ayer" : DateTimeTool.formatddMM(date);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: AppThemeTokens.neutral,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              color: AppThemeTokens.teal,
              barWidth: 3,
              isCurved: true,
              curveSmoothness: 0.28,
              isStrokeCapRound: true,
              spots: List.generate(
                data.length,
                (index) => FlSpot(index.toDouble(), data[index].value),
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 3,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: AppThemeTokens.teal,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppThemeTokens.teal.withValues(alpha: 0.10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
