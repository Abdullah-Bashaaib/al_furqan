import 'package:al_furqan/controllers/school_controller.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/SchoolDirector/ElhalagatList.dart';
import 'package:al_furqan/views/SchoolDirector/TeachersAttendance.dart';
import 'package:al_furqan/views/SchoolDirector/studentListPage.dart';
import 'package:al_furqan/views/SchoolDirector/teacher_management.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DrawerSchoolDirector extends StatefulWidget {
  final UserModel? user;
  const DrawerSchoolDirector({super.key, required this.user});

  @override
  _DrawerSchoolDirectorState createState() => _DrawerSchoolDirectorState();
}

class _DrawerSchoolDirectorState extends State<DrawerSchoolDirector> {
  String? _schoolName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchoolName();
  }

  Future<void> _loadSchoolName() async {
    if (widget.user?.schoolID == null) {
      print("schoolID is null");
      if (mounted) {
        setState(() {
          _schoolName = 'غير متوفر';
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final school =
          await schoolController.getSchoolBySchoolID(widget.user!.schoolID!);
      if (mounted) {
        setState(() {
          _schoolName = school?.school_name ?? 'غير متوفر';
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading school name: $e");
      if (mounted) {
        setState(() {
          _schoolName = 'خطأ في الجلب';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // قسم البروفايل
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green.shade700,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 65,
                  height: 65,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/pictures/profile.jpg'),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  widget.user != null
                      ? '${widget.user!.first_name} ${widget.user!.last_name}'
                      : 'غير متوفر',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'مدير ${_schoolName ?? 'غير متوفر'}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
              ],
            ),
          ),
          // القوائم
          ListTile(
            leading: Icon(Icons.people),
            title: Text('تحضير المعلمين'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.manage_accounts),
            title: Text("إدارة المعلمين"),
            onTap: () {
              Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) => TeacherManagement()));
            },
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('إدارة الطلاب'),
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => StudentsListPage(user: widget.user),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('إدارة الحلقات'),
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => HalqatListPage(user: widget.user!),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('المناهج'),
            onTap: () {
              // الانتقال إلى شاشة المناهج
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('الإعدادات'),
            onTap: () {
              // الانتقال إلى شاشة الإعدادات
            },
          ),
          Spacer(),
          Divider(),
          // تسجيل الخروج
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('تسجيل الخروج'),
            onTap: () {
              // تنفيذ عملية تسجيل الخروج
            },
          ),
        ],
      ),
    );
  }
}