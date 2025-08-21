import 'package:al_furqan/controllers/plan_controller.dart';
import 'package:al_furqan/models/conservation_plan_model.dart';
import 'package:al_furqan/models/eltlawah_plan_model.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/islamic_studies_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/utils.dart';

class AddHalagaPlansScreen extends StatefulWidget {
  HalagaModel halaga;
  AddHalagaPlansScreen({super.key, required this.halaga});

  @override
  _HalagaPlansScreenState createState() =>
      _HalagaPlansScreenState(halaga: halaga);
}

class _HalagaPlansScreenState extends State<AddHalagaPlansScreen> {
  final _formKey = GlobalKey<FormState>();
  HalagaModel halaga;
  _HalagaPlansScreenState({required this.halaga});

  final List<String> islamicSubjects = [
    'التفسير',
    'الحديث',
    'الفقه',
    'السيرة النبوية',
    'القصص',
    'العقيدة',
    'الأخلاق',
  ];

  String? selectedIslamicSubject;

  final TextEditingController conservationStartSurahController =
      TextEditingController();
  final TextEditingController conservationEndSurahController =
      TextEditingController();
  final TextEditingController conservationStartVerseController =
      TextEditingController();
  final TextEditingController conservationEndVerseController =
      TextEditingController();

  final TextEditingController recitationStartSurahController =
      TextEditingController();
  final TextEditingController recitationEndSurahController =
      TextEditingController();
  final TextEditingController recitationStartVerseController =
      TextEditingController();
  final TextEditingController recitationEndVerseController =
      TextEditingController();

  final TextEditingController islamicStudiesContentController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _savePlans() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await planController.clearAllPlans(); // حذف البيانات القديمة
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('halagaID', halaga.halagaID!);
      debugPrint("-----------------Add------------------------");
      List<String> studentsID =
          await planController.getAllStudentsHalaga(halaga.halagaID!);
      debugPrint("-----> studentsID = $studentsID");

