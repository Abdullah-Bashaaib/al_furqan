import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:flutter/material.dart';

class HalagaDetailsScreen extends StatefulWidget {
  final HalagaModel halaga;

  const HalagaDetailsScreen({Key? key, required this.halaga}) : super(key: key);

  @override
  _HalagaDetailsScreenState createState() => _HalagaDetailsScreenState();
}

class _HalagaDetailsScreenState extends State<HalagaDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late HalagaModel _halaga;
  bool _isLoading = false;
  String? _errorMessage;

  // controllers لمنفذ الحفظ
  final TextEditingController executedStartSurahController =
      TextEditingController();
  final TextEditingController executedEndSurahController =
      TextEditingController();
  final TextEditingController executedStartVerseController =
      TextEditingController();
  final TextEditingController executedEndVerseController =
      TextEditingController();

  // controllers لمنفذ التلاوة
  final TextEditingController executedTlawahStartSurahController =
      TextEditingController();
  final TextEditingController executedTlawahEndSurahController =
      TextEditingController();
  final TextEditingController executedTlawahStartVerseController =
      TextEditingController();
  final TextEditingController executedTlawahEndVerseController =
      TextEditingController();

  // controllers للعلوم الشرعية المنفذة
  final TextEditingController executedIslamicContentController =
      TextEditingController();
  final TextEditingController islamicExecutionReasonController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _halaga = widget.halaga;
    _loadExistingData();
  }

  void _loadExistingData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // إعادة تحميل بيانات الحلقة للحصول على أحدث البيانات
      final updatedHalaga =
          await halagaController.getHalqaDetails(_halaga.halagaID!);
      if (updatedHalaga != null) {
        _halaga = updatedHalaga;
      }

      // منفذ الحفظ
      if (_halaga.executedStartSurah != null) {
        executedStartSurahController.text = _halaga.executedStartSurah!;
      }

      if (_halaga.executedEndSurah != null) {
        executedEndSurahController.text = _halaga.executedEndSurah!;
      }

      if (_halaga.executedStartVerse != null) {
        executedStartVerseController.text =
            _halaga.executedStartVerse.toString();
      }

      if (_halaga.executedEndVerse != null) {
        executedEndVerseController.text = _halaga.executedEndVerse.toString();
      }

      // منفذ التلاوة
      if (_halaga.executedStartSurah != null) {
        executedTlawahStartSurahController.text = _halaga.executedStartSurah!;
      }

      if (_halaga.executedEndSurah != null) {
        executedTlawahEndSurahController.text = _halaga.executedEndSurah!;
      }

      if (_halaga.executedStartVerse != null) {
        executedTlawahStartVerseController.text =
            _halaga.executedStartVerse.toString();
      }

      if (_halaga.executedEndVerse != null) {
        executedTlawahEndVerseController.text =
            _halaga.executedEndVerse.toString();
      }

      // العلوم الشرعية المنفذة
      if (_halaga.executedIslamicContent != null) {
        executedIslamicContentController.text = _halaga.executedIslamicContent!;
      }

      if (_halaga.islamicExecutionReason != null) {
        islamicExecutionReasonController.text = _halaga.islamicExecutionReason!;
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تحميل البيانات: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveExecutionData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // تحديث بيانات التنفيذ
      _halaga.executedStartSurah = executedStartSurahController.text.isEmpty
          ? null
          : executedStartSurahController.text;
      _halaga.executedEndSurah = executedEndSurahController.text.isEmpty
          ? null
          : executedEndSurahController.text;
      _halaga.executedStartVerse = executedStartVerseController.text.isEmpty
          ? null
          : int.tryParse(executedStartVerseController.text);
      _halaga.executedEndVerse = executedEndVerseController.text.isEmpty
          ? null
          : int.tryParse(executedEndVerseController.text);

      // منفذ التلاوة
      _halaga.executedStartSurah =
          executedTlawahStartSurahController.text.isEmpty
              ? null
              : executedTlawahStartSurahController.text;
      _halaga.executedEndSurah = executedTlawahEndSurahController.text.isEmpty
          ? null
          : executedTlawahEndSurahController.text;
      _halaga.executedStartVerse =
          executedTlawahStartVerseController.text.isEmpty
              ? null
              : int.tryParse(executedTlawahStartVerseController.text);
      _halaga.executedEndVerse = executedTlawahEndVerseController.text.isEmpty
          ? null
          : int.tryParse(executedTlawahEndVerseController.text);

      // العلوم الشرعية
      _halaga.executedIslamicContent =
          executedIslamicContentController.text.isEmpty
              ? null
              : executedIslamicContentController.text;
      _halaga.islamicExecutionReason =
          islamicExecutionReasonController.text.isEmpty
              ? null
              : islamicExecutionReasonController.text;

      // حفظ البيانات
      await halagaController.updateHalagaPlans(_halaga);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ بيانات التنفيذ بنجاح')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء حفظ البيانات: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الحلقة', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان الحلقة
                    Text(
                      'تفاصيل حلقة: ${_halaga.Name ?? ""}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'المعلم: ${_halaga.TeacherName ?? "غير معين"}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 24),

                    // معلومات خطة الحفظ
                    _buildInfoCard(
                      title: 'خطة الحفظ',
                      icon: Icons.menu_book,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSubtitle('المخطط'),
                          _buildPlanInfoRow(
                            'من: ${_halaga.conservationStartSurah ?? "غير محدد"}${_halaga.conservationStartVerse != null ? " - آية ${_halaga.conservationStartVerse}" : ""}',
                            'إلى: ${_halaga.conservationEndSurah ?? "غير محدد"}${_halaga.conservationEndVerse != null ? " - آية ${_halaga.conservationEndVerse}" : ""}',
                          ),
                          Divider(height: 24),
                          _buildSubtitle('منفذ الحفظ'),
                          _buildSurahInputRow(
                            label: 'من',
                            surahController: executedStartSurahController,
                            verseController: executedStartVerseController,
                            surahHint: 'سورة البداية',
                            isRequired: false,
                          ),
                          SizedBox(height: 10),
                          _buildSurahInputRow(
                            label: 'إلى',
                            surahController: executedEndSurahController,
                            verseController: executedEndVerseController,
                            surahHint: 'سورة النهاية',
                            isRequired: false,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // معلومات خطة التلاوة
                    _buildInfoCard(
                      title: 'خطة التلاوة',
                      icon: Icons.record_voice_over,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSubtitle('المخطط'),
                          _buildPlanInfoRow(
                            'من: ${_halaga.recitationStartSurah ?? "غير محدد"}${_halaga.recitationStartVerse != null ? " - آية ${_halaga.recitationStartVerse}" : ""}',
                            'إلى: ${_halaga.recitationEndSurah ?? "غير محدد"}${_halaga.recitationEndVerse != null ? " - آية ${_halaga.recitationEndVerse}" : ""}',
                          ),
                          Divider(height: 24),
                          _buildSubtitle('منفذ التلاوة'),
                          _buildSurahInputRow(
                            label: 'من',
                            surahController: executedTlawahStartSurahController,
                            verseController: executedTlawahStartVerseController,
                            surahHint: 'سورة البداية',
                            isRequired: false,
                          ),
                          SizedBox(height: 10),
                          _buildSurahInputRow(
                            label: 'إلى',
                            surahController: executedTlawahEndSurahController,
                            verseController: executedTlawahEndVerseController,
                            surahHint: 'سورة النهاية',
                            isRequired: false,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // العلوم الشرعية
                    _buildInfoCard(
                      title: 'العلوم الشرعية',
                      icon: Icons.local_library,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSubtitle('المقرر'),
                          Text(
                            _halaga.islamicStudiesSubject ?? 'غير محدد',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 16),
                          _buildSubtitle('المحتوى المخطط'),
                          Text(
                            _halaga.islamicStudiesContent ?? 'غير محدد',
                            style: TextStyle(fontSize: 16),
                          ),
                          Divider(height: 24),
                          _buildSubtitle('المحتوى المنفذ'),
                          TextFormField(
                            controller: executedIslamicContentController,
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

                    SizedBox(height: 24),

                    // أسباب التأخير المنهاج
                    _buildInfoCard(
                      title: 'أسباب التأخر في المنهاج',
                      icon: Icons.event_busy,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: islamicExecutionReasonController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText:
                                  'أدخل أسباب التأخر في تنفيذ المنهاج إن وجدت',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // عرض رسالة الخطأ إذا وجدت
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),

                    SizedBox(height: 24),

                    // زر الحفظ
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveExecutionData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('حفظ بيانات التنفيذ',
                                style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard(
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
      padding: const EdgeInsets.only(bottom: 8.0),
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

  Widget _buildPlanInfoRow(String from, String to) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(from, style: TextStyle(fontSize: 15)),
        SizedBox(height: 4),
        Text(to, style: TextStyle(fontSize: 15)),
      ],
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
          ),
        ),
      ],
    );
  }
}
