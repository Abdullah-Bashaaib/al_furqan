import 'package:flutter/material.dart';
import 'package:al_furqan/views/Teacher/StudentDetilesPage.dart';

class StudentsListPage extends StatelessWidget {
  // قائمة افتراضية تحتوي على بيانات الطلاب
  final List<Map<String, String>> students = [
    {'name': 'محمد أحمد', 'progress': 'الزمر: آية 5'},
    {'name': 'علي حسن', 'progress': 'البقرة: آية 200'},
    {'name': 'سعيد خالد', 'progress': 'النساء: آية 45'},
    {'name': 'فاطمة محمود', 'progress': 'الأنفال: آية 20'},
    {'name': 'أحمد إبراهيم', 'progress': 'الملك: آية 10'},
  ];

  StudentsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('طلاب الحلقة',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        student['name']!,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        student['progress']!,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      trailing:
                          Icon(Icons.arrow_forward_ios, color: Colors.teal),
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => StudentDetailsPage(
                        //         studentName: student['name']!),
                        //   ),
                        // );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
