import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<Map<String, dynamic>> students = [
    {"name": "أحمد محمد", "isPresent": false},
    {"name": "سارة علي", "isPresent": false},
    {"name": "محمد حسن", "isPresent": false},
    {"name": "ليلى عبد الرحمن", "isPresent": false},
    {"name": "خالد يوسف", "isPresent": false},
  ];

  bool allSelected = false;

  void toggleStudentSelection(int index) {
    setState(() {
      students[index]["isPresent"] = !students[index]["isPresent"];
    });
  }

  void toggleSelectAll() {
    setState(() {
      allSelected = !allSelected;
      for (var student in students) {
        student["isPresent"] = allSelected;
      }
    });
  }

  void saveAttendance() {
    List presentStudents = students
        .where((student) => student["isPresent"])
        .map((student) => student["name"])
        .toList();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم حفظ الحضور: ${presentStudents.join(", ")}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تحضير الطلاب")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // زر تحديد الكل
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("تحديد الكل", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Switch(
                  value: allSelected,
                  onChanged: (value) => toggleSelectAll(),
                ),
              ],
            ),
            SizedBox(height: 10),

            // قائمة الطلاب مع تحديد الحضور مثل تحديد الأشهر
            Expanded(
              child: Wrap(
                spacing: 8.0,
                children: students.asMap().entries.map((entry) {
                  int index = entry.key;
                  var student = entry.value;
                  bool isSelected = student["isPresent"];

                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(student["name"]),
                        SizedBox(width: 5),
                        if (isSelected) Icon(Icons.check, color: Colors.white, size: 18), // علامة صح ✅
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) => toggleStudentSelection(index),
                    selectedColor: Colors.green,
                    backgroundColor: Colors.grey[300],
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),

            // زر موافق لحفظ الحضور
            ElevatedButton(
              onPressed: saveAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text("موافق"),
            ),
          ],
        ),
      ),
    );
  }
}
