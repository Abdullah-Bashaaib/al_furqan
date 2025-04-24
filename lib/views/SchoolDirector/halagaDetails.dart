import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/views/SchoolDirector/EditHalaga.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/views/SchoolDirector/add_students_to_halqa_screen.dart';
import 'package:al_furqan/views/SchoolDirector/HalagaPlansScreen.dart';

class HalqaDetailsPage extends StatefulWidget {
  final HalagaModel halqa;
  const HalqaDetailsPage({super.key, required this.halqa});

  @override
  _HalqaDetailsPageState createState() => _HalqaDetailsPageState();
}

class _HalqaDetailsPageState extends State<HalqaDetailsPage> {
  List<StudentModel> students = [];
  bool _isLoading = false;
  HalagaModel? _halqaDetails;

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _loadHalqaDetails();
  }

  Future<void> _loadStudents() async {
    final int? halagaID = widget.halqa.halagaID;
    if (halagaID == null) {
      print("halagaID is null");
      if (mounted) {
        setState(() => students = []);
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
          print("Loaded students: ${students.length}");
        });
      }
    } catch (e) {
      print("Error loading students: $e");
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
    final int? halagaID = widget.halqa.halagaID;
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
      print("Error loading halqa details: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              // انتقال لصفحة التعديل واستقبال النتيجة
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditHalagaScreen(halga: widget.halqa),
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
                        widget.halqa.TeacherName = halqa.TeacherName;
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
                                  'اسم المعلم: ${widget.halqa.TeacherName ?? 'غير متوفر'}',
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

                            // خطة الحفظ
                            _buildConservationPlanSection(),

                            const SizedBox(height: 15),
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
                        Text(
                          'الطلاب',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
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
                                      itemCount: students.length,
                                      itemBuilder: (context, index) {
                                        final student = students[index];
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.1),
                                            child: Text(
                                              student.firstName
                                                      ?.substring(0, 1)
                                                      .toUpperCase() ??
                                                  'S',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            '${student.firstName ?? ''} ${student.middleName ?? ''} ${student.lastName ?? ''}'
                                                .trim(),
                                            style:
                                                const TextStyle(fontSize: 16),
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
    String? plannedStartSurah = _halqaDetails?.conservationStartSurah;
    String? plannedEndSurah = _halqaDetails?.conservationEndSurah;
    int? plannedStartVerse = _halqaDetails?.conservationStartVerse;
    int? plannedEndVerse = _halqaDetails?.conservationEndVerse;

    // بيانات المنفذ
    String? executedStartSurah = _halqaDetails?.executedStartSurah;
    String? executedEndSurah = _halqaDetails?.executedEndSurah;
    int? executedStartVerse = _halqaDetails?.executedStartVerse;
    int? executedEndVerse = _halqaDetails?.executedEndVerse;

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
                      Text(
                          plannedStartSurah != null
                              ? '${plannedStartSurah}${plannedStartVerse != null ? " - آية ${plannedStartVerse}" : ""}'
                              : 'لم يتم التحديد',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('إلى',
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(
                          plannedEndSurah != null
                              ? '${plannedEndSurah}${plannedEndVerse != null ? " - آية ${plannedEndVerse}" : ""}'
                              : 'لم يتم التحديد',
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
                      Text(
                          executedStartSurah != null
                              ? '${executedStartSurah}${executedStartVerse != null ? " - آية ${executedStartVerse}" : ""}'
                              : 'لم يتم التنفيذ بعد',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('إلى',
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(
                          executedEndSurah != null
                              ? '${executedEndSurah}${executedEndVerse != null ? " - آية ${executedEndVerse}" : ""}'
                              : 'لم يتم التنفيذ بعد',
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
    String? plannedStartSurah = _halqaDetails?.recitationStartSurah;
    String? plannedEndSurah = _halqaDetails?.recitationEndSurah;
    int? plannedStartVerse = _halqaDetails?.recitationStartVerse;
    int? plannedEndVerse = _halqaDetails?.recitationEndVerse;

    // بيانات المنفذ
    String? executedStartSurah = _halqaDetails?.executedStartSurah;
    String? executedEndSurah = _halqaDetails?.executedEndSurah;
    int? executedStartVerse = _halqaDetails?.executedStartVerse;
    int? executedEndVerse = _halqaDetails?.executedEndVerse;

    // نسبة الإنجاز (يمكن حساب هذه النسبة لاحقًا)
    String completionRate = '0%';

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
                      Text(
                          plannedStartSurah != null
                              ? '${plannedStartSurah}${plannedStartVerse != null ? " - آية ${plannedStartVerse}" : ""}'
                              : 'لم يتم التحديد',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('إلى',
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(
                          plannedEndSurah != null
                              ? '${plannedEndSurah}${plannedEndVerse != null ? " - آية ${plannedEndVerse}" : ""}'
                              : 'لم يتم التحديد',
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
                      Text(
                          executedStartSurah != null
                              ? '${executedStartSurah}${executedStartVerse != null ? " - آية ${executedStartVerse}" : ""}'
                              : 'لم يتم التنفيذ بعد',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('إلى',
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(
                          executedEndSurah != null
                              ? '${executedEndSurah}${executedEndVerse != null ? " - آية ${executedEndVerse}" : ""}'
                              : 'لم يتم التنفيذ بعد',
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
    String? subject = _halqaDetails?.islamicStudiesSubject;
    String? plannedContent = _halqaDetails?.islamicStudiesContent;
    String? executedContent = _halqaDetails?.executedIslamicContent;
    String? executionReason = _halqaDetails?.islamicExecutionReason;

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
                  Text(subject ?? 'لم يتم التحديد'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('المحتوى: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(plannedContent ?? 'لم يتم التحديد'),
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
                    child: Text(executedContent ?? 'لم يتم التنفيذ بعد'),
                  ),
                ],
              ),
              if (executionReason != null && executionReason.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('أسباب التأخر: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(executionReason,
                          style: TextStyle(color: Colors.red[700])),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
