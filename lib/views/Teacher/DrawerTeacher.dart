import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/plan_controller.dart';
import 'package:al_furqan/helper/current_user.dart';
import 'package:al_furqan/models/provider/halaqa_provider.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/views/Teacher/HalagaPlansListScreen.dart';
import 'package:al_furqan/views/Teacher/attendTeacherScreen.dart';
import 'package:al_furqan/views/Teacher/islamic_studies_plans_list.dart';
import 'package:al_furqan/views/Teacher/main_screenT.dart';
import 'package:al_furqan/views/Teacher/monthly_report.dart';
import 'package:al_furqan/views/Teacher/students_attendance.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:provider/provider.dart';

import '../shared/Conversation_list.dart';

class DrawerTeacher extends StatefulWidget {
  const DrawerTeacher({
    super.key,
  });

  @override
  State<DrawerTeacher> createState() => _DrawerTeacherState();
}

class _DrawerTeacherState extends State<DrawerTeacher>
//  with UserDataMixin
{
  final HalagaController _halagaController = HalagaController();
  // HalagaModel? _teacherHalaga;
  // bool _isLoadingHalaga = true;
  String? _errorMessage;
  List<StudentModel> students = [];

  @override
  void initState() {
    super.initState();
    debugPrint("DrawerTeacher - initState called");
    // نضيف مؤقت صغير للتأكد من أن بيانات المستخدم تم تحميلها قبل تحميل الحلقة
    // Future.delayed(Duration(milliseconds: 500), () {
    //   if (mounted) {
    //     _loadTeacherHalaga();
    //   }
    // });

    planController.getPlans(CurrentUser.halaga!.halagaID!);
    loadStudents();
  }

  Future<void> loadStudents() async {
    students =
        await studentController.getStudents(CurrentUser.halaga!.halagaID!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint("DrawerTeacher - didChangeDependencies called");
    // لن نستدعي _loadTeacherHalaga هنا لتجنب التكرار، سيتم استدعاؤها من initState
  }

  // Future<void> _loadTeacherHalaga() async {
  //   debugPrint("DrawerTeacher - _loadTeacherHalaga started");
  //   debugPrint(
  //       "DrawerTeacher - User data: ${user != null ? 'Available' : 'Not available'}");

  //   if (_isLoadingHalaga) {
  //     debugPrint("DrawerTeacher - Already loading halaga data, skipping");
  //     return;
  //   }

  //   if (user == null) {
  //     debugPrint(
  //         "DrawerTeacher - User is null, trying to load user data first");
  //     await fetchUserData(); // استدعاء دالة تحميل بيانات المستخدم أولاً
  //     if (user == null) {
  //       debugPrint("DrawerTeacher - Still couldn't load user data");
  //       setState(() {
  //         _errorMessage = "فشل في تحميل بيانات المستخدم";
  //       });
  //       return;
  //     }
  //   }

  //   debugPrint("DrawerTeacher - User elhalagatID: ${user?.elhalagatID}");

  //   if (user!.elhalagatID == null || user!.elhalagatID == 0) {
  //     debugPrint("DrawerTeacher - User has no halaga assigned");
  //     setState(() {
  //       _errorMessage = "لم يتم تعيين حلقة للمعلم";
  //     });
  //     return;
  //   }

  //   setState(() {
  //     _isLoadingHalaga = true;
  //   });

  //   try {
  //     debugPrint(
  //         "DrawerTeacher - Fetching halaga details for ID: ${user!.elhalagatID}");
  //     // Get the teacher's halaga details using the halagaID (elhalagatID) from user data
  //     _teacherHalaga =
  //         await _halagaController.getHalqaDetails(user!.elhalagatID!);

  //     debugPrint(
  //         "DrawerTeacher - Halaga response: ${_teacherHalaga != null ? 'Found' : 'Not found'}");

  //     if (_teacherHalaga != null) {
  //       debugPrint(
  //           "DrawerTeacher - Fetched teacher's halaga: ${_teacherHalaga?.Name}, ID: ${_teacherHalaga?.halagaID}");
  //     } else {
  //       debugPrint(
  //           "DrawerTeacher - Halaga not found for ID: ${user!.elhalagatID}");
  //       setState(() {
  //         _errorMessage =
  //             "لم يتم العثور على بيانات الحلقة رقم ${user!.elhalagatID}";
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint("DrawerTeacher - Error fetching teacher's halaga: $e");
  //     setState(() {
  //       _errorMessage = "خطأ أثناء جلب بيانات الحلقة: $e";
  //     });
  //   } finally {
  //     if (mounted) {
  //       // نتحقق من أن الكائن لا يزال موجوداً
  //       setState(() {
  //         _isLoadingHalaga = false;
  //       });
  //     }
  //   }
  // }

  // void _showDiagnosticInfo() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('معلومات تشخيصية'),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text('معرف المستخدم: ${user?.user_id ?? 'غير متوفر'}'),
  //             Text(
  //                 'اسم المستخدم: ${user != null ? '${user!.first_name} ${user!.last_name}' : 'غير متوفر'}'),
  //             Text('معرف الحلقة: ${user?.elhalagatID ?? 'غير متوفر'}'),
  //             Divider(),
  //             Text(
  //                 'حالة تحميل الحلقة: ${_isLoadingHalaga ? 'جار التحميل' : 'مكتمل'}'),
  //             Text(
  //                 'بيانات الحلقة: ${_teacherHalaga != null ? 'متوفرة' : 'غير متوفرة'}'),
  //             if (_teacherHalaga != null) ...[
  //               Text('اسم الحلقة: ${_teacherHalaga!.Name ?? 'غير متوفر'}'),
  //               Text('معرف الحلقة: ${_teacherHalaga!.halagaID ?? 'غير متوفر'}'),
  //             ],
  //             if (_errorMessage != null) ...[
  //               Divider(),
  //               Text('رسالة الخطأ:',
  //                   style: TextStyle(fontWeight: FontWeight.bold)),
  //               Text(_errorMessage!, style: TextStyle(color: Colors.red)),
  //             ],
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text('إغلاق'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             _loadTeacherHalaga(); // إعادة محاولة تحميل البيانات
  //           },
  //           child: Text('إعادة المحاولة'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    HalagaModel? h = (context).read<HalaqaProvider>().halaga;
    // debugPrint(
    //     "DrawerTeacher - Build called, teacherHalaga: ${_teacherHalaga != null ? 'Available' : 'Null'}");
    return Drawer(
      elevation: 16.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // قسم البروفايل
            Container(
              padding: EdgeInsets.symmetric(vertical: 25),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
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
                          spreadRadius: 1,
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
                  CurrentUser.user == null
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          '${CurrentUser.user!.first_name} ${CurrentUser.user!.last_name}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'معلم الحلقة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '${CurrentUser.halaga!.Name}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // if (_isLoadingHalaga)
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 8.0),
                  //     child: CircularProgressIndicator(
                  //       color: Colors.white,
                  //       strokeWidth: 2,
                  //     ),
                  //   ),
                  // // else if (_teacherHalaga != null)
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 8.0),
                  //     child: Container(
                  //       padding:
                  //           EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  //       decoration: BoxDecoration(
                  //         color: Colors.white.withOpacity(0.3),
                  //         borderRadius: BorderRadius.circular(20),
                  //       ),
                  //       child: Text(
                  //         '${CurrentUser.user!.first_name}',
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 14,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //   )
                  // else
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 8.0),
                  //     child: InkWell(
                  //       // onTap: _loadTeacherHalaga,
                  //       child: Container(
                  //         padding:
                  //             EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  //         decoration: BoxDecoration(
                  //           color: Colors.orange.withOpacity(0.3),
                  //           borderRadius: BorderRadius.circular(20),
                  //         ),
                  //         child: Text(
                  //           _errorMessage ?? 'اضغط لتحميل بيانات الحلقة',
                  //           style: TextStyle(
                  //             color: Colors.white,
                  //             fontSize: 14,
                  //             fontWeight: FontWeight.bold,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),

                  // زر لعرض معلومات تشخيصية
                  // TextButton(
                  //   onPressed: _showDiagnosticInfo,
                  //   child: Text(
                  //     'فحص حالة البيانات',
                  //     style: TextStyle(color: Colors.white70),
                  //   ),
                  // ),
                ],
              ),
            ),

            SizedBox(height: 10),

            // القوائم
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                physics: BouncingScrollPhysics(),
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.refresh,
                    title: 'مزامنة البيانات',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScreenT(),
                        ),
                      );
                    },
                  ),
                  _buildMenuCategory('الإدارة'),
                  _buildMenuItem(
                    context,
                    icon: Icons.people,
                    title: 'تحضير الطلاب',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentsAttendance(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.qr_code,
                    title: 'حضوري ',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceScannerPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.assessment,
                    title: 'التقرير الشهري',
                    onTap: () async {
                      print(
                          'Conservation Plans: ${planController.conservationPlans.length}');
                      print(
                          'Eltlawah Plans: ${planController.eltlawahPlans.length}');
                      print(
                          'Islamic Study Plans: ${planController.islamicStudyPlans.length}');
                      print('Students: ${students.length}');
                      if (planController.conservationPlans.isEmpty ||
                          planController.eltlawahPlans.isEmpty ||
                          planController.islamicStudyPlans.isEmpty ||
                          students.isEmpty) {
                        return showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Row(
                                    children: [
                                      Icon(Icons.error_outline),
                                      Text(
                                        'غير جاهز',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.red),
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ],
                                  ),
                                ));
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MonthlyReportScreen(),
                          ),
                        );
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildMenuCategory('التعليم'),
                  _buildMenuItem(
                    context,
                    icon: Icons.book,
                    title: 'خطة الحفظ والتلاوة',
                    onTap: () {
                      Navigator.pop(context);
                      // if (_isLoadingHalaga) {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(
                      //       content: Text(
                      //           'جار تحميل بيانات الحلقة، يرجى الانتظار...'),
                      //       backgroundColor: Colors.orange,
                      //     ),
                      //   );
                      //   return;
                      // }
                      if (CurrentUser.user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_errorMessage ??
                                'لم يتم العثور على بيانات الحلقة'),
                            backgroundColor: Colors.red,
                            action: SnackBarAction(
                              label: 'إعادة المحاولة',
                              onPressed: () {
                                // _loadTeacherHalaga();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('جار إعادة تحميل البيانات...'),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                        return;
                      }

                      // الانتقال إلى شاشة المناهج
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HalagaPlansListScreen(
                            halaga: CurrentUser.halaga!,
                          ),
                        ),
                      ).then((value) {
                        // إعادة تحميل البيانات عند العودة
                        if (value == true) {
                          // _loadTeacherHalaga();
                        }
                      });
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.assessment,
                    title: 'العلوم الشرعية',
                    onTap: () {
                      Navigator.pop(context);
                      // الانتقال إلى شاشة التقييمات
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IslamicStudiesPlansListScreen(
                            halaga: CurrentUser.halaga!,
                          ),
                        ),
                      ).then((value) {
                        // إعادة تحميل البيانات عند العودة
                        if (value == true) {
                          // _loadTeacherHalaga();
                        }
                      });
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.message,
                    title: 'الرسائل',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ConversationsScreen(
                                  currentUser: CurrentUser.user!,
                                )),
                      );
                    },
                  ),
                  // _buildDivider(),
                  // _buildMenuCategory('الإعدادات'),
                  // _buildMenuItem(
                  //   context,
                  //   icon: Icons.settings,
                  //   title: 'الإعدادات',
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //     // الانتقال إلى شاشة الإعدادات
                  //   },
                  // ),
                  // _buildMenuItem(
                  //   context,
                  //   icon: Icons.refresh,
                  //   title: 'تحديث البيانات',
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //     // _loadTeacherHalaga();
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(
                  //         content: Text('جار تحديث البيانات...'),
                  //         backgroundColor: Colors.blue,
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),

            // تسجيل الخروج
            Container(
              margin: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onTap: () {
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('تسجيل الخروج'),
                      content: Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('إلغاء'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            // تنفيذ عملية تسجيل الخروج
                            Navigator.pop(context);
                          },
                          child: Text('تسجيل الخروج'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCategory(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 15, top: 15, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).primaryColor,
                    size: 22,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (showBadge)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'جديد',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child:
          Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.1)),
    );
  }
}
