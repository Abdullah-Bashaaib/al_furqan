import 'dart:developer';

import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/plan_controller.dart';
import 'package:al_furqan/models/conservation_plan_model.dart';
import 'package:al_furqan/models/eltlawah_plan_model.dart';
import 'package:al_furqan/models/islamic_studies_model.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:al_furqan/views/SchoolDirector/EditHalaga.dart';
import 'package:al_furqan/views/Teacher/HalqaReportScreen.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/models/halaga_model.dart';

class HalqaDetailsPage extends StatefulWidget {
  final HalagaModel halqa;
  final String teacher;
  const HalqaDetailsPage(
      {super.key, required this.halqa, required this.teacher});

  @override
  _HalqaDetailsPageState createState() => _HalqaDetailsPageState();
}

class _HalqaDetailsPageState extends State<HalqaDetailsPage> {
  List<StudentModel> students = [];
  bool _isLoading = false;
  HalagaModel? _halqaDetails;
  List<ConservationPlanModel> conservationPlans = [];
  List<EltlawahPlanModel> eltlawahPlans = [];
  List<IslamicStudiesModel> islamicStudyPlans = [];

  // خرائط لربط معرفات الطلاب بخططهم
  Map<String, ConservationPlanModel> studentConservationPlans = {};

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    _loadStudents();
    _loadHalqaDetails();
    await _loadPlanDetails();
    loadPlanFromFirebase();
  }

  Future<void> loadPlanFromFirebase() async {
    await planController.saveInLocal(widget.halqa.halagaID!);
    planController.conservationPlans.clear();
    planController.eltlawahPlans.clear();
    planController.islamicStudyPlans.clear();
    await _loadPlanDetails();
  }

  Future<void> _loadStudents() async {
    final String? halagaID = widget.halqa.halagaID;
    if (halagaID == null) {
      debugPrint("halagaID is null");
      if (mounted) {
        setState(() => students = []);
        // log("Students list in halaga Details ${students.length}");
      }
      return;
    }

    try {
      if (mounted) setState(() => _isLoading = true);
      final loadedStudents =
          await studentController.getStudents(halagaID) ?? [];
      if (mounted) {
        setState(() {
          students = loadedStudents;
          _isLoading = false;
          log("Loaded students: ${students.length}");
        });
      }
    } catch (e) {
      log("Error loading students: $e");
      if (mounted) {
        setState(() {
          students = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في جلب الطلاب: $e')),
        );
      }
    }
  }

  Future<void> _loadHalqaDetails() async {
    final String? halagaID = widget.halqa.halagaID;
    if (halagaID == null) return;

    try {
      setState(() => _isLoading = true);
      // الحصول على تفاصيل الحلقة بما في ذلك خطة الحفظ والتلاوة والعلوم الشرعية
      final details = await halagaController.getHalqaDetails(halagaID);
      if (mounted) {
        setState(() {
          _halqaDetails = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading halqa details: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPlanDetails() async {
    final String? halagaID = widget.halqa.halagaID;
    debugPrint("------> halagaID: $halagaID");
    if (halagaID == null) {
      debugPrint("------> halagaID is null, returning");
      return;
    }

    try {
      if (mounted) {
        setState(() => _isLoading = true);
      }

      // الحصول على تفاصيل الحلقة بما في ذلك خطة الحفظ والتلاوة والعلوم الشرعية
      await planController.getPlans(halagaID);

      // طباعة معلومات تصحيح للتحقق من البيانات
      debugPrint(
          "------> Conservation Plans: ${planController.conservationPlans.length}");
      debugPrint(
          "------> Eltlawah Plans: ${planController.eltlawahPlans.length}");
      debugPrint(
          "------> Islamic Study Plans: ${planController.islamicStudyPlans.length}");

      if (mounted) {
        // تعيين القوائم بشكل صحيح بدون استخدام async داخل setState
        setState(() {
          conservationPlans = planController.conservationPlans;
          eltlawahPlans = planController.eltlawahPlans;
          islamicStudyPlans = planController.islamicStudyPlans;

          // إنشاء خريطة من معرفات الطلاب إلى خطط الحفظ الخاصة بهم
          studentConservationPlans.clear();
          for (var plan in conservationPlans) {
            if (plan.studentId != null) {
              studentConservationPlans[plan.studentId!] = plan;
              debugPrint(
                  "------> Added plan for student ID: ${plan.studentId}");
            }
          }

          _isLoading = false;

          // طباعة معلومات تصحيح للتحقق من البيانات بعد التعيين
          debugPrint("------> Updated state with plans");
          debugPrint(
              "------> Local Conservation Plans: ${conservationPlans.length}");
          debugPrint("------> Local Eltlawah Plans: ${eltlawahPlans.length}");
          debugPrint(
              "------> Local Islamic Study Plans: ${islamicStudyPlans.length}");
          debugPrint(
              "------> Student Conservation Plans Map size: ${studentConservationPlans.length}");
        });
      }
    } catch (e) {
      debugPrint("Error loading halqa details: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // _loadPlanDetails();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'تفاصيل الحلقة',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // زر تقرير PDF
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            tooltip: 'تقرير PDF',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HalqaReportScreen(halqa: widget.halqa),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              // انتقال لصفحة التعديل واستقبال النتيجة
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditHalagaScreen(
                      halga: widget.halqa, teacher: widget.teacher),
                ),
              );

              // إذا تم التعديل بنجاح، قم بتحديث البيانات
              if (result == true) {
                // تحديث البيانات من قاعدة البيانات
                if (widget.halqa.halagaID != null) {
                  // تحديث البيانات من قاعدة البيانات أولاً
                  final updatedHalqa =
                      await halagaController.getData(widget.halqa.SchoolID!);

                  // البحث عن الحلقة بنفس المعرف
                  for (var halqa in updatedHalqa) {
                    if (halqa.halagaID == widget.halqa.halagaID) {
                      // تحديث بيانات الحلقة الحالية
                      setState(() {
                        widget.halqa.Name = halqa.Name;
                        widget.halqa.NumberStudent = halqa.NumberStudent;
                        // widget. = halqa.TeacherName;
                      });
                      break;
                    }
                  }
                }

                // تحديث الطلاب والتفاصيل
                _loadStudents();
                _loadHalqaDetails();

                // إظهار رسالة نجاح
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث بيانات الحلقة بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // بطاقة معلومات الحلقة
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.2)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Icon(Icons.school, color: Colors.white),
                              ),
                              title: Text(
                                widget.halqa.Name ?? 'اسم الحلقة غير متوفر',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.person,
                                    size: 18, color: Colors.grey[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'اسم المعلم: ${widget.teacher ?? 'غير متوفر'}',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.groups,
                                    size: 18, color: Colors.grey[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'عدد الطلاب: ${widget.halqa.NumberStudent ?? 0}',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // قسم خطط الحفظ والتلاوة والعلوم الشرعية
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.2)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'خطط وتنفيذ الحلقة',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const Divider(),

                            // خطة التلاوة
                            _buildRecitationPlanSection(),

                            const SizedBox(height: 15),
                            const Divider(),

                            // العلوم الشرعية
                            _buildIslamicStudiesSection(),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // قائمة الطلاب
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.people,
                                color: Theme.of(context).primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'الطلاب (${students.length})',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 350,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : students.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.group_off,
                                            size: 48,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'لا يوجد طلاب في هذه الحلقة',
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: students.length,
                                      itemBuilder: (context, index) {
                                        final student = students[index];
                                        final hasConservationPlan =
                                            studentConservationPlans
                                                .containsKey(student.studentID);

                                        return Card(
                                          margin:
                                              const EdgeInsets.only(bottom: 12),
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // معلومات الطالب
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 24,
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .primaryColor
                                                              .withOpacity(0.1),
                                                      child: Text(
                                                        student.firstName
                                                                ?.substring(
                                                                    0, 1)
                                                                .toUpperCase() ??
                                                            'S',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '${student.firstName ?? ''} ${student.middleName ?? ''} ${student.lastName ?? ''}'
                                                                .trim(),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                // خطة الحفظ
                                                if (hasConservationPlan) ...[
                                                  const SizedBox(height: 16),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[50],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey[200]!),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // المخطط
                                                        Row(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .assignment,
                                                                size: 16,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor),
                                                            const SizedBox(
                                                                width: 4),
                                                            Text(
                                                              'خطة الحفظ',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 6,
                                                                    horizontal:
                                                                        8),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Text('من: ',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey[600],
                                                                            fontSize: 12)),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        '${studentConservationPlans[student.studentID]?.plannedStartSurah ?? "غير محدد"} ${studentConservationPlans[student.studentID]?.plannedStartAya ?? ""}',
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            Expanded(
                                                              child: Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 6,
                                                                    horizontal:
                                                                        8),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                        'إلى: ',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey[600],
                                                                            fontSize: 12)),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        '${studentConservationPlans[student.studentID]?.plannedEndSurah ?? "غير محدد"} ${studentConservationPlans[student.studentID]?.plannedEndAya ?? ""}',
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        // المنفذ
                                                        const SizedBox(
                                                            height: 12),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .check_circle,
                                                                size: 16,
                                                                color: Colors
                                                                        .green[
                                                                    700]),
                                                            const SizedBox(
                                                                width: 4),
                                                            Text(
                                                              'المنفذ:',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .green[700],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 6,
                                                                    horizontal:
                                                                        8),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Text('من: ',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey[600],
                                                                            fontSize: 12)),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        '${studentConservationPlans[student.studentID]?.executedStartSurah ?? "غير محدد"} ${studentConservationPlans[student.studentID]?.executedStartAya ?? ""}',
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            Expanded(
                                                              child: Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 6,
                                                                    horizontal:
                                                                        8),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                        'إلى: ',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey[600],
                                                                            fontSize: 12)),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        '${studentConservationPlans[student.studentID]?.executedEndSurah ?? "غير محدد"} ${studentConservationPlans[student.studentID]?.executedEndAya ?? ""}',
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ] else ...[
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.info_outline,
                                                            size: 16,
                                                            color: Colors
                                                                .grey[600]),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          'لا توجد خطة حفظ لهذا الطالب',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[600]),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildConservationPlanSection() {
    // بيانات المخطط
    // String? plannedStartSurah = _halqaDetails?.conservationStartSurah;
    // String? plannedEndSurah = _halqaDetails?.conservationEndSurah;
    // int? plannedStartVerse = _halqaDetails?.conservationStartVerse;
    // int? plannedEndVerse = _halqaDetails?.conservationEndVerse;

    // بيانات المنفذ
    // String? executedStartSurah = _halqaDetails?.executedStartSurah;
    // String? executedEndSurah = _halqaDetails?.executedEndSurah;
    // int? executedStartVerse = _halqaDetails?.executedStartVerse;
    // int? executedEndVerse = _halqaDetails?.executedEndVerse;

    // نسبة الإنجاز (يمكن حساب هذه النسبة لاحقًا)
    String completionRate = '0%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.menu_book, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              'خطة الحفظ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // المخطط
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المخطط:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('من',
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text('none',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('إلى',
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text('none',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // المنفذ
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المنفذ:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('من',
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text('none',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('إلى',
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text('none',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('نسبة الإنجاز: ', style: TextStyle(fontSize: 14)),
                  Text(completionRate,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecitationPlanSection() {
    // بيانات المخطط
    String? plannedStartSurah;
    String? plannedEndSurah;
    int? plannedStartVerse;
    int? plannedEndVerse;

    // بيانات المنفذ
    String? executedStartSurah;
    String? executedEndSurah;
    int? executedStartVerse;
    int? executedEndVerse;

    // نسبة الإنجاز (يمكن حساب هذه النسبة لاحقًا)
    String completionRate = '0%';

    // طباعة معلومات تصحيح للتحقق من البيانات
    debugPrint(
        "_buildRecitationPlanSection - eltlawahPlans length: ${eltlawahPlans.length}");

    // تحقق من وجود خطط تلاوة قبل محاولة الوصول إليها
    if (eltlawahPlans.isNotEmpty) {
      plannedStartSurah = eltlawahPlans[0].plannedStartSurah;
      plannedEndSurah = eltlawahPlans[0].plannedEndSurah;
      plannedStartVerse = eltlawahPlans[0].plannedStartAya;
      plannedEndVerse = eltlawahPlans[0].plannedEndAya;

      executedStartSurah = eltlawahPlans[0].executedStartSurah;
      executedEndSurah = eltlawahPlans[0].executedEndSurah;
      executedStartVerse = eltlawahPlans[0].executedStartAya;
      executedEndVerse = eltlawahPlans[0].executedEndAya;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.record_voice_over,
                color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              'خطة التلاوة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // المخطط
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المخطط:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('من',
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(plannedStartSurah ?? 'none',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('إلى',
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(plannedEndSurah ?? 'none',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // المنفذ
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المنفذ:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('من',
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(executedStartSurah ?? 'none',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('إلى',
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(executedEndSurah ?? 'none',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('نسبة الإنجاز: ', style: TextStyle(fontSize: 14)),
                  Text(completionRate,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIslamicStudiesSection() {
    // بيانات العلوم الشرعية
    String? subject =
        islamicStudyPlans.isNotEmpty ? islamicStudyPlans[0].subject : null;
    String? plannedContent = islamicStudyPlans.isNotEmpty
        ? islamicStudyPlans[0].plannedContent
        : null;
    String? executedContent = islamicStudyPlans.isNotEmpty
        ? islamicStudyPlans[0].executedContent
        : null;

    // طباعة معلومات تصحيح للتحقق من البيانات
    debugPrint(
        "------> Islamic Study Plans in _buildIslamicStudiesSection: ${islamicStudyPlans.length}");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_library, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              'العلوم الشرعية',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // المقرر والمخطط
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المخطط:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('المقرر: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(subject ?? 'none'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('المحتوى: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(plannedContent ?? 'none'),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // المنفذ
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المنفذ:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('المحتوى: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(executedContent ?? 'none'),
                  ),
                ],
              ),
              // if (executionReason != null && executionReason.isNotEmpty) ...[
              //   const SizedBox(height: 12),
              //   Row(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       const Text('أسباب التأخر: ',
              //           style: TextStyle(fontWeight: FontWeight.bold)),
              //       Expanded(
              //         child: Text(executionReason,
              //             style: TextStyle(color: Colors.red[700])),
              //       ),
              //     ],
              //   ),
              // ],
            ],
          ),
        ),
      ],
    );
  }
}