      for (String item in studentsID) {
        debugPrint("----------> Processing studentId: $item");

        // التحقق من صحة السور
        if (!isValidSurah(conservationStartSurahController.text) ||
            !isValidSurah(conservationEndSurahController.text) ||
            !isValidSurah(recitationStartSurahController.text) ||
            !isValidSurah(recitationEndSurahController.text)) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'أسماء السور غير صالحة';
          });
          return;
        }

        // إضافة خطة الحفظ
        int conservationResult = await planController.addConservationPlan2(
          ConservationPlanModel(
            elhalagatId: halaga.halagaID,
            studentId: item,
            plannedStartSurah: conservationStartSurahController.text,
            plannedStartAya:
                int.tryParse(conservationStartVerseController.text),
            plannedEndSurah: conservationEndSurahController.text,
            plannedEndAya: int.tryParse(conservationEndVerseController.text),
            executedStartSurah: "لا يوجد",
            executedStartAya: 0,
            executedEndSurah: "لا يوجد",
            executedEndAya: 0,
            executedRate: 0,
            isSync: 0,
          ),
        );

        // التحقق من نجاح العمليات
        if (conservationResult <= 0) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'فشل في إضافة خطط الطالب $item';
          });
          return;
        }
      }
      // إضافة خطة التلاوة
      int eltlawahResult = await planController.addEltlawahPlan2(
        EltlawahPlanModel(
          elhalagatId: halaga.halagaID,
          plannedStartSurah: recitationStartSurahController.text,
          plannedStartAya: int.tryParse(recitationStartVerseController.text),
          plannedEndSurah: recitationEndSurahController.text,
          plannedEndAya: int.tryParse(recitationEndVerseController.text),
          executedStartSurah: "لا يوجد",
          executedStartAya: 0,
          executedEndSurah: "لا يوجد",
          executedEndAya: 0,
          executedRate: 0,
          isSync: 0,
        ),
      );
      if (eltlawahResult <= 0) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'فشل في إضافة خطط التلاوة';
        });
        return;
      }
      // إضافة خطة العلوم الشرعية
      int islamicResult = await planController.addIslamicStudies2(
        IslamicStudiesModel(
            elhalagatID: halaga.halagaID,
            subject: selectedIslamicSubject,
            plannedContent: islamicStudiesContentController.text,
            planMonth: "2025-05",
            isSync: 0,
            executedContent: "لا يوجد"),
      );
      if (islamicResult <= 0) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'فشل في إضافة خطط العلوم الشرعية';
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });

      Utils.showSnackBarSuccess(context, "تم حفظ الخطط بنجاح");
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء حفظ الخطط: $e';
      });
    }
  }

  bool isValidSurah(String surah) {
    final validSurahs = [
      'الفاتحة',
      'البقرة',
      'آل عمران',
      'النساء',
      'المائدة',
      'الأنعام',
      'الأعراف',
      'الأنفال',
      'التوبة',
      'يونس',
      'هود',
      'يوسف',
      'الرعد',
      'إبراهيم',
      'الحجر',
      'النحل',
      'الإسراء',
      'الكهف',
      'مريم',
      'طه',
      'الأنبياء',
      'الحج',
      'المؤمنون',
      'النور',
      'الفرقان',
      'الشعراء',
      'النمل',
      'القصص',
      'العنكبوت',
      'الروم',
      'لقمان',
      'السجدة',
      'الأحزاب',
      'سبأ',
      'فاطر',
      'يس',
      'الصافات',
      'ص',
      'الزمر',
      'غافر',
      'فصلت',
      'الشورى',
      'الزخرف',
      'الدخان',
      'الجاثية',
      'الأحقاف',
      'محمد',
      'الفتح',
      'الحجرات',
      'ق',
      'الذاريات',
      'الطور',
      'النجم',
      'القمر',
      'الرحمن',
      'الواقعة',
      'الحديد',
      'المجادلة',
      'الحشر',
      'الممتحنة',
      'الصف',
      'الجمعة',
      'المنافقون',
      'التغابن',
      'الطلاق',
      'التحريم',
      'الملك',
      'القلم',
      'الحاقة',
      'المعارج',
      'نوح',
      'الجن',
      'المزمل',
      'المدثر',
      'القيامة',
      'الإنسان',
      'المرسلات',
      'النبأ',
      'النازعات',
      'عبس',
      'التكوير',
      'الإنفطار',
      'المطففين',
      'الإنشقاق',
      'البروج',
      'الطارق',
      'الأعلى',
      'الغاشية',
      'الفجر',
      'البلد',
      'الشمس',
      'الليل',
      'الضحى',
      'الشرح',
      'التين',
      'العلق',
      'القدر',
      'البينة',
      'الزلزلة',
      'العاديات',
      'القارعة',
      'التكاثر',
      'العصر',
      'الهمز',
      'الفيل',
      'قريش',
      'الماعون',
      'الكوثر',
      'الكافرون',
      'النصر',
      'المسد',
      'الإخلاص',
      'الفلق',
      'الناس',
    ];
    return validSurahs.contains(surah);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('خطط الحلقة', style: TextStyle(color: Colors.white)),
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
              Text(
                'خطط حلقة: ${halaga.Name ?? ""}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 24),
              _buildCard(
                title: 'خطة الحفظ',
                icon: Icons.menu_book,
                child: Column(
                  children: [
                    _buildSubtitle('المخطط'),
                    _buildSurahInputRow(
                      label: 'من',
                      surahController: conservationStartSurahController,
                      verseController: conservationStartVerseController,
                      surahHint: 'سورة الفاتحة',
                    ),
                    SizedBox(height: 10),
                    _buildSurahInputRow(
                      label: 'إلى',
                      surahController: conservationEndSurahController,
                      verseController: conservationEndVerseController,
                      surahHint: 'سورة البقرة',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              _buildCard(
                title: 'خطة التلاوة',
                icon: Icons.record_voice_over,
                child: Column(
                  children: [
                    _buildSubtitle('المخطط'),
                    _buildSurahInputRow(
                      label: 'من',
                      surahController: recitationStartSurahController,
                      verseController: recitationStartVerseController,
                      surahHint: 'سورة الفاتحة',
                    ),
                    SizedBox(height: 10),
                    _buildSurahInputRow(
                      label: 'إلى',
                      surahController: recitationEndSurahController,
                      verseController: recitationEndVerseController,
                      surahHint: 'سورة البقرة',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              _buildCard(
                title: 'خطة العلوم الشرعية',
                icon: Icons.local_library,
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
                      'المخطط',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: islamicStudiesContentController,
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
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePlans,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('حفظ الخطط', style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'يمكنك إدخال بيانات التنفيذ في صفحة تفاصيل الحلقة',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
      {required String title, required IconData icon, required Widget child}) {
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
                Icon(icon, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
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

  Widget _buildSubtitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildSurahInputRow({
    required String label,
    required TextEditingController surahController,
    required TextEditingController verseController,
    required String surahHint,
    bool isRequired = true,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: surahController,
            decoration: InputDecoration(
              hintText: surahHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            validator: (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return 'هذا الحقل مطلوب';
              }
              return null;
            },
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: TextFormField(
            controller: verseController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'آية',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            ),
            textAlign: TextAlign.center,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "أدخل قيمة";
              }
              if (int.tryParse(value) == null) {
                return "أدخل رقم صحيح";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
