import 'package:al_furqan/controllers/plan_controller.dart';
import 'package:al_furqan/models/conservation_plan_model.dart';
import 'package:al_furqan/models/eltlawah_plan_model.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/islamic_studies_model.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/utils.dart';

class EditHalagaPlanScreen extends StatefulWidget {
  final HalagaModel halaga;
  final dynamic
      plan; // يمكن أن يكون ConservationPlanModel أو EltlawahPlanModel أو IslamicStudiesModel
  final String planType; // "conservation", "tlawah", "islamic"
  final StudentModel student;

  const EditHalagaPlanScreen({
    super.key,
    required this.halaga,
    required this.plan,
    required this.planType,
    required this.student,
  });

  @override
  _EditHalagaPlanScreenState createState() => _EditHalagaPlanScreenState();
}

class _EditHalagaPlanScreenState extends State<EditHalagaPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  late String titleText;

  // المخطط
  final TextEditingController plannedStartSurahController =
      TextEditingController();
  final TextEditingController plannedEndSurahController =
      TextEditingController();
  final TextEditingController plannedStartVerseController =
      TextEditingController();
  final TextEditingController plannedEndVerseController =
      TextEditingController();

  // المنفذ
  final TextEditingController executedStartSurahController =
      TextEditingController();
  final TextEditingController executedEndSurahController =
      TextEditingController();
  final TextEditingController executedStartVerseController =
      TextEditingController();
  final TextEditingController executedEndVerseController =
      TextEditingController();

  // العلوم الشرعية
  final TextEditingController plannedContentController =
      TextEditingController();
  final TextEditingController executedContentController =
      TextEditingController();
  String? selectedIslamicSubject;

  final List<String> islamicSubjects = [
    'التفسير',
    'الحديث',
    'الفقه',
    'السيرة النبوية',
    'القصص',
    'العقيدة',
    'الأخلاق',
  ];

  // الشهر
  String planMonth = DateFormat('yyyy-MM').format(DateTime.now());

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPlanData();
    _setTitleText();
  }

  void _setTitleText() {
    switch (widget.planType) {
      case "conservation":
        titleText = "تعديل خطة الحفظ";
        break;
      case "tlawah":
        titleText = "تعديل خطة التلاوة";
        break;
      case "islamic":
        titleText = "تعديل خطة العلوم الشرعية";
        break;
      default:
        titleText = "تعديل الخطة";
    }
  }

  void _loadPlanData() {
    if (widget.planType == "conservation") {
      ConservationPlanModel plan = widget.plan as ConservationPlanModel;

      // تعيين بيانات المخطط
      plannedStartSurahController.text = plan.plannedStartSurah ?? '';
      plannedEndSurahController.text = plan.plannedEndSurah ?? '';
      plannedStartVerseController.text = plan.plannedStartAya?.toString() ?? '';
      plannedEndVerseController.text = plan.plannedEndAya?.toString() ?? '';

      // تعيين بيانات المنفذ
      executedStartSurahController.text = plan.executedStartSurah ?? '';
      executedEndSurahController.text = plan.executedEndSurah ?? '';
      executedStartVerseController.text =
          plan.executedStartAya?.toString() ?? '';
      executedEndVerseController.text = plan.executedEndAya?.toString() ?? '';

      // تعيين الشهر
      planMonth =
          plan.planMonth ?? DateFormat('yyyy-MM').format(DateTime.now());
    } else if (widget.planType == "tlawah") {
      EltlawahPlanModel plan = widget.plan as EltlawahPlanModel;

      // تعيين بيانات المخطط
      plannedStartSurahController.text = plan.plannedStartSurah ?? '';
      plannedEndSurahController.text = plan.plannedEndSurah ?? '';
      plannedStartVerseController.text = plan.plannedStartAya?.toString() ?? '';
      plannedEndVerseController.text = plan.plannedEndAya?.toString() ?? '';

      // تعيين بيانات المنفذ
      executedStartSurahController.text = plan.executedStartSurah ?? '';
      executedEndSurahController.text = plan.executedEndSurah ?? '';
      executedStartVerseController.text =
          plan.executedStartAya?.toString() ?? '';
      executedEndVerseController.text = plan.executedEndAya?.toString() ?? '';

      // تعيين الشهر
      planMonth =
          plan.planMonth ?? DateFormat('yyyy-MM').format(DateTime.now());
    } else if (widget.planType == "islamic") {
      IslamicStudiesModel plan = widget.plan as IslamicStudiesModel;

      // تعيين المادة
      selectedIslamicSubject = plan.subject;

      // تعيين المحتوى المخطط والمنفذ
      plannedContentController.text = plan.plannedContent ?? '';
      executedContentController.text = plan.executedContent ?? '';

      // تعيين الشهر
      planMonth =
          plan.planMonth ?? DateFormat('yyyy-MM').format(DateTime.now());
    }
  }

  Future<void> _updatePlan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.planType == "conservation") {
        ConservationPlanModel plan = widget.plan as ConservationPlanModel;

        // تحديث بيانات المخطط
        plan.plannedStartSurah = plannedStartSurahController.text;
        plan.plannedEndSurah = plannedEndSurahController.text;
        plan.plannedStartAya = int.tryParse(plannedStartVerseController.text);
        plan.plannedEndAya = int.tryParse(plannedEndVerseController.text);

        // تحديث بيانات المنفذ
        plan.executedStartSurah = executedStartSurahController.text;
        plan.executedEndSurah = executedEndSurahController.text;
        plan.executedStartAya = int.tryParse(executedStartVerseController.text);
        plan.executedEndAya = int.tryParse(executedEndVerseController.text);

        // تحديث الشهر
        plan.planMonth = planMonth;

        // وضع علامة للمزامنة
        plan.isSync = 0;

        // وضع معدل التنفيذ
        debugPrint(
            "DEBUG: plannedEndSurah = ${plan.plannedEndSurah}, executedEndSurah = ${plan.executedEndSurah}");
        debugPrint(
            "DEBUG: plannedEndAya = ${plan.plannedEndAya}, executedEndAya = ${plan.executedEndAya}");

        // تحسين حساب معدل التنفيذ
        if (plan.executedEndSurah == plan.plannedEndSurah) {
          debugPrint("DEBUG: السورة متطابقة، جاري حساب المعدل");
          if (plan.plannedEndAya != null &&
              plan.executedEndAya != null &&
              plan.plannedEndAya! > 0) {
            if (plan.plannedEndAya! >= plan.executedEndAya!) {
              double executedRate =
                  (plan.executedEndAya! / plan.plannedEndAya!) * 100;
              plan.executedRate = executedRate;
              debugPrint("DEBUG: تم حساب المعدل = ${plan.executedRate}%");
            } else {
              plan.executedRate =
                  100.0; // إذا كان المنفذ أكثر من المخطط، فقد تم تنفيذ 100%
              debugPrint("DEBUG: المنفذ أكبر من المخطط، المعدل = 100%");
            }
          } else {
            plan.executedRate = 0.0;
            debugPrint("DEBUG: قيم الآيات غير صالحة، المعدل = 0%");
          }
        } else {
          // يمكن إضافة حساب أكثر تعقيدًا هنا للسور المختلفة
          plan.executedRate = 0.0;
          debugPrint("DEBUG: السور مختلفة، المعدل = 0%");
        }

        // تحديث في قاعدة البيانات - سنستخدم updatePlan لأن updateConservationPlan غير معرف
        await planController.updateConservationPlan2(plan);
      } else if (widget.planType == "tlawah") {
        EltlawahPlanModel plan = widget.plan as EltlawahPlanModel;

        // تحديث بيانات المخطط
        plan.plannedStartSurah = plannedStartSurahController.text;
        plan.plannedEndSurah = plannedEndSurahController.text;
        plan.plannedStartAya = int.tryParse(plannedStartVerseController.text);
        plan.plannedEndAya = int.tryParse(plannedEndVerseController.text);

        // تحديث بيانات المنفذ
        plan.executedStartSurah = executedStartSurahController.text;
        plan.executedEndSurah = executedEndSurahController.text;
        plan.executedStartAya = int.tryParse(executedStartVerseController.text);
        plan.executedEndAya = int.tryParse(executedEndVerseController.text);

        // تحديث الشهر
        plan.planMonth = planMonth;

        // وضع علامة للمزامنة
        plan.isSync = 0;

        // وضع معدل التنفيذ
        debugPrint(
            "DEBUG: plannedEndSurah = ${plan.plannedEndSurah}, executedEndSurah = ${plan.executedEndSurah}");
        debugPrint(
            "DEBUG: plannedEndAya = ${plan.plannedEndAya}, executedEndAya = ${plan.executedEndAya}");

        // تحسين حساب معدل التنفيذ
        if (plan.executedEndSurah == plan.plannedEndSurah) {
          debugPrint("DEBUG: السورة متطابقة، جاري حساب المعدل");
          if (plan.plannedEndAya != null &&
              plan.executedEndAya != null &&
              plan.plannedEndAya! > 0) {
            if (plan.plannedEndAya! >= plan.executedEndAya!) {
              double executedRate =
                  (plan.executedEndAya! / plan.plannedEndAya!) * 100;
              plan.executedRate = executedRate.roundToDouble();
              debugPrint("DEBUG: تم حساب المعدل = ${plan.executedRate}%");
            } else {
              plan.executedRate =
                  100.0; // إذا كان المنفذ أكثر من المخطط، فقد تم تنفيذ 100%
              debugPrint("DEBUG: المنفذ أكبر من المخطط، المعدل = 100%");
            }
          } else {
            plan.executedRate = 0.0;
            debugPrint("DEBUG: قيم الآيات غير صالحة، المعدل = 0%");
          }
        } else {
          // يمكن إضافة حساب أكثر تعقيدًا هنا للسور المختلفة
          plan.executedRate = 0.0;
          debugPrint("DEBUG: السور مختلفة، المعدل = 0%");
        }

        // تحديث في قاعدة البيانات - سنستخدم updateEltlawahPlan2 لأن updateEltlawahPlan غير معرف
        await planController.updateEltlawahPlan2(plan);
      } else if (widget.planType == "islamic") {
        IslamicStudiesModel plan = widget.plan as IslamicStudiesModel;

        // تحديث المادة والمحتوى
        plan.subject = selectedIslamicSubject;
        plan.plannedContent = plannedContentController.text;
        plan.executedContent = executedContentController.text;

        // تحديث الشهر
        plan.planMonth = planMonth;

        // وضع علامة للمزامنة
        plan.isSync = 0;

        // تحديث في قاعدة البيانات - سنستخدم updateIslamicStudies2 لأن updateIslamicStudies غير معرف
        await planController.updateIslamicStudies2(plan);
      }

      setState(() {
        _isLoading = false;
      });

      Utils.showSnackBarSuccess(context, "تم تحديث الخطة بنجاح");
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء تحديث الخطة: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titleText, style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات الطالب
              _buildStudentInfoCard(),
              SizedBox(height: 24),

              // رأس الخطة والشهر
              _buildHeaderSection(),
              SizedBox(height: 24),

              // بناء محتوى الشاشة حسب نوع الخطة
              if (widget.planType == "conservation" ||
                  widget.planType == "tlawah")
                _buildQuranPlanContent(),

              if (widget.planType == "islamic") _buildIslamicStudiesContent(),

              // رسائل الخطأ
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              // زر التحديث
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('تحديث الخطة', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              radius: 24,
              child: Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.student.firstName} ${widget.student.lastName}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "حلقة: ${widget.halaga.Name}",
                    style: TextStyle(
                      color: Colors.grey[600],
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

  Widget _buildHeaderSection() {
    return Row(
      children: [
        Icon(
          _getPlanIcon(),
          color: Theme.of(context).primaryColor,
          size: 28,
        ),
        SizedBox(width: 10),
        Text(
          _getPlanTitle(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Spacer(),
        // يمكن إضافة حقل لاختيار الشهر هنا
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_month, color: Colors.blue, size: 18),
              SizedBox(width: 8),
              Text(
                "شهر: $planMonth",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuranPlanContent() {
    return Column(
      children: [
        // قسم المخطط
        _buildCard(
          title: "المخطط",
          icon: Icons.check_circle,
          color: Colors.green,
          child: Column(
            children: [
              _buildSurahInputRow(
                label: 'من',
                surahController: plannedStartSurahController,
                verseController: plannedStartVerseController,
                surahHint: 'سورة الفاتحة',
              ),
              SizedBox(height: 16),
              _buildSurahInputRow(
                label: 'إلى',
                surahController: plannedEndSurahController,
                verseController: plannedEndVerseController,
                surahHint: 'سورة البقرة',
              ),
            ],
          ),
        ),

        SizedBox(height: 24),

        // قسم المنفذ
        _buildCard(
          title: "المنفذ",
          icon: Icons.assignment_turned_in,
          color: Colors.orange,
          child: Column(
            children: [
              _buildSurahInputRow(
                label: 'من',
                surahController: executedStartSurahController,
                verseController: executedStartVerseController,
                surahHint: 'سورة الفاتحة',
              ),
              SizedBox(height: 16),
              _buildSurahInputRow(
                label: 'إلى',
                surahController: executedEndSurahController,
                verseController: executedEndVerseController,
                surahHint: 'سورة البقرة',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIslamicStudiesContent() {
    return Column(
      children: [
        // قسم المخطط
        _buildCard(
          title: "المخطط",
          icon: Icons.check_circle,
          color: Colors.green,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'المقرر',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Spacer(),
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text('اختر المقرر'),
                          value: selectedIslamicSubject,
                          items: islamicSubjects.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedIslamicSubject = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: _showAddSubjectDialog,
                    icon: Icon(Icons.add_circle),
                    color: Theme.of(context).primaryColor,
                    tooltip: 'إضافة مقرر جديد',
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'المحتوى المخطط',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: plannedContentController,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "الحقل مطلوب!";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'أدخل المحتوى المخطط للمقرر',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24),

        // قسم المنفذ
        _buildCard(
          title: "المنفذ",
          icon: Icons.assignment_turned_in,
          color: Colors.orange,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المحتوى المنفذ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: executedContentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'أدخل المحتوى المنفذ للمقرر',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSurahInputRow({
    required String label,
    required TextEditingController surahController,
    required TextEditingController verseController,
    required String surahHint,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: surahController,
            textAlign: TextAlign.center,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "مطلوب";
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: surahHint,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Text(
          'آية:',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: TextFormField(
            controller: verseController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "مطلوب";
              }
              return null;
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddSubjectDialog() {
    final TextEditingController newSubjectController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة مقرر جديد'),
        content: TextField(
          controller: newSubjectController,
          decoration: InputDecoration(
            labelText: 'اسم المقرر',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newSubjectController.text.isNotEmpty) {
                setState(() {
                  islamicSubjects.add(newSubjectController.text);
                  selectedIslamicSubject = newSubjectController.text;
                });
                Navigator.pop(context);
              }
            },
            child: Text('إضافة'),
          ),
        ],
      ),
    );
  }

  IconData _getPlanIcon() {
    switch (widget.planType) {
      case "conservation":
        return Icons.menu_book;
      case "tlawah":
        return Icons.record_voice_over;
      case "islamic":
        return Icons.local_library;
      default:
        return Icons.edit_note;
    }
  }

  String _getPlanTitle() {
    switch (widget.planType) {
      case "conservation":
        return "خطة الحفظ";
      case "tlawah":
        return "خطة التلاوة";
      case "islamic":
        return "خطة العلوم الشرعية";
      default:
        return "الخطة";
    }
  }
}
