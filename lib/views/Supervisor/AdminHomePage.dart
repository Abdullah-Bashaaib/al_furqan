import 'package:al_furqan/controllers/TeacherController.dart';
import 'package:al_furqan/controllers/school_controller.dart';
import 'package:al_furqan/models/provider/student_provider.dart';
import 'package:al_furqan/services/sync.dart';
import 'package:al_furqan/views/login/login.dart';
import 'package:al_furqan/widgets/chart_card.dart';
import 'package:al_furqan/widgets/drawer_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helper/current_user.dart';
import '../../models/users_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
//  with UserDataMixin
{
  final _schools = schoolController.schools;
  final _teachers = teacherController.teachers;
  int _totalStudents = 0;
  // int _unreadMessages = 0; // سيتم استخدامه مستقبلاً للرسائل
  int _presentTeachers = 0;
  int _lateTeachers = 0;
  double _attendanceRate = 0.0;
  double _activitiesCompletionRate = 0.0;
  String _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  UserModel? user = CurrentUser.user;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // syncData();
    _refreshData();
    // _loadAdditionalData();
  }

  Future<void> loadStudentsWithDialog(BuildContext context) async {
    // عرض الـ Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(child: Text("الرجاء الانتظار حتى تحميل البيانات")),
          ],
        ),
      ),
    );

    // تحميل البيانات
    await context.read<StudentProvider>().loadTotalStudents();

    // إغلاق الـ Dialog
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }
  // Future<void> _loadAdditionalData() async {
  //   try {
  //     // Commented out message-related code for future use
  //     // final prefs = await SharedPreferences.getInstance();
  //     // int? userId = prefs.getInt('user_id');
  //     // if (userId != null) {
  //     //   // Get unread messages count
  //     //   _unreadMessages = await messageController.getUnreadMessagesCount(userId);
  //     // }
  //
  //     // Calculate attendance data (simulated since we don't have the actual data)
  //     // In a real implementation, this would come from the attendance database
  //     _calculateAttendanceData();
  //
  //     // Calculate activities completion rate (simulated)
  //     _calculateActivitiesData();
  //
  //     setState(() {});
  //   } catch (e) {
  //     debugPrint("Error loading additional data: $e");
  //   }
  // }

  void _calculateAttendanceData() {
    // Simulate teacher attendance data based on current time
    // In a real implementation, this would come from the attendance collection in Firestore
    final now = DateTime.now();
    final totalTeachers = _teachers.length;

    if (totalTeachers > 0) {
      // Simulate that 70-90% of teachers are present
      _presentTeachers =
          (totalTeachers * (0.7 + (now.minute % 20) / 100)).round();

      // Simulate that 10-20% of present teachers are late (after 7:30 AM)
      _lateTeachers = (now.hour >= 7 && now.minute > 30)
          ? (_presentTeachers * (0.1 + (now.second % 10) / 100)).round()
          : 0;

      // Calculate attendance rate
      _attendanceRate =
          totalTeachers > 0 ? (_presentTeachers / totalTeachers) * 100 : 0;
    }
  }

  void _calculateActivitiesData() {
    // Simulate activities completion rate based on current date
    // In a real implementation, this would be calculated from actual activity data
    final now = DateTime.now();
    final dayOfMonth = now.day;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    // Calculate completion rate based on day of month (increases as month progresses)
    _activitiesCompletionRate = (dayOfMonth / daysInMonth) * 100;
  }

  // Future<void> syncData() async {
  //   sync.syncUsers;
  // }

  // void _showLoadingDialog() {
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           backgroundColor: Colors.white,
  //           shape:
  //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //           content: Padding(
  //             padding: EdgeInsets.symmetric(vertical: 20),
  //             child: Row(
  //               children: [
  //                 CircularProgressIndicator(
  //                   valueColor: AlwaysStoppedAnimation<Color>(
  //                       Theme.of(context).primaryColor),
  //                 ),
  //                 SizedBox(width: 20),
  //                 Expanded(
  //                   child: Text(
  //                     'الرجاء الانتظار حتى رفع البيانات',
  //                     style: TextStyle(
  //                       color: Colors.black87,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       }).then((value) {
  //     if (!mounted) return;
  //     Navigator.pop(context);
  //   });
  // }

  Future<void> _refreshData() async {
    try {
      sync.syncSchool();
      await schoolController.getData();
      await teacherController.getTeachers();
      // _totalStudents = await studentController.getTotalStudents();

      // Update additional data
      // await _loadAdditionalData();

      // Update current date
      _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      setState(() {});
      debugPrint(
          "Refreshed admin data: ${_schools.length} schools, ${_teachers.length} teachers, $_totalStudents students");

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('تم تحديث البيانات بنجاح'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      debugPrint("Error refreshing admin data: $e");
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('فشل في جلب البيانات: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لوحة تحكم المشرف',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () async {
              // Show confirmation dialog
              bool confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('تسجيل الخروج'),
                      content: Text('هل أنت متأكد من تسجيل الخروج؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('إلغاء'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pushReplacement(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => LoginScreen())),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('تسجيل الخروج'),
                        ),
                      ],
                    ),
                  ) ??
                  false;

              if (confirm) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushReplacement(context,
                    CupertinoPageRoute(builder: (context) => LoginScreen()));
              }
            },
            icon: Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      drawer: user == null ? null : DrawerList(user: user),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          loadStudentsWithDialog(context);
          _refreshData();
        },
        tooltip: 'تحديث البيانات',
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: user == null
            ? Center(child: Text("فشل في جلب بيانات المستخدم"))
            : SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    SizedBox(height: 24),
                    _buildStatCards(),
                    SizedBox(height: 24),

                    _buildSectionTitle('الإحصائيات', Icons.analytics),
                    SizedBox(height: 8),
                    // _buildChartCard('نسبة تنفيذ الأنشطة', Colors.blue, _activitiesCompletionRate),
                    SizedBox(height: 16),
                    _buildChartCard(
                        'نسبة حضور المعلمين', Colors.green, _attendanceRate),
                    SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً ${user?.first_name ?? "مشرف"}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'التاريخ: $_currentDate',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'آخر تحديث: ${DateTime.now().toString().substring(11, 16)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 12),
          _buildAttendanceSummary(),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAttendanceIndicator('حاضر', _presentTeachers, Colors.green),
        _buildAttendanceIndicator('متأخر', _lateTeachers, Colors.orange),
        _buildAttendanceIndicator(
            'غائب', _teachers.length - _presentTeachers, Colors.red),
      ],
    );
  }

  Widget _buildAttendanceIndicator(String label, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
            'عدد المدارس', '${_schools.length}', Icons.school, Colors.blue),
        _buildStatCard(
            'عدد المعلمين', '${_teachers.length}', Icons.person, Colors.green),
        Selector<StudentProvider, int>(
            builder: (context, prov, child) => _buildStatCard(
                'عدد الطلاب', '$prov', Icons.people, Colors.orange),
            selector: (_, s) => s.totalStudentCount),
        // تم تعليق بطاقة الرسائل غير المقروءة للاستخدام المستقبلي
        // _buildStatCard('الرسائل غير المقروءة', '$_unreadMessages', Icons.mail, Colors.red),
        _buildStatCard('نسبة الحضور', '${_attendanceRate.toStringAsFixed(1)}%',
            Icons.check_circle, Colors.teal),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        // Show details when tapped
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('تفاصيل $title')));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).primaryColor),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Color color, double percentage) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Show details when tapped
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('تفاصيل $title')));
          },
          child: ChartCard(
            title: title,
            color: color,
            percentage: percentage,
          ),
        ),
      ),
    );
  }
}
