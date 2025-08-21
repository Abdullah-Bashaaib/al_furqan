import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final Color color;
  final double percentage;

  const ChartCard({super.key, 
    required this.title,
    required this.color,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: percentage,
                      color: color,
                      title: '$percentage%',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: 100 - percentage,
                      color: Colors.grey.shade300,
                      title: '',
                      radius: 30,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
