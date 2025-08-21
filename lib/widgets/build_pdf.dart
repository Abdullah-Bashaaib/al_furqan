import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class BuildPdf {
  final List<Map<String, dynamic>> records;

  BuildPdf({required this.records});

  Future<Uint8List> buildReportPdf() async {
    final doc = pw.Document();

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

    // تجهيز صفوف الجدول حتى 21 صفًا
    final int maxRows = 21;
    final List<Map<String, dynamic>> rows = List.generate(maxRows, (i) {
      if (i < records.length) return records[i];
      return {
        "school_name": "",
        "teacher_name": "",
        "halqa_name": "",
        "student_count": "",
        "attendance_percentage": "",
        "memorization_progress": "",
        "tajweed_progress": "",
        "fiqh_progress": "",
        "activities_count": "",
        "notes": "",
      };
    });

    // حساب الإجماليات
    int totalStudents = 0;
    int totalActivities = 0;
    double avgAttendance = 0;
    int countWithAttendance = 0;

    for (final r in records) {
      final sc = r["student_count"];
      final ac = r["activities_count"];
      final at = r["attendance_percentage"];
      if (sc is num) totalStudents += sc.toInt();
      if (ac is num) totalActivities += ac.toInt();
      if (at is num) {
        avgAttendance += at.toDouble();
        countWithAttendance++;
      }
    }
    if (countWithAttendance > 0) {
      avgAttendance = avgAttendance / countWithAttendance;
    }

    // أنماط النصوص
    final baseStyle = pw.TextStyle(font: regularFont, fontSize: 10);
    final bold = pw.TextStyle(font: boldFont, fontSize: 11);
    final headerStyle = pw.TextStyle(font: boldFont, fontSize: 12);

    pw.Widget cell(String text,
        {pw.TextAlign align = pw.TextAlign.center,
        pw.EdgeInsets padding =
            const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        bool header = false}) {
      return pw.Container(
        padding: padding,
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey600, width: 0.6),
          color: header ? PdfColors.grey300 : null,
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

    // ترويسة الجدول
    final tableHeader = [
      cell('م', header: true),
      cell('اسم الحلقة', header: true),
      cell('اسم المعلم', header: true),
      cell('عدد الطلاب', header: true),
      cell('نسبة الحضور %', header: true),
      cell('الحفظ %', header: true),
      cell('العلوم الشرعية %', header: true),
      cell('التلاوة %', header: true),
      cell('عدد الأنشطة المنفذة', header: true),
    ];

    // صفوف الجدول
    final tableRows = <List<pw.Widget>>[];
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      tableRows.add([
        cell('${i + 1}'),
        cell('${r["halqa_name"] ?? ""}'),
        cell('${r["teacher_name"] ?? ""}'),
        cell('${r["student_count"] ?? ""}'),
        cell('${r["attendance_percentage"] ?? ""}'),
        cell('${r["memorization_progress"] ?? ""}'),
        cell('${r["fiqh_progress"] ?? ""}'),
        cell('${r["tajweed_progress"] ?? ""}'),
        cell('${r["activities_count"] ?? ""}'),
      ]);
    }

    // عرض الأعمدة
    final colWidths = <int, pw.TableColumnWidth>{
      0: const pw.FixedColumnWidth(22), // م
      1: const pw.FlexColumnWidth(2.2), // اسم الحلقة
      2: const pw.FlexColumnWidth(2.2), // اسم المعلم
      3: const pw.FixedColumnWidth(60), // عدد الطلاب
      4: const pw.FixedColumnWidth(70), // الحضور
      5: const pw.FixedColumnWidth(55), // الحفظ
      6: const pw.FixedColumnWidth(70), // العلوم الشرعية
      7: const pw.FixedColumnWidth(55), // التلاوة
      8: const pw.FixedColumnWidth(85), // الأنشطة
    };

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
                // الرأس
                pw.Container(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                        bottom:
                            pw.BorderSide(color: PdfColors.green, width: 1.2)),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      if (logo != null)
                        pw.Container(
                          height: 48,
                          width: 48,
                          margin: const pw.EdgeInsets.only(left: 8),
                          child: pw.Image(logo!, fit: pw.BoxFit.contain),
                        ),
                      pw.Expanded(
                        child: pw.Column(
                          children: [
                            pw.Text('جمعية الفرقان للخدمة القرآنية',
                                style: bold.copyWith(fontSize: 14)),
                            pw.SizedBox(height: 2),
                            pw.Text('Al-Furqan Association for Qur\'an Service',
                                style: baseStyle),
                            pw.SizedBox(height: 4),
                            pw.Text('تقرير الحلقات وسير المناهج',
                                style: bold.copyWith(fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 8),

                // الجدول
                pw.Expanded(
                  child: pw.Table(
                    border: pw.TableBorder.all(
                        color: PdfColors.grey600, width: 0.6),
                    columnWidths: colWidths,
                    children: [
                      pw.TableRow(children: tableHeader),
                      ...tableRows.map((row) => pw.TableRow(children: row)),
                      // صف الإجمالي
                      pw.TableRow(children: [
                        cell(''),
                        cell('الإجمالي', header: true),
                        cell(''),
                        cell('$totalStudents'),
                        cell(countWithAttendance > 0
                            ? avgAttendance.toStringAsFixed(1)
                            : ''),
                        cell(''),
                        cell(''),
                        cell(''),
                        cell('$totalActivities'),
                      ]),
                    ],
                  ),
                ),

                pw.SizedBox(height: 12),

                // التذييل
                pw.Container(
                  padding: const pw.EdgeInsets.only(top: 8),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                        top: pw.BorderSide(color: PdfColors.green, width: 1.2)),
                  ),
                  child: pw.Center(
                    child: pw.Text('خدمة قرآنية متكاملة',
                        style: bold.copyWith(color: PdfColors.green)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }
}
