import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:al_furqan/models/report_model.dart';

class BuildPdf {
  final List<ReportModel> records;

  BuildPdf({required this.records});

  Future<Uint8List> buildReportPdf() async {
    final doc = pw.Document();
    int studentCount = 0;
    double totalRate = 0.0;
    double totalRateC = 0.0;
    double totalRateE = 0.0;
    double totalRateI = 0.0;
    for (var r in records) {
      totalRate += r.attendanceRate;
    }

    for (var r in records) {
      totalRateC += r.conservationRate;
    }

    for (var r in records) {
      totalRateE += r.eltlawahRate;
    }

    for (var r in records) {
      totalRateI += r.islamicRate;
    }

    for (var r in records) {
      studentCount += r.numberStudent;
    }

    // تحميل الخط العربي
    final regularFont =
        pw.Font.ttf(await rootBundle.load('assets/fonts/RB_Regular.ttf'));
    final boldFont =
        pw.Font.ttf(await rootBundle.load('assets/fonts/RB_Regular.ttf'));

    // تحميل الشعار
    pw.MemoryImage? logo;
    try {
      final logoBytes = await rootBundle.load('assets/logo.png');
      logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {}

    // أنماط النصوص
    final baseStyle = pw.TextStyle(font: regularFont, fontSize: 10);
    final bold = pw.TextStyle(font: boldFont, fontSize: 11);
    final headerStyle = pw.TextStyle(font: boldFont, fontSize: 12);
    final titleStyle = pw.TextStyle(font: boldFont, fontSize: 14);
    final greenText =
        pw.TextStyle(font: boldFont, fontSize: 11, color: PdfColors.green800);

    // ألوان التقرير
    final headerGreen = PdfColors.green100;
    final borderColor = PdfColors.grey600;
    final stripeColor = PdfColors.green100;

    pw.Widget cell(String text,
        {pw.TextAlign align = pw.TextAlign.center,
        pw.EdgeInsets padding =
            const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        bool header = false}) {
      return pw.Container(
        padding: padding,
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: borderColor, width: 0.5),
          color: header ? headerGreen : null,
        ),
        child: pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Text(text,
              textAlign: align,
              maxLines: 2,
              style: header ? headerStyle : baseStyle),
        ),
      );
    }

    // ترويسة الجدول - الترتيب من اليمين إلى اليسار
    final tableHeader = [
      cell('عدد الأنشطة المنفذة', header: true),
      cell('التلاوة %', header: true),
      cell('العلوم الشرعية %', header: true),
      cell('الحفظ %', header: true),
      cell('نسبة الحضور %', header: true),
      cell('عدد الطلاب', header: true),
      cell('اسم المعلم', header: true),
      cell('اسم الحلقة', header: true),
      cell('م', header: true),
    ];

    // عرض الأعمدة - الترتيب من اليمين إلى اليسار
    final colWidths = <int, pw.TableColumnWidth>{
      0: const pw.FixedColumnWidth(85), // الأنشطة
      1: const pw.FixedColumnWidth(55), // التلاوة
      2: const pw.FixedColumnWidth(70), // العلوم الشرعية
      3: const pw.FixedColumnWidth(55), // الحفظ
      4: const pw.FixedColumnWidth(70), // الحضور
      5: const pw.FixedColumnWidth(60), // عدد الطلاب
      6: const pw.FlexColumnWidth(2.2), // اسم المعلم
      7: const pw.FlexColumnWidth(2.2), // اسم الحلقة
      8: const pw.FixedColumnWidth(22), // م
    };

    // صفوف الجدول - 21 صف فارغ كما هو في الصورة
    final tableRows = <List<pw.Widget>>[];
    for (var i = 0; i < 21; i++) {
      if (i < records.length) {
        final r = records[i];
        tableRows.add([
          cell(''), // الأنشطة
          cell(r.eltlawahRate.toStringAsFixed(1)), // التلاوة
          cell(r.islamicRate.toStringAsFixed(1)), // العلوم الشرعية
          cell(r.conservationRate.toStringAsFixed(1)), // الحفظ
          cell(r.attendanceRate.toStringAsFixed(1)), // الحضور
          cell(r.numberStudent.toString()), // عدد الطلاب
          cell(r.teacherName), // اسم المعلم
          cell(r.halagaName), // اسم الحلقة
          cell('${i + 1}'), // م
        ]);
      } else {
        tableRows.add(List.generate(9, (_) => cell('')));
      }
    }

    // إضافة أشرطة خضراء للتزيين
    pw.Widget greenStripe(double height) {
      return pw.Container(
        height: height,
        color: stripeColor,
      );
    }

    // صفحة التقرير
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(16, 18, 16, 24),
        build: (context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // أشرطة خضراء علوية
                greenStripe(6),
                pw.SizedBox(height: 3),
                greenStripe(6),
                pw.SizedBox(height: 3),
                greenStripe(6),

                pw.SizedBox(height: 20),

                // الترويسة مع الشعار
                pw.Row(
                  children: [
                    pw.Container(
                      width: 50,
                      height: 50,
                      child: logo != null ? pw.Image(logo) : pw.Container(),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text('جمعية الفرقان للخدمة القرآنية',
                              style: titleStyle),
                          pw.SizedBox(height: 2),
                          pw.Text('Al-Furqan Association for Qur\'an Service',
                              style: baseStyle.copyWith(fontSize: 8)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.only(left: 10),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            // ترك هذا المكان فارغًا للعنوان الجانبي كما في الصورة
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),

                // عنوان التقرير
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.symmetric(vertical: 8),
                  child: pw.Text('تقرير الحلقات وسير المناهج',
                      style: bold.copyWith(fontSize: 16)),
                ),

                pw.SizedBox(height: 10),

                // جدول التقرير
                pw.Table(
                  border: pw.TableBorder.all(color: borderColor, width: 0.5),
                  columnWidths: colWidths,
                  children: [
                    pw.TableRow(children: tableHeader),
                    ...tableRows.map((row) => pw.TableRow(children: row)),
                    // صف الإجمالي
                    pw.TableRow(children: [
                      cell(''),
                      cell('${totalRateE / records.length}'),
                      cell('${totalRateI / records.length}'),
                      cell('${totalRateC / records.length}'),
                      cell('${totalRate / records.length}'),
                      cell('$studentCount'),
                      cell(''),
                      cell('الإجمالي', header: true),
                      cell(''),
                    ]),
                  ],
                ),

                pw.SizedBox(height: 20),

                // التذييل
                pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Text('خدمة قرآنية متكاملة', style: greenText),
                ),

                pw.SizedBox(height: 8),

                // أشرطة خضراء سفلية
                greenStripe(6),
                pw.SizedBox(height: 3),
                greenStripe(6),
                pw.SizedBox(height: 3),
                greenStripe(6),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }
}
