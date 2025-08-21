import 'package:al_furqan/helper/current_user.dart';
import 'package:al_furqan/main.dart';
import 'package:al_furqan/models/eltlawah_plan_model.dart';
import 'package:al_furqan/models/islamic_studies_model.dart';
import 'package:al_furqan/models/provider/halaqa_provider.dart';
import 'package:al_furqan/models/provider/message_provider.dart';
import 'package:al_furqan/models/provider/user_provider.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/Teacher/DrawerTeacher.dart';
import 'package:al_furqan/views/login/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/plan_controller.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
// with UserDataMixin, WidgetsBindingObserver
{
  UserModel? user = CurrentUser.user;
  // String? phone = perf.getString('phoneUser');
  // bool _isLoadingHalaga = false;
  // String? _errorMessage;
  // HalagaModel? _teacherHalaga;
  // final bool _isLoading = false;
  String pContent = '';
  String eContent = '';
  EltlawahPlanModel? eltlawahPlan;
  List<IslamicStudiesModel?> islamicPlan = [];
  IslamicStudiesModel? islamicPlanSelected;

  Future<void> selectedIslamicSubject(String subject) async {
    try {
      final match = islamicPlan.firstWhere(
        (s) => s?.subject != null && s!.subject == subject,
      );

      setState(() {
        islamicPlanSelected = match;
        pContent = match!.plannedContent!;
        eContent = match.executedContent!;
      });
    } catch (e) {
      // لم يتم العثور على المادة
      setState(() {
        islamicPlanSelected = null;
      });
      print("Error selecting subject: $e");
    }
  }

  Future<void> _loadPlans() async {
    //   setState(() => _isLoading = true);
    //   try {
    // print("------------------------->> CurrentUser.halaga!.halagaID : ${CurrentUser.halaga!.halagaID}");
    // await planController.getPlans(CurrentUser.halaga!.halagaID!);
    // await studentController.getStudents(CurrentUser.halaga!.halagaID!);
    debugPrint(
        "------------------------->> planController.eltlawahPlans : ${planController.eltlawahPlans.isEmpty}");
    EltlawahPlanModel? eltlawahPlanB = planController.eltlawahPlans.isNotEmpty
        ? planController.eltlawahPlans.last
        : null;

    final now = DateTime.now();
    final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    List<IslamicStudiesModel?> islamicPlanB =
        planController.islamicStudyPlans.isNotEmpty
            ? planController.islamicStudyPlans.where(
                (element) {
                  if (element == null || element.planMonth == null) {
                    return false;
                  }
                  return element.planMonth == month;
                },
              ).toList()
            : [];
    // ignore: unnecessary_null_comparison
    if (eltlawahPlanB != null || islamicPlanB != null) {
      eltlawahPlan = eltlawahPlanB;
      islamicPlan = islamicPlanB;
    }
  }
  //catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('حدث خطأ في تحميل الخطط: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  // Future<void> _loadTeacherHalaga() async {
  //   debugPrint("MainTeacher - _loadTeacherHalaga started");
  //   // debugPrint(
  //   //     "MainTeacher - User data: ${user != null ? 'Available' : 'Not available'}");

  //   if (_isLoadingHalaga) {
  //     debugPrint("MainTeacher - Already loading halaga data, skipping");
  //     return;
  //   }

  //   if (user == null) {
  //     debugPrint("MainTeacher - User is null, trying to load user data first");
  //     // await fetchUserData(); // استدعاء دالة تحميل بيانات المستخدم أولاً
  //     if (user == null) {
  //       debugPrint("MainTeacher - Still couldn't load user data");
  //       setState(() {
  //         _errorMessage = "فشل في تحميل بيانات المستخدم";
  //       });
  //       return;
  //     }
  //   }

  //   debugPrint("MainTeacher - User elhalagatID: ${user?.elhalagatID}");

  //   if (user!.elhalagatID == null || user!.elhalagatID == 0) {
  //     debugPrint("MainTeacher - User has no halaga assigned");
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
  //         "MainTeacher - Fetching halaga details for ID: ${user!.elhalagatID}");
  //     // Get the teacher's halaga details using the halagaID (elhalagatID) from user data
  //     _teacherHalaga =
  //         await _halagaController.getHalqaDetails(user!.elhalagatID!);

  //     debugPrint(
  //         "MainTeacher - Halaga response: ${_teacherHalaga != null ? 'Found' : 'Not found'}");

  //     if (_teacherHalaga != null) {
  //       debugPrint(
  //           "MainTeacher - Fetched teacher's halaga: ${_teacherHalaga?.Name}, ID: ${_teacherHalaga?.halagaID}");
  //     } else {
  //       debugPrint(
  //           "MainTeacher - Halaga not found for ID: ${user!.elhalagatID}");
  //       setState(() {
  //         _errorMessage =
  //             "لم يتم العثور على بيانات الحلقة رقم ${user!.elhalagatID}";
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint("MainTeacher - Error fetching teacher's halaga: $e");
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

  // Helper method to build stat cards in the header
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color textColor,
    int? badgeCount,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: textColor, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badgeCount != null && badgeCount > 0)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badgeCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build plan fields for Quran plans
  Widget _buildPlanField({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 2,
            spreadRadius: 0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Helper method to build info cards
  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: title == 'نسبة الحضور' ? 0.85 : 0.75,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // إضافة مراقب دورة حياة التطبيق
    // WidgetsBinding.instance.addObserver(this);
    // Initial data loading
    // fetchUserData();
    _loadPlans();
    // loadMessagesAndStudent();
    // halagaController.getHalagatFromFirebase();
    // _loadTeacherHalaga();
  }

  @override
  void dispose() {
    // إزالة مراقب دورة حياة التطبيق
    // WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // تحديث عدد الإشعارات عند العودة للتطبيق
    if (state == AppLifecycleState.resumed) {
      // updateNotificationCount();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // تحميل الرسائل وبيانات الطلاب
  // Future<void> loadMessagesAndStudent() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String? Id = prefs.getString('user_id');
  //   debugPrint('===== ($Id) =====');

  //   // int? schoolID = perf.getInt('schoolId');
  //   // تحميل بيانات الطلاب والمعلمين
  //   // await studentController.addToLocalOfFirebase(schoolID!);
  //   // await halagaController.getTeachers(schoolID);
  //   // await fathersController.getFathersBySchoolId(schoolID);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          // زر تحديث البيانات
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () async {
                // _loadTeacherHalaga();
                await _loadPlans();
                (context).read<HalaqaProvider>().loadHalagaFromFirebase();
                (context).read<MessageProvider>().loadMessageFromFirebase();
                await _loadPlans();
                // updateNotificationCount();
                // استدعاء دالة تحديث البيانات مباشرة (ستقوم بتحديث حالة التحميل داخلياً)
                // fetchUserData().then((_) {
                // تحديث عدد الإشعارات عند الضغط على زر التحديث
                // updateNotificationCount();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 10),
                        Text('تم تحديث البيانات بنجاح'),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // );
                  // }
                );
              },
              icon: Icon(Icons.refresh, color: Colors.white),
              tooltip: 'تحديث البيانات',
            ),
          ),
          // زر تسجيل الخروج
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () async {
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
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          perf.clear();
                          (context).read<MessageProvider>().clear();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('تسجيل الخروج'),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.logout, color: Colors.white),
              tooltip: 'تسجيل الخروج',
            ),
          ),
        ],
        title: user == null
            ? Row(
                children: [
                  SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)),
                  SizedBox(width: 10),
                  Text("جاري التحميل..."),
                ],
              )
            : Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: Text(
                      '${user!.first_name != null && user!.first_name!.isNotEmpty ? user!.first_name![0] : ''}${user!.last_name != null && user!.last_name!.isNotEmpty ? user!.last_name![0] : ''}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '${user!.first_name} ${user!.last_name}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
      ),
      drawer: user == null ? null : DrawerTeacher(),
      body: user == null || CurrentUser.halaga == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 70, color: Colors.red),
                  SizedBox(height: 20),
                  Text(
                    "فشل في جلب بيانات المستخدم",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () =>
                        (context).read<UserProvider>().loadUsersFromFirebase(),
                    icon: Icon(Icons.refresh),
                    label: Text("إعادة المحاولة"),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            )
          // : user!.elhalagatID == null || user!.elhalagatID == 0
          //     ? Center(
          //         child: Container(
          //           padding: EdgeInsets.all(24),
          //           decoration: BoxDecoration(
          //             color: Colors.amber.withOpacity(0.1),
          //             borderRadius: BorderRadius.circular(16),
          //             border: Border.all(color: Colors.amber, width: 2),
          //           ),
          //           child: Column(
          //             mainAxisSize: MainAxisSize.min,
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               Icon(
          //                 Icons.warning_amber_rounded,
          //                 size: 80,
          //                 color: Colors.amber,
          //               ),
          //               SizedBox(height: 20),
          //               Text(
          //                 "لا يوجد حلقة مسجلة لك",
          //                 style: TextStyle(
          //                   fontSize: 22,
          //                   fontWeight: FontWeight.bold,
          //                 ),
          //               ),
          //               SizedBox(height: 10),
          //               Text(
          //                 "يرجى التواصل مع مدير المدرسة لتسجيلك في حلقة",
          //                 style: TextStyle(
          //                   fontSize: 16,
          //                   color: Colors.grey[700],
          //                 ),
          //                 textAlign: TextAlign.center,
          //               ),
          //               SizedBox(height: 20),
          //               ElevatedButton.icon(
          //                 onPressed: () => (context)
          //                     .read<UserProvider>()
          //                     .loadUsersFromFirebase(),
          //                 icon: Icon(Icons.refresh),
          //                 label: Text("تحديث البيانات"),
          //                 style: ElevatedButton.styleFrom(
          //                   padding: EdgeInsets.symmetric(
          //                       horizontal: 20, vertical: 12),
          //                   backgroundColor: Colors.amber,
          //                   foregroundColor: Colors.black,
          //                   shape: RoundedRectangleBorder(
          //                       borderRadius: BorderRadius.circular(8)),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       )
          : SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dashboard Header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.7)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'لوحة تحكم المعلم',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'مرحباً بك في نظام إدارة الحلقات',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  title: 'اسم الحلقة',
                                  value: CurrentUser.halaga!.Name!,
                                  icon: Icons.class_,
                                  color: Colors.white,
                                  textColor: Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(width: 12),
                              Selector<MessageProvider, int>(
                                  builder: (context, prov, child) => Expanded(
                                        child: _buildStatCard(
                                          title: 'الإشعارات',
                                          value: '$prov رسائل جديدة',
                                          icon: Icons.notifications_active,
                                          color: Colors.white,
                                          textColor:
                                              Theme.of(context).primaryColor,
                                          badgeCount: prov,
                                        ),
                                      ),
                                  selector: (_, s) => s.unReadCount)
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // أول صف يحتوي على كاردين
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // كارد 1 - عدد الطلاب
                        Expanded(
                          child: _buildInfoCard(
                            title: 'عدد الطلاب',
                            value:
                                CurrentUser.halaga!.NumberStudent!.toString(),
                            icon: Icons.people,
                            color: Colors.blue,
                            context: context,
                          ),
                        ),
                        SizedBox(width: 16),
                        // كارد 2 - نسبة الحضور
                        Expanded(
                          child: _buildInfoCard(
                            title: 'نسبة الحضور',
                            value: '0',
                            icon: Icons.check_circle,
                            color: Colors.green,
                            context: context,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // خطة التلاوة
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.menu_book,
                                          color: Colors.green),
                                    ),
                                    SizedBox(width: 10),
                                    Flexible(
                                      child: Text('خطة التلاوة',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800])),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.trending_up,
                                          color: Colors.green, size: 16),
                                      SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          eltlawahPlan != null
                                              ? 'نسبة التنفيذ: ${eltlawahPlan!.executedRate}%'
                                              : 'نسبة التنفيذ: %',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('المخطط',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.grey[800])),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildPlanField(
                                          label: 'من',
                                          value: eltlawahPlan != null
                                              ? '${eltlawahPlan!.plannedStartSurah!}الاية${eltlawahPlan!.plannedStartAya}'
                                              : 'لا توجد خطه',
                                          icon: Icons.arrow_right,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: _buildPlanField(
                                          label: 'إلى',
                                          value: eltlawahPlan == null
                                              ? 'لا توجد خطه'
                                              : ' ${eltlawahPlan!.plannedEndSurah} - الآية ${eltlawahPlan!.plannedEndAya}',
                                          icon: Icons.arrow_left,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('المنفذ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.grey[800])),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildPlanField(
                                          label: 'من',
                                          value: eltlawahPlan == null
                                              ? 'لا توجد خطه'
                                              : ' ${eltlawahPlan!.executedStartSurah} - الآية ${eltlawahPlan!.executedStartAya}',
                                          icon: Icons.arrow_right,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: _buildPlanField(
                                          label: 'إلى',
                                          value: eltlawahPlan == null
                                              ? 'لا توجد خطه'
                                              : ' ${eltlawahPlan!.executedEndSurah} - الآية ${eltlawahPlan!.executedEndAya}',
                                          icon: Icons.arrow_left,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // SizedBox(height: 12),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            //   children: [
                            //     ElevatedButton.icon(
                            //       onPressed: () {},
                            //       icon: Icon(Icons.edit),
                            //       label: Text('تعديل'),
                            //       style: ElevatedButton.styleFrom(
                            //         backgroundColor: Colors.blue,
                            //         foregroundColor: Colors.white,
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(8),
                            //         ),
                            //         padding: EdgeInsets.symmetric(
                            //             horizontal: 16, vertical: 10),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // خطة العلوم الشرعية
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.school,
                                          color: Colors.purple),
                                    ),
                                    SizedBox(width: 10),
                                    Flexible(
                                      child: Text('خطة العلوم الشرعية',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18)),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                // Container(
                                //   padding: EdgeInsets.symmetric(
                                //       horizontal: 12, vertical: 6),
                                //   decoration: BoxDecoration(
                                //     color: Colors.purple.withOpacity(0.1),
                                //     borderRadius: BorderRadius.circular(20),
                                //   ),
                                //   child: Row(
                                //     mainAxisSize: MainAxisSize.min,
                                //     children: [
                                //       // Icon(Icons.trending_up,
                                //       //     color: Colors.purple, size: 16),
                                //       // SizedBox(width: 4),
                                //       // Flexible(
                                //       //   child: Text(
                                //       //     'نسبة التنفيذ: ${islamicPlan.}%',
                                //       //     overflow: TextOverflow.ellipsis,
                                //       //     style: TextStyle(
                                //       //       color: Colors.purple,
                                //       //       fontWeight: FontWeight.bold,
                                //       //       fontSize: 12,
                                //       //     ),
                                //       //   ),
                                //       // ),
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // المقرر - Dropdown
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.book,
                                          size: 18, color: Colors.purple),
                                      SizedBox(width: 8),
                                      Flexible(
                                        child: Text('المقرر',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.grey[800])),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color:
                                              Colors.purple.withOpacity(0.3)),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        border: InputBorder.none,
                                        hintText: 'اختر المقرر',
                                      ),
                                      value: 'التفسير',
                                      onChanged: (String? newValue) async {
                                        if (newValue != null) {
                                          await selectedIslamicSubject(
                                              newValue);
                                        }
                                      },
                                      items: [
                                        'التفسير',
                                        'الحديث',
                                        'الفقه',
                                        'السيرة النبوية',
                                        'القصص',
                                        'العقيدة',
                                        'الأخلاق',
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      icon: Icon(Icons.arrow_drop_down,
                                          color: Colors.purple),
                                      isExpanded: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),

                            // المخطط والمنفذ
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.assignment,
                                                size: 18, color: Colors.blue),
                                            SizedBox(width: 8),
                                            Flexible(
                                              child: Text('المخطط',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.grey[800])),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.blue
                                                    .withOpacity(0.3)),
                                          ),
                                          child: Text(
                                            islamicPlanSelected == null
                                                ? 'لا يوجد'
                                                : pContent,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_circle,
                                                size: 18, color: Colors.green),
                                            SizedBox(width: 8),
                                            Flexible(
                                              child: Text('المنفذ',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.grey[800])),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.green
                                                    .withOpacity(0.3)),
                                          ),
                                          child: Text(
                                            islamicPlanSelected == null
                                                ? 'لا يوجد'
                                                : eContent,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // SizedBox(height: 16),

                            // شريط التقدم
                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     Row(
                            //       mainAxisAlignment:
                            //           MainAxisAlignment.spaceBetween,
                            //       children: [
                            //         Text('نسبة التقدم',
                            //             style: TextStyle(
                            //                 fontWeight: FontWeight.bold,
                            //                 color: Colors.grey[700])),
                            //         Text('${}%',
                            //             style: TextStyle(
                            //                 fontWeight: FontWeight.bold,
                            //                 color: Colors.purple)),
                            //       ],
                            //     ),
                            //     SizedBox(height: 8),
                            //     ClipRRect(
                            //       borderRadius: BorderRadius.circular(4),
                            //       child: LinearProgressIndicator(
                            //         value: 0.75,
                            //         backgroundColor: Colors.grey[200],
                            //         valueColor: AlwaysStoppedAnimation<Color>(
                            //             Colors.purple),
                            //         minHeight: 8,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            // SizedBox(height: 16),

                            // أزرار الإجراءات
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            //   children: [
                            //     OutlinedButton.icon(
                            //       onPressed: () {},
                            //       icon: Icon(Icons.delete_outline),
                            //       label: Text('حذف'),
                            //       style: OutlinedButton.styleFrom(
                            //         foregroundColor: Colors.red,
                            //         side: BorderSide(
                            //             color: Colors.red.withOpacity(0.5)),
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(8),
                            //         ),
                            //         padding: EdgeInsets.symmetric(
                            //             horizontal: 16, vertical: 10),
                            //       ),
                            //     ),
                            //     SizedBox(width: 12),
                            //     ElevatedButton.icon(
                            //       onPressed: () {},
                            //       icon: Icon(Icons.edit),
                            //       label: Text('تعديل'),
                            //       style: ElevatedButton.styleFrom(
                            //         backgroundColor: Colors.purple,
                            //         foregroundColor: Colors.white,
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(8),
                            //         ),
                            //         padding: EdgeInsets.symmetric(
                            //             horizontal: 16, vertical: 10),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // أبرز الملاحظات والتوصيات
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.lightbulb,
                                      color: Colors.amber),
                                ),
                                SizedBox(width: 10),
                                Text('أبرز الملاحظات والتوصيات',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                              ],
                            ),
                            SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.2)),
                              ),
                              child: TextField(
                                maxLines: 5,
                                decoration: InputDecoration(
                                  hintText: 'اكتب الملاحظات والتوصيات هنا...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.save),
                                  label: Text('حفظ الملاحظات'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.black87,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // الطلاب المتميزون
                    // Container(
                    //   margin: EdgeInsets.only(top: 20, bottom: 10),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Padding(
                    //         padding: const EdgeInsets.symmetric(
                    //             vertical: 8.0, horizontal: 4.0),
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           children: [
                    //             Row(
                    //               children: [
                    //                 Container(
                    //                   padding: EdgeInsets.all(8),
                    //                   decoration: BoxDecoration(
                    //                     color: Colors.orange.withOpacity(0.1),
                    //                     borderRadius: BorderRadius.circular(8),
                    //                   ),
                    //                   child: Icon(Icons.star,
                    //                       color: Colors.orange),
                    //                 ),
                    //                 SizedBox(width: 10),
                    //                 Text('الطلاب المتميزون',
                    //                     style: TextStyle(
                    //                         fontWeight: FontWeight.bold,
                    //                         fontSize: 18)),
                    //               ],
                    //             ),
                    //             TextButton.icon(
                    //               onPressed: () {},
                    //               icon: Icon(Icons.people, size: 16),
                    //               label: Text('عرض الكل'),
                    //               style: TextButton.styleFrom(
                    //                 foregroundColor: Colors.blue,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //       SizedBox(height: 10),
                    //       Container(
                    //         height: 120,
                    //         child: ListView.builder(
                    //           scrollDirection: Axis.horizontal,
                    //           itemCount: 5,
                    //           itemBuilder: (context, index) {
                    //             return Container(
                    //               width: 100,
                    //               margin: EdgeInsets.only(right: 12),
                    //               decoration: BoxDecoration(
                    //                 color: Colors.white,
                    //                 borderRadius: BorderRadius.circular(12),
                    //                 boxShadow: [
                    //                   BoxShadow(
                    //                     color: Colors.grey.withOpacity(0.1),
                    //                     spreadRadius: 1,
                    //                     blurRadius: 4,
                    //                     offset: Offset(0, 2),
                    //                   ),
                    //                 ],
                    //               ),
                    //               child: Column(
                    //                 mainAxisAlignment: MainAxisAlignment.center,
                    //                 children: [
                    //                   CircleAvatar(
                    //                     radius: 30,
                    //                     backgroundColor:
                    //                         Colors.orange.withOpacity(0.1),
                    //                     child: Text(
                    //                       'ط${index + 1}',
                    //                       style: TextStyle(
                    //                         fontWeight: FontWeight.bold,
                    //                         color: Colors.orange,
                    //                         fontSize: 18,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   SizedBox(height: 8),
                    //                   Text('الطالب ${index + 1}',
                    //                       style: TextStyle(
                    //                           fontWeight: FontWeight.bold)),
                    //                   Text('95%',
                    //                       style: TextStyle(
                    //                           color: Colors.green,
                    //                           fontSize: 12)),
                    //                 ],
                    //               ),
                    //             );
                    //           },
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
    );
  }
}
