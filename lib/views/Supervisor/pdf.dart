import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PdfGenerator {
  Future<void> generateReport(BuildContext context) async {
    final pdf = pw.Document();
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/pictures/al_furqan.png'))
          .buffer
          .asUint8List(),
    );

    final dbPath = await getDatabasesPath();
    final db = await openDatabase(join(dbPath, 'your_database.db'));
    final List<Map<String, dynamic>> halqatReportSample = [
      {
        "school_name": "مدرسة الفرقان لتحفيظ القرآن الكريم",
        "teacher_name": "الشيخ أحمد العتيبي",
        "halqa_name": "حلقة النور",
        "student_count": 12,
        "attendance_percentage": 92,
        "memorization_progress": 80,
        "notes": "الطلاب ملتزمون، ويوجد تحسن ملحوظ في الأداء."
      },
    ];
    final List<Map<String, dynamic>> data = halqatReportSample;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          children: [
            pw.Center(
              child: pw.Image(logoImage, height: 80),
            ),
            pw.SizedBox(height: 10),
            pw.Text("تقرير الحلقات وسير المنهاج",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: [
                "م",
                "اسم الحلقة",
                "اسم المعلم",
                "عدد الطلاب",
                "نسبة الحضور",
                "نسبة إتقان الحفظ",
                "العلوم الشرعية",
                "عدد الأنشطة المنفذة"
              ],
              data: List<List<String>>.generate(
                data.length,
                (index) => [
                  '${index + 1}',
                  data[index]['halqa_name'] ?? '',
                  data[index]['teacher_name'] ?? '',
                  '${data[index]['students_count'] ?? ''}',
                  '${data[index]['attendance_percent'] ?? ''}%',
                  '${data[index]['hifz_percent'] ?? ''}%',
                  '${data[index]['sharia'] ?? ''}',
                  '${data[index]['activities'] ?? ''}',
                ],
              ),
              cellStyle: pw.TextStyle(fontSize: 10),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.center,
              border: pw.TableBorder.all(),
            ),
            pw.SizedBox(height: 10),
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text("الإجمالي",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/halqat_report.pdf");
    await file.writeAsBytes(await pdf.save());

    // طباعة أو مشاركة
    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'halqat_report.pdf');
  }
}
