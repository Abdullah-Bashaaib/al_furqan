import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/school_controller.dart';
import 'package:al_furqan/main.dart';
import 'package:al_furqan/models/provider/user_provider.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/SchoolDirector/ElhalagatList.dart';
import 'package:al_furqan/views/SchoolDirector/attendanceQrScreen.dart';
import 'package:al_furqan/views/SchoolDirector/main_screenD.dart';
import 'package:al_furqan/views/SchoolDirector/studentListPage.dart';
import 'package:al_furqan/views/SchoolDirector/teacher_management.dart';
import 'package:al_furqan/views/SchoolDirector/teachers_attendance_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/Conversation_list.dart';

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
      debugPrint("schoolID is null");
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
      debugPrint("Error loading school name: $e");
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
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile section with enhanced styling
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            AssetImage('assets/pictures/profile.jpg'),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      widget.user != null
                          ? '${widget.user!.first_name} ${widget.user!.last_name}'
                          : 'غير متوفر',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'مدير ${_schoolName ?? 'غير متوفر'}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 15,
                            ),
                          ),
                  ],
                ),
              ),
            ),

            // Scrollable menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Staff Management Section
                  _buildSectionTitle('إدارة البيانات'),
                  _buildMenuItem(
                    icon: Icons.update,
                    title: 'مزامنة البيانات ',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScreenD(),
                        ),
                      );
                    },
                  ),
                  _buildSectionTitle('إدارة الكادر'),
                  _buildMenuItem(
                    icon: Icons.manage_accounts,
                    title: "إدارة المعلمين",
                    onTap: () {
                      (context).read<UserProvider>().loadUsersFromFirebase();
                      Navigator.pop(context);
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => TeacherManagement()));
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.people,
                    title: 'تحضير المعلمين',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceQRScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.manage_accounts,
                    title: "عرض الحضور",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                            builder: (context) => TeachersAttendanceListScreen(
                                schoolId: widget.user!.schoolID!.toString())),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.message,
                    title: "الرسائل",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => ConversationsScreen(
                            currentUser: widget.user!,
                          ),
                        ),
                      );
                    },
                  ),
                  // Student Management Section
                  _buildSectionTitle('إدارة الطلاب والحلقات'),
                  _buildMenuItem(
                    icon: Icons.school,
                    title: 'إدارة الطلاب',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) =>
                              StudentsListPage(user: widget.user),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.groups,
                    title: 'إدارة الحلقات',
                    onTap: () async {
                      int? schoolID = perf.getInt('schoolId');
                      await halagaController.getHalagatFromFirebaseByID(
                          schoolID!, 'SchoolID');
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => HalqatListPage(),
                        ),
                      );
                    },
                  ),

                  // Academic Section
                  //     _buildSectionTitle('الشؤون الأكاديمية'),
                  //     _buildMenuItem(
                  //       icon: Icons.book,
                  //       title: 'المناهج',
                  //       onTap: () {
                  //         Navigator.pop(context);
                  //      Navigator.of(context).pop();
                  // Navigator.push(
                  //   context,
                  //   CupertinoPageRoute(
                  //       builder: (context) => DatabaseViewerEntry()),
                  // );
                  //         // الانتقال إلى شاشة المناهج
                  //       },
                  //     ),

                  // System Section
                  // _buildSectionTitle('النظام'),
                  // _buildMenuItem(
                  //   icon: Icons.settings,
                  //   title: 'الإعدادات',
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //     // الانتقال إلى شاشة الإعدادات
                  //   },
                  // ),
                ],
              ),
            ),

            // Logout at the bottom
            // Divider(thickness: 1),
            // _buildMenuItem(
            //   icon: Icons.logout,
            //   title: 'تسجيل الخروج',
            //   color: Colors.red.shade300,
            //   onTap: () {
            //     // Show confirmation dialog
            //     showDialog(
            //       context: context,
            //       builder: (context) => AlertDialog(
            //         title: Text('تسجيل الخروج'),
            //         content: Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
            //         actions: [
            //           TextButton(
            //             onPressed: () => Navigator.pop(context),
            //             child: Text('إلغاء'),
            //           ),
            //           TextButton(
            //             onPressed: () {
            //               // Implement logout logic here
            //               Navigator.pop(context);
            //             },
            //             child: Text('تسجيل الخروج'),
            //           ),
            //         ],
            //       ),
            //     );
            //   },
            // ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.green.shade700),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: color ?? Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_left,
          size: 18,
          color: Colors.grey,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        onTap: onTap,
        dense: true,
        tileColor: Colors.white,
      ),
    );
  }
}
