import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomPieChart extends StatelessWidget {
  const CustomPieChart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Row(
        spacing: 4,
        children: [
          Flexible(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: Center(
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sections: [
                      PieChartSectionData(
                        color: Colors.yellow,
                        value: 1,
                        title: "25%",
                      ),
                      PieChartSectionData(
                        color: Colors.red,
                        value: 1,
                        title: "25%",
                      ),
                      PieChartSectionData(
                        color: Colors.green,
                        value: 1,
                        title: "25%",
                      ),
                      PieChartSectionData(
                        color: Colors.blue,
                        value: 1.0,
                        title: "25%",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    // const PieChartRow(),
                    // const SizedBox(height: 8),
                    // const PieChartRow(),
                    // const SizedBox(height: 8),

                    // const PieChartRow(),
                    // const SizedBox(height: 8),

                    // const PieChartRow(),
                    // const SizedBox(height: 8),

                    // const PieChartRow(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
