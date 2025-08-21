import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/conservation_plan_model.dart';
import 'package:al_furqan/models/eltlawah_plan_model.dart';
import 'package:al_furqan/models/islamic_studies_model.dart';

class MonthlyReportPDF {
  final List<StudentModel> students;
  final Map<String?, Map<String, dynamic>> reportData;
  final EltlawahPlanModel? eltlawahPlan;
  final IslamicStudiesModel? islamicStudyPlan;
  final DateTime selectedMonth;

  MonthlyReportPDF({
    required this.students,
    required this.reportData,
    required this.eltlawahPlan,
    required this.islamicStudyPlan,
    required this.selectedMonth,
  });

  Future<pw.Document> generatePDF() async {
    final pdf = pw.Document();
    final arabicFont = await PdfGoogleFonts.cairoRegular();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Container(
                padding: pw.EdgeInsets.all(20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    // عنوان التقرير
                    pw.Center(
                      child: pw.Text(
                        'التقرير الشهري',
                        style: pw.TextStyle(
                          font: arabicFont,
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 10),

                    // معلومات الشهر
                    pw.Text(
                      'تقرير شهر: ${_getMonthName(selectedMonth)}',
                      style: pw.TextStyle(
                        font: arabicFont,
                        fontSize: 18,
                      ),
                    ),
                    pw.SizedBox(height: 20),

                    // جدول الحضور والغياب
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            color: PdfColors.grey300,
                            child: pw.Text(
                              'سجل الحضور والغياب',
                              style: pw.TextStyle(
                                font: arabicFont,
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Table(
                            border: pw.TableBorder.all(),
                            children: [
                              // رأس الجدول
                              pw.TableRow(
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.grey200,
                                ),
                                children: [
                                  _buildTableHeader('اسم الطالب', arabicFont),
                                  _buildTableHeader('نسبة الحضور', arabicFont),
                                ],
                              ),
                              // بيانات الطلاب
                              ...students.map((student) {
                                final data = reportData[student.studentID];
                                return pw.TableRow(
                                  children: [
                                    _buildTableCell(
                                        student.firstName ?? '', arabicFont),
                                    _buildTableCell(
                                        '${data?['attendanceRate'] ?? '0'}%',
                                        arabicFont),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 20),

                    // جدول خطة الحفظ
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            color: PdfColors.grey300,
                            child: pw.Text(
                              'خطة الحفظ',
                              style: pw.TextStyle(
                                font: arabicFont,
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Table(
                            border: pw.TableBorder.all(),
                            children: [
                              // رأس الجدول
                              pw.TableRow(
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.grey200,
                                ),
                                children: [
                                  _buildTableHeader('اسم الطالب', arabicFont),
                                  _buildTableHeader('السورة', arabicFont),
                                  _buildTableHeader('الآية', arabicFont),
                                  _buildTableHeader('نسبة الإنجاز', arabicFont),
                                ],
                              ),
                              // بيانات الطلاب
                              ...students.map((student) {
                                final data = reportData[student.studentID];
                                return pw.TableRow(
                                  children: [
                                    _buildTableCell(
                                        student.firstName ?? '', arabicFont),
                                    _buildTableCell(
                                        data?['executedEndSurah'] ?? '',
                                        arabicFont),
                                    _buildTableCell(
                                        '${data?['executedEndAya'] ?? '0'}',
                                        arabicFont),
                                    _buildTableCell(
                                        '${data?['executedRate'] ?? '0'}%',
                                        arabicFont),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 20),

                    // خطة التلاوة
                    if (eltlawahPlan != null)
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        padding: pw.EdgeInsets.all(10),
                        margin: pw.EdgeInsets.only(bottom: 20),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              padding: pw.EdgeInsets.all(8),
                              color: PdfColors.grey300,
                              child: pw.Text(
                                'خطة التلاوة',
                                style: pw.TextStyle(
                                  font: arabicFont,
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Table(
                              border: pw.TableBorder.all(),
                              children: [
                                pw.TableRow(
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.grey200,
                                  ),
                                  children: [
                                    _buildTableHeader('السورة', arabicFont),
                                    _buildTableHeader('من آية', arabicFont),
                                    _buildTableHeader('إلى آية', arabicFont),
                                    _buildTableHeader(
                                        'نسبة الإنجاز', arabicFont),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    _buildTableCell(
                                        eltlawahPlan?.executedEndSurah ?? '',
                                        arabicFont),
                                    _buildTableCell('1', arabicFont),
                                    _buildTableCell(
                                        '${eltlawahPlan?.executedEndAya ?? '0'}',
                                        arabicFont),
                                    _buildTableCell(
                                        '${eltlawahPlan?.executedRate ?? '0'}%',
                                        arabicFont),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    // خطة العلوم الشرعية
                    if (islamicStudyPlan != null)
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        padding: pw.EdgeInsets.all(10),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              padding: pw.EdgeInsets.all(8),
                              color: PdfColors.grey300,
                              child: pw.Text(
                                'خطة العلوم الشرعية',
                                style: pw.TextStyle(
                                  font: arabicFont,
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Table(
                              border: pw.TableBorder.all(),
                              children: [
                                pw.TableRow(
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.grey200,
                                  ),
                                  children: [
                                    _buildTableHeader('المادة', arabicFont),
                                    _buildTableHeader('الدرس', arabicFont),
                                    _buildTableHeader(
                                        'نسبة الإنجاز', arabicFont),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    _buildTableCell(
                                        islamicStudyPlan?.subject ?? '',
                                        arabicFont),
                                    _buildTableCell(
                                        islamicStudyPlan?.executedContent ?? '',
                                        arabicFont),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  Future<void> generateAndPrintReport() async {
    final pdf = await generatePDF();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildTableHeader(String text, pw.Font font) {
    return pw.Container(
      padding: pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildTableCell(String text, pw.Font font) {
    return pw.Container(
      padding: pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  String _getMonthName(DateTime date) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'إبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class MonthlyReportPDFScreen extends StatelessWidget {
  final List<StudentModel> students;
  final Map<String?, Map<String, dynamic>> reportData;
  final EltlawahPlanModel? eltlawahPlan;
  final IslamicStudiesModel? islamicStudyPlan;
  final DateTime selectedMonth;

  const MonthlyReportPDFScreen({
    Key? key,
    required this.students,
    required this.reportData,
    required this.eltlawahPlan,
    required this.islamicStudyPlan,
    required this.selectedMonth,
  }) : super(key: key);

  Future<void> _savePDF(BuildContext context) async {
    try {
      // إنشاء PDF
      final pdfGenerator = MonthlyReportPDF(
        students: students,
        reportData: reportData,
        eltlawahPlan: eltlawahPlan,
        islamicStudyPlan: islamicStudyPlan,
        selectedMonth: selectedMonth,
      );
      final pdf = await pdfGenerator.generatePDF();

      // الحصول على مسار مجلد التنزيلات
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لم يتم العثور على مجلد الحفظ')),
        );
        return;
      }

      // تكوين اسم الملف باستخدام التاريخ
      final String month = selectedMonth.month.toString().padLeft(2, '0');
      final String year = selectedMonth.year.toString();
      final String fileName = 'تقرير_شهري_${year}_${month}.pdf';
      final String filePath = '${directory.path}/$fileName';

      // حفظ الملف
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // عرض رسالة نجاح مع زر لفتح الملف
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ التقرير في المجلد: ${directory.path}'),
          action: SnackBarAction(
            label: 'فتح',
            onPressed: () async {
              final uri = Uri.file(filePath);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء حفظ الملف: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('معاينة التقرير'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => _savePDF(context),
            tooltip: 'حفظ كملف PDF',
          ),
        ],
      ),
      body: FutureBuilder(
        future: MonthlyReportPDF(
          students: students,
          reportData: reportData,
          eltlawahPlan: eltlawahPlan,
          islamicStudyPlan: islamicStudyPlan,
          selectedMonth: selectedMonth,
        ).generateAndPrintReport(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return Container();
        },
      ),
    );
  }
}
