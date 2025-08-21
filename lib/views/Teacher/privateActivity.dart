import 'package:flutter/material.dart';
import 'package:al_furqan/views/Teacher/addActivity.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({super.key});

  @override
  _ActivityListScreenState createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  List<Map<String, dynamic>> activities = [
    {"name": "اجتماع الفريق", "date": "2025-02-11", "isCompleted": false},
    {"name": "إعداد تقرير", "date": "2025-02-12", "isCompleted": true},
  ];

  void toggleStatus(int index) {
    setState(() {
      activities[index]["isCompleted"] = !activities[index]["isCompleted"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("قائمة الأنشطة")),
      body: ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(activity["name"],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text("التاريخ: ${activity["date"]}"),
              trailing: ElevatedButton(
                onPressed: () => toggleStatus(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      activity["isCompleted"] ? Colors.green : Colors.red,
                ),
                child: Text(
                    activity["isCompleted"] ? "تم التنفيذ" : "لم يتم التنفيذ"),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // هنا سنضيف التنقل لصفحة الإضافة لاحقًا
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddActivityScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
