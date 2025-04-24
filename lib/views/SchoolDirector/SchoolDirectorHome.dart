import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/TeacherController.dart';
import 'package:al_furqan/helper/user_helper.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/SchoolDirector/AddTeacher.dart';
import 'package:al_furqan/views/SchoolDirector/DrawerSchoolDirector.dart';
import 'package:al_furqan/views/login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SchoolManagerScreen extends StatefulWidget {
  SchoolManagerScreen({super.key});

  @override
  State<SchoolManagerScreen> createState() => _SchoolManagerScreenState();
}

class _SchoolManagerScreenState extends State<SchoolManagerScreen>
    with UserDataMixin {
  final teacher = teacherController.teachers;
  final student = studentController.students;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    countStudent();
  }

  Future<int> countStudent() async {
    List<StudentModel> countStudents =
        await studentController.getSchoolStudents(1);
    int number = countStudents.length;
    return number;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CupertinoColors.activeGreen.withOpacity(0.5),
        title: isLoading || user == null
            ? Text("جاري التحميل...")
            : Text('${user!.first_name} ${user!.last_name}'),
        actions: [
          IconButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      drawer: user == null ? null : DrawerSchoolDirector(user: user),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : user == null
              ? Center(child: Text("فشل في جلب بيانات المستخدم"))
              : Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: _buildStatCard('عدد المعلمين',
                                  '${teacher.length}', Colors.blue)),
                          SizedBox(width: 10),
                          Expanded(
                              child: _buildStatCard('عدد الطلاب',
                                  '${countStudent()}', Colors.green)),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text('قائمة المعلمين',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: teacher.isEmpty
                            ? Center(child: Text("لا يوجد معلمين متاحين"))
                            : ListView.builder(
                                itemCount: teacher.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    child: ListTile(
                                      title: Text(
                                          "${teacher[index].first_name ?? ''} ${teacher[index].middle_name ?? ''} ${teacher[index].last_name ?? ''}"
                                              .trim()),
                                      subtitle: Text('المستوى: اسم الحلقة'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.info,
                                                color: Colors.blue),
                                            onPressed: () {
                                              // الانتقال إلى صفحة معلومات المعلم
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit,
                                                color: Colors.orange),
                                            onPressed: () {
                                              // تعديل بيانات المعلم
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddTeacherScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 5,
      surfaceTintColor: Color.fromARGB(255, 1, 117, 70),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: Colors.green, width: 2)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
