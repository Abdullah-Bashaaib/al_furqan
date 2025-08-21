import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatelessWidget {
  final int totalActivities = 10;
  final double completionPercentage = 75.0;

  final List<Map<String, dynamic>> recentActivities = [
    {"name": "اجتماع الفريق", "category": "إدارة", "date": "2025-02-10", "status": "تم"},
    {"name": "إعداد تقرير", "category": "عمل", "date": "2025-02-09", "status": "لم يتم"},
    {"name": "تدريب", "category": "تطوير ذاتي", "date": "2025-02-08", "status": "تم"},
  ];

   StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("الإحصائيات")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // الصف الأول: الكاردات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StatCard(title: "عدد الأنشطة", value: "$totalActivities"),
                StatCard(title: "نسبة التنفيذ", value: "$completionPercentage%"),
              ],
            ),
            SizedBox(height: 20),

            // المخطط المتعرج
            Text("نسبة تنفيذ الأنشطة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            SizedBox(height: 200, child: ActivityChart()),

            SizedBox(height: 20),

            // جدول الأنشطة الأخيرة
            Text("الأنشطة الأخيرة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  DataTable(
                    columns: [
                      DataColumn(label: Text("النشاط")),
                      DataColumn(label: Text("المجال")),
                      DataColumn(label: Text("التاريخ")),
                      DataColumn(label: Text("الحالة")),
                    ],
                    rows: recentActivities.map((activity) {
                      return DataRow(cells: [
                        DataCell(Text(activity["name"])),
                        DataCell(Text(activity["category"])),
                        DataCell(Text(activity["date"])),
                        DataCell(Text(activity["status"], style: TextStyle(
                          color: activity["status"] == "تم" ? Colors.green : Colors.red,
                        ))),
                      ]);
                    }).toList(),
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

// ويدجت الكارد للإحصائيات
class StatCard extends StatelessWidget {
  final String title;
  final String value;

  const StatCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}

// ويدجت المخطط المتعرج
class ActivityChart extends StatelessWidget {
  const ActivityChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(1, 20),
              FlSpot(2, 40),
              FlSpot(3, 60),
              FlSpot(4, 80),
              FlSpot(5, 75),
            ],
            isCurved: true,
            barWidth: 3,
            // colors: [Colors.blue],
            // belowBarData: BarAreaData(show: true, colors: [Colors.blue.withOpacity(0.3)]),
          ),
        ],
      ),
    );
  }
}
