import 'package:al_furqan/controllers/plan_controller.dart';
import 'package:al_furqan/helper/current_user.dart';
import 'package:al_furqan/models/conservation_plan_model.dart';
import 'package:al_furqan/models/eltlawah_plan_model.dart';
import 'package:al_furqan/models/islamic_studies_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/Teacher/printing_report.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/controllers/StudentController.dart';
// import 'package:al_furqan/helper/user_helper.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({Key? key}) : super(key: key);

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen>
// with UserDataMixin
{
  final StudentController _studentController = StudentController();
  final PlanController planController = PlanController();
  List<StudentModel> _students = [];
  EltlawahPlanModel? eltlawahPlan;
  List<ConservationPlanModel> _conservationPlans = [];
  IslamicStudiesModel? _islamicStudyPlan;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _selectedMonth = DateTime.now();
  UserModel? user = CurrentUser.user;

  // بيانات التقرير
  Map<String?, Map<String, dynamic>> _reportData = {};

  @override
  void initState() {
    super.initState();
    // تهيئة بيانات اللغة العربية للتاريخ
    initializeDateFormatting('ar', null).then((_) {
      _loadStudents();
    });
  }

  Future<void> _loadPlans() async {
    await planController.getPlans(user!.elhalagatID!);

    // تنسيق التاريخ بصيغة "سنة-شهر" مثل "2025-05"
    String currentMonthFormat = _loadEtlawahPaln();

    for (var islamicStudyPlan in planController.islamicStudyPlans) {
      if (islamicStudyPlan.planMonth == currentMonthFormat) {
        _islamicStudyPlan = islamicStudyPlan;
        break;
      }
    }

    setState(() {
      _conservationPlans = planController.conservationPlans;
    });

    // التحقق من وجود خطط حفظ
    if (_conservationPlans.isEmpty) {
      // عرض مربع حوار للتنبيه
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('تنبيه'),
              content:
                  Text('لا توجد خطط حفظ للطلاب. يرجى إضافة خطط الحفظ أولاً.'),
              actions: [
                TextButton(
                  child: Text('موافق'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // العودة إلى الدراور
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      });
    }
  }

  String _loadEtlawahPaln() {
    // تنسيق التاريخ بصيغة "سنة-شهر" مثل "2025-05"
    String monthStr = _selectedMonth.month < 10
        ? "0${_selectedMonth.month}"
        : "${_selectedMonth.month}";
    String currentMonthFormat = "${_selectedMonth.year}-$monthStr";
    print("currentMonthFormat: $currentMonthFormat");

    // طباعة عدد خطط التلاوة المتوفرة
    print("عدد خطط التلاوة: ${planController.eltlawahPlans.length}");

    // طباعة تنسيق التاريخ لكل خطة تلاوة للتحقق
    // for (var plan in planController.eltlawahPlans) {
    //   print(
    //       "خطة التلاوة - planMonth: '${plan.planMonth}' للطالب: ${plan.studentId}");
    // }

    for (var eltlawahPlan in planController.eltlawahPlans) {
      if (eltlawahPlan.planMonth == currentMonthFormat) {
        this.eltlawahPlan = eltlawahPlan;
        print("تم العثور على خطة التلاوة: $eltlawahPlan");
        break;
      }
    }

    // التحقق من نتيجة البحث
    if (this.eltlawahPlan == null) {
      print("لم يتم العثور على خطة تلاوة للشهر: $currentMonthFormat");
    }
    return currentMonthFormat;
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // if (user == null || user!.elhalagatID == null) {
      //   await fetchUserData();
      //   if (user == null || user!.elhalagatID == null) {
      //     setState(() {
      //       _errorMessage = "لم يتم العثور على بيانات المستخدم أو الحلقة";
      //       _isLoading = false;
      //     });
      //     return;
      //   }
      // }

      // تحميل الطلاب من حلقة المعلم
      final students = await _studentController.getStudents(user!.elhalagatID!);
      await _loadPlans();

      // إنشاء بيانات تجريبية للتقرير
      _generateDemoReportData(students);

      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "حدث خطأ أثناء تحميل بيانات الطلاب: $e";
        _isLoading = false;
      });
    }
  }

  // دالة لإنشاء بيانات تجريبية للتقرير
  void _generateDemoReportData(List<StudentModel> students) {
    // التحقق من وجود خطط حفظ قبل إنشاء البيانات
    if (_conservationPlans.isEmpty) {
      return; // الخروج من الدالة إذا لم تكن هناك خطط
    }

    for (var student in students) {
      // إنشاء بيانات تجريبية لكل طالب
      final totalDays = 30;
      final attendanceDays = student.attendanceDays ?? 0;
      final absenceDays = student.absenceDays ?? 0;

      // خطة الحفظ
      final conservationPlan = _conservationPlans
          .firstWhere((plan) => plan.studentId == student.studentID);

      _reportData[student.studentID] = {
        'totalDays': totalDays,
        'attendanceDays': attendanceDays,
        'absenceDays': absenceDays,
        'attendanceRate': (attendanceDays / totalDays * 100).toStringAsFixed(1),
        'executedEndSurah': conservationPlan.executedEndSurah ?? 'لا توجد خطة',
        'executedEndAya': conservationPlan.executedEndAya ?? 0,
        'executedRate': conservationPlan.executedRate ?? 0.0,
      };
    }
  }

  // دالة لتغيير الشهر المحدد
  void _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
        // هنا يمكن إعادة تحميل البيانات للشهر المحدد
        _generateDemoReportData(_students);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('التقرير الشهري'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _selectMonth,
            tooltip: 'اختر الشهر',
          ),
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MonthlyReportPDFScreen(
                    students: _students,
                    reportData: _reportData,
                    eltlawahPlan: eltlawahPlan,
                    islamicStudyPlan: _islamicStudyPlan,
                    selectedMonth: _selectedMonth,
                  ),
                ),
              );
            },
            tooltip: 'طباعة التقرير',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child:
                      Text(_errorMessage!, style: TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // عرض الشهر المحدد
                      Container(
                        padding: EdgeInsets.all(16),
                        color: Colors.grey.shade100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'تقرير شهر:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              DateFormat('MMMM yyyy', 'ar')
                                  .format(_selectedMonth),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      // إحصائيات عامة
                      Container(
                        padding: EdgeInsets.all(16),
                        color: Colors.grey.shade200,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: _buildStatCard(
                                  'إجمالي الطلاب',
                                  _students.length.toString(),
                                  Colors.blue,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: _buildStatCard(
                                  'متوسط الحضور',
                                  _calculateAverageAttendance(),
                                  Colors.green,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: _buildStatCard(
                                  'عدد أيام الشهر',
                                  '30',
                                  Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // كارد خطة التلاوة والعلوم الشرعية
                      Container(
                        margin: EdgeInsets.only(
                            top: 16, bottom: 16, left: 16, right: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // العنوان
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.menu_book, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'خطة التلاوة والعلوم الشرعية',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // محتوى الكارد
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  // خطة التلاوة
                                  _buildPlanSection(
                                    title: 'خطة التلاوة',
                                    icon: Icons.import_contacts,
                                    color: Colors.green,
                                    items: [
                                      eltlawahPlan == null
                                          ? SizedBox()
                                          : _buildPlanItem(
                                              eltlawahPlan!.executedEndSurah!,
                                              'الآيات 1-${eltlawahPlan!.executedEndAya!}',
                                              '${eltlawahPlan!.executedRate!}%'),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Divider(),
                                  SizedBox(height: 16),
                                  // خطة العلوم الشرعية
                                  _buildPlanSection(
                                    title: 'خطة العلوم الشرعية',
                                    icon: Icons.school,
                                    color: Colors.blue,
                                    items: [
                                      _buildPlanItem(
                                        _islamicStudyPlan!.subject!,
                                        _islamicStudyPlan!.executedContent!,
                                        '100%',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // جدول خطة حفظ الطلاب
                      Container(
                        margin: EdgeInsets.only(
                            top: 16, bottom: 16, left: 16, right: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // العنوان
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.auto_stories, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'جدول خطة حفظ الطلاب',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // محتوى الجدول
                            _students.isEmpty
                                ? Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Center(
                                        child:
                                            Text('لا يوجد طلاب في هذه الحلقة')),
                                  )
                                : Column(
                                    children: [
                                      // عنوان الجدول
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16),
                                        color: Colors.grey.shade100,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'اسم الطالب',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                'السورة الحالية',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                'الآية الحالية',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                'نسبة الإنجاز',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // صفوف الجدول
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: _students.length,
                                        itemBuilder: (context, index) {
                                          final student = _students[index];
                                          // بيانات تجريبية لخطة الحفظ
                                          final reportData =
                                              _reportData[student.studentID];

                                          // اختيار بيانات عشوائية لكل طالب

                                          // final surah = reportData!
                                          //     ['conservationPlan'];
                                          // final dailyAssignment =
                                          //     surah['dailyAssignment'];
                                          // final progress =
                                          //     surah['progress'];
                                          final progressValue =
                                              reportData!['executedRate'] ??
                                                  '0';

                                          return Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 16),
                                            decoration: BoxDecoration(
                                              color: index % 2 == 0
                                                  ? Colors.white
                                                  : Colors.grey.shade50,
                                              border: Border(
                                                bottom:
                                                    index < _students.length - 1
                                                        ? BorderSide(
                                                            color: Colors
                                                                .grey.shade200)
                                                        : BorderSide.none,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                // اسم الطالب
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    '${student.firstName ?? ''} ${student.middleName ?? ''} ${student.lastName ?? ''}',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                // السورة الحالية
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    reportData[
                                                        'executedEndSurah']!,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                // المقرر اليومي
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    "${reportData['executedEndAya']}",
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                // نسبة الإنجاز
                                                Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "${reportData['executedRate']}",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              _getProgressColor(
                                                                  progressValue),
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      SizedBox(height: 4),
                                                      LinearProgressIndicator(
                                                        value:
                                                            progressValue / 100,
                                                        backgroundColor: Colors
                                                            .grey.shade200,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                _getProgressColor(
                                                                    progressValue)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                      // جدول التقرير
                      _students.isEmpty
                          ? Container(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                  child: Text('لا يوجد طلاب في هذه الحلقة')),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  // عنوان الجدول
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        _buildTableHeader('اسم الطالب', 3),
                                        _buildTableHeader('أيام الحضور', 1),
                                        _buildTableHeader('أيام الغياب', 1),
                                        _buildTableHeader('نسبة الحضور', 1),
                                      ],
                                    ),
                                  ),
                                  // صفوف الجدول
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: _students.length,
                                      itemBuilder: (context, index) {
                                        final student = _students[index];
                                        final reportData =
                                            _reportData[student.studentID];

                                        return Container(
                                          decoration: BoxDecoration(
                                            color: index % 2 == 0
                                                ? Colors.white
                                                : Colors.grey.shade50,
                                            border: Border(
                                              bottom: index <
                                                      _students.length - 1
                                                  ? BorderSide(
                                                      color:
                                                          Colors.grey.shade300)
                                                  : BorderSide.none,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              _buildTableCell(
                                                '${student.firstName ?? ''} ${student.middleName ?? ''} ${student.lastName ?? ''}',
                                                3,
                                                alignment:
                                                    Alignment.centerRight,
                                              ),
                                              _buildTableCell(
                                                reportData?['attendanceDays']
                                                        ?.toString() ??
                                                    '0',
                                                1,
                                              ),
                                              _buildTableCell(
                                                reportData?['absenceDays']
                                                        ?.toString() ??
                                                    '0',
                                                1,
                                              ),
                                              _buildTableCell(
                                                '${reportData?['attendanceRate'] ?? '0'}%',
                                                1,
                                                color: _getAttendanceColor(
                                                  double.tryParse(reportData?[
                                                              'attendanceRate'] ??
                                                          '0') ??
                                                      0,
                                                ),
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
                    ],
                  ),
                ),
    );
  }

  // حساب متوسط نسبة الحضور
  String _calculateAverageAttendance() {
    if (_reportData.isEmpty) return '0%';

    double total = 0;
    for (var data in _reportData.values) {
      total += double.tryParse(data['attendanceRate'] ?? '0') ?? 0;
    }

    return '${(total / _reportData.length).toStringAsFixed(1)}%';
  }

  // تحديد لون نسبة الحضور
  Color _getAttendanceColor(double rate) {
    if (rate >= 90) return Colors.green;
    if (rate >= 75) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String title, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTableCell(
    String text,
    int flex, {
    Alignment alignment = Alignment.center,
    Color? color,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        alignment: alignment,
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // دالة لبناء قسم من أقسام الخطة (التلاوة أو العلوم الشرعية)
  Widget _buildPlanSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        // عناصر القسم
        ...items,
      ],
    );
  }

  // دالة لبناء عنصر من عناصر الخطة
  Widget _buildPlanItem(String title, String subtitle, String progress) {
    // تحويل النسبة المئوية إلى قيمة عددية
    final double progressValue =
        double.tryParse(progress.replaceAll('%', '')) ?? 0;
    final Color progressColor = _getProgressColor(progressValue);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          // معلومات العنصر
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          // نسبة الإنجاز
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  progress,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
                SizedBox(height: 4),
                // شريط التقدم
                LinearProgressIndicator(
                  value: progressValue / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // دالة لتحديد لون نسبة الإنجاز
  Color _getProgressColor(double progress) {
    if (progress >= 80) return Colors.green;
    if (progress >= 60) return Colors.orange;
    return Colors.red;
  }
}
