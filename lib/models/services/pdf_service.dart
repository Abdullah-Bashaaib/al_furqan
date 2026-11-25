// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:al_furqan/models/halaga_model.dart';
// import 'package:intl/intl.dart';
//
// class PdfService {
//   // Generate a PDF report for a halqa
//   Future<Uint8List> generateHalqaReport(HalagaModel halqa) async {
//     final pdf = pw.Document();
//     final arabicFont = await _loadArabicFont();
//
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(32),
//         build: (pw.Context context) {
//           return [
//             _buildHeader(halqa, arabicFont),
//             pw.SizedBox(height: 20),
//             _buildHalqaInfo(halqa, arabicFont),
//             pw.SizedBox(height: 30),
//             _buildConservationSection(halqa, arabicFont),
//             pw.SizedBox(height: 30),
//             _buildRecitationSection(halqa, arabicFont),
//             pw.SizedBox(height: 30),
//             _buildIslamicStudiesSection(halqa, arabicFont),
//             pw.SizedBox(height: 30),
//             _buildProgressSection(halqa, arabicFont),
//           ];
//         },
//       ),
//     );
//
//     return pdf.save();
//   }
//
//   // Load Arabic font for the PDF
//   Future<pw.Font> _loadArabicFont() async {
//     try {
//       final fontData = await rootBundle.load("assets/fonts/HacenTunisia.ttf");
//       return pw.Font.ttf(fontData);
//     } catch (e) {
//       print('Error loading Arabic font: $e');
//       // Fall back to a default font that comes with the pdf package
//       return pw.Font.helvetica();
//     }
//   }
//
//   // Build header section
//   pw.Widget _buildHeader(HalagaModel halqa, pw.Font arabicFont) {
//     final now = DateTime.now();
//     final formattedDate = DateFormat('yyyy-MM-dd').format(now);
//
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.center,
//       children: [
//         pw.Text(
//           'تقرير حلقة ${halqa.Name}',
//           style: pw.TextStyle(
//             font: arabicFont,
//             fontSize: 24,
//             fontWeight: pw.FontWeight.bold,
//           ),
//           textDirection: pw.TextDirection.rtl,
//         ),
//         pw.SizedBox(height: 10),
//         pw.Text(
//           'تاريخ التقرير: $formattedDate',
//           style: pw.TextStyle(
//             font: arabicFont,
//             fontSize: 16,
//           ),
//           textDirection: pw.TextDirection.rtl,
//         ),
//       ],
//     );
//   }
//
//   // Build halqa info section
//   pw.Widget _buildHalqaInfo(HalagaModel halqa, pw.Font arabicFont) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(15),
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(width: 1, color: PdfColors.grey400),
//         borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
//       ),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.end,
//         children: [
//           pw.Text(
//             'معلومات الحلقة',
//             style: pw.TextStyle(
//               font: arabicFont,
//               fontSize: 18,
//               fontWeight: pw.FontWeight.bold,
//             ),
//             textDirection: pw.TextDirection.rtl,
//           ),
//           pw.Divider(),
//           _buildInfoRow('اسم الحلقة:', halqa.Name ?? 'غير متوفر', arabicFont),
//           _buildInfoRow(
//               'المعلم:', halqa.TeacherName ?? 'غير متوفر', arabicFont),
//           _buildInfoRow(
//               'عدد الطلاب:', '${halqa.NumberStudent ?? 0}', arabicFont),
//         ],
//       ),
//     );
//   }
//
//   // Build conservation (memorization) section
//   pw.Widget _buildConservationSection(HalagaModel halqa, pw.Font arabicFont) {
//     final plannedStart =
//         '${halqa.conservationStartSurah ?? "غير محدد"}${halqa.conservationStartVerse != null ? " - آية ${halqa.conservationStartVerse}" : ""}';
//     final plannedEnd =
//         '${halqa.conservationEndSurah ?? "غير محدد"}${halqa.conservationEndVerse != null ? " - آية ${halqa.conservationEndVerse}" : ""}';
//
//     final executedStart =
//         '${halqa.executedStartSurah ?? "غير محدد"}${halqa.executedStartVerse != null ? " - آية ${halqa.executedStartVerse}" : ""}';
//     final executedEnd =
//         '${halqa.executedEndSurah ?? "غير محدد"}${halqa.executedEndVerse != null ? " - آية ${halqa.executedEndVerse}" : ""}';
//
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(15),
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(width: 1, color: PdfColors.green800),
//         borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
//       ),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.end,
//         children: [
//           pw.Text(
//             'خطة الحفظ',
//             style: pw.TextStyle(
//               font: arabicFont,
//               fontSize: 18,
//               fontWeight: pw.FontWeight.bold,
//               color: PdfColors.green800,
//             ),
//             textDirection: pw.TextDirection.rtl,
//           ),
//           pw.Divider(color: PdfColors.green800),
//           pw.SizedBox(height: 5),
//           pw.Text(
//             'المخطط:',
//             style: pw.TextStyle(
//               font: arabicFont,
//               fontSize: 16,
//               fontWeight: pw.FontWeight.bold,
//             ),
//             textDirection: pw.TextDirection.rtl,
//           ),
//           pw.SizedBox(height: 5),
//           _buildInfoRow('من:', plannedStart, arabicFont),
//           _buildInfoRow('إلى:', plannedEnd, arabicFont),
//           pw.SizedBox(height: 10),
//           pw.Text(
//             'المنفذ:',
//             style: pw.TextStyle(
//               font: arabicFont,
//               fontSize: 16,
//               fontWeight: pw.FontWeight.bold,
//             ),
//             textDirection: pw.TextDirection.rtl,
//           ),
//           pw.SizedBox(height: 5),
//           _buildInfoRow('من:', executedStart, arabicFont),
//           _buildInfoRow('إلى:', executedEnd, arabicFont),
//         ],
//       ),
//     );
//   }
//
//   // Build recitation section
//   pw.Widget _buildRecitationSection(HalagaModel halqa, pw.Font arabicFont) {
//     final plannedStart =
//         '${halqa.recitationStartSurah ?? "غير محدد"}${halqa.recitationStartVerse != null ? " - آية ${halqa.recitationStartVerse}" : ""}';
//     final plannedEnd =
//         '${halqa.recitationEndSurah ?? "غير محدد"}${halqa.recitationEndVerse != null ? " - آية ${halqa.recitationEndVerse}" : ""}';
//
//     final executedStart =
//         '${halqa.executedStartSurah ?? "غير محدد"}${halqa.executedStartVerse != null ? " - آية ${halqa.executedStartVerse}" : ""}';
//     final executedEnd =
//         '${halqa.executedEndSurah ?? "غير محدد"}${halqa.executedEndVerse != null ? " - آية ${halqa.executedEndVerse}" : ""}';
//
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(15),
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(width: 1, color: PdfColors.blue800),
//         borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
//       ),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.end,
//         children: [
//           pw.Text(
//             'خطة التلاوة',
//             style: pw.TextStyle(
//               font: arabicFont,
//               fontSize: 18,
//               fontWeight: pw.FontWeight.bold,
//               color: PdfColors.blue800,
//             ),
//             textDirection: pw.TextDirection.rtl,
//           ),
//           pw.Divider(color: PdfColors.blue800),
//           pw.SizedBox(height: 5),
//           pw.Text(
//             'المخطط:',
//             style: pw.TextStyle(
//               font: arabicFont,
//               fontSize: 16,
//               fontWeight: pw.FontWeight.bold,
//             ),
//             textDirection: pw.TextDirection.rtl,
//           ),
//           pw.SizedBox(height: 5),
//           _buildInfoRow('من:', plannedStart, arabicFont),
//           _buildInfoRow('إلى:', plannedEnd, arabicFont),
//           pw.SizedBox(height: 10),
//           pw.Text(
//             'المنفذ:',
//             style: pw.TextStyle(
//               font: arabicFont,
//               fontSize: 16,
//               fontWeight: pw.FontWeight.bold,
//             ),
//             textDirection: pw.TextDirection.rtl,
//           ),
//           pw.SizedBox(height: 5),
//           _buildInfoRow('من:', executedStart, arabicFont),
//           _buildInfoRow('إلى:', executedEnd, arabicFont),
//         ],
//       ),
//     );
//   }
//
//   // Build Islamic studies section
//   pw.Widget _buildIslamicStudiesSection(HalagaModel halqa, pw.Font arabicFont) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(15),
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(width: 1, color: PdfColors.brown800),
//         borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
//       ),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.end,
//         children: [
//           pw.Text(
//             'العلوم الشرعية',
//             style: pw.TextStyle(
//               font: arabicFont,
//               fontSize: 18,
//               fontWeight: pw.FontWeight.bold,
//               color: PdfColors.brown800,
//             ),
//             textDirection: pw.TextDirection.rtl,
//           ),
//           pw.Divider(color: PdfColors.brown800),
//           pw.SizedBox(height: 5),
//           _buildInfoRow(
//               'المقرر:', halqa.islamicStudiesSubject ?? 'غير محدد', arabicFont),
//           pw.SizedBox(height: 10),
//           pw.Text(
//             'المحتوى المخطط:',
//             style: pw.TextStyle(
//               font: arabicFont,
//               fontSize: 16,
//               fontWeight: pw.FontWeight.bold,
//             ),
//             textDirection: pw.TextDirection.rtl,
//           ),
//           pw.SizedBox(height: 5),
//           pw.Text(
//             halqa.islamicStudiesContent ?? 'غير محدد',
//             style: pw.TextStyle(
//               font: arabicFont,
//               fontSize: 14,
//             ),
//             textDirection: pw.TextDirection.rtl,
//           ),
//           pw.SizedBox(height: 10),
//           pw.Text(
//             'المحتوى المنفذ:',
//             style: pw.TextStyle(
//               font: arabicFont,
//               fontSize: 16,
//               fontWeight: pw.FontWeight.bold,
//             ),
//             textDirection: pw.TextDirection.rtl,
//           ),
//           pw.SizedBox(height: 5),
//           pw.Text(
//             halqa.executedIslamicContent ?? 'لم يتم التنفيذ بعد',
//             style: pw.TextStyle(
//               font: arabicFont,
//               fontSize: 14,
//             ),
//             textDirection: pw.TextDirection.rtl,
//           ),
//           if (halqa.islamicExecutionReason != null &&
//               halqa.islamicExecutionReason!.isNotEmpty) ...[
//             pw.SizedBox(height: 10),
//             pw.Text(
//               'أسباب التأخر:',
//               style: pw.TextStyle(
//                 font: arabicFont,
//                 fontSize: 16,
//                 fontWeight: pw.FontWeight.bold,
//               ),
//               textDirection: pw.TextDirection.rtl,
//             ),
//             pw.SizedBox(height: 5),
//             pw.Text(
//               halqa.islamicExecutionReason!,
//               style: pw.TextStyle(
//                 font: arabicFont,
//                 fontSize: 14,
//                 color: PdfColors.red800,
//               ),
//               textDirection: pw.TextDirection.rtl,
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   // Build progress section
//   pw.Widget _buildProgressSection(HalagaModel halqa, pw.Font arabicFont) {
//     // Calculate some example completion percentages (you would use real data)
//     double conservationPercentage = _calculateCompletionPercentage(
//       halqa.conservationStartSurah,
//       halqa.conservationEndSurah,
//       halqa.executedStartSurah,
//       halqa.executedEndSurah,
//     );
//
//     double recitationPercentage = _calculateCompletionPercentage(
//       halqa.recitationStartSurah,
//       halqa.recitationEndSurah,
//       halqa.executedStartSurah,
//       halqa.executedEndSurah,
//     );
//
//     double islamicStudiesPercentage = halqa.executedIslamicContent != null &&
//             halqa.executedIslamicContent!.isNotEmpty
//         ? 75.0
//         : 0.0; // Example value
//
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(15),
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(width: 1, color: PdfColors.grey400),
//         borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
//       ),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.end,
//         children: [
//           pw.Text(
//             'نسب الإنجاز',
//             style: pw.TextStyle(
//               font: arabicFont,
//               fontSize: 18,
//               fontWeight: pw.FontWeight.bold,
//             ),
//             textDirection: pw.TextDirection.rtl,
//           ),
//           pw.Divider(),
//           pw.SizedBox(height: 10),
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
//             children: [
//               _buildProgressIndicator('الحفظ', conservationPercentage,
//                   PdfColors.green800, arabicFont),
//               _buildProgressIndicator('التلاوة', recitationPercentage,
//                   PdfColors.blue800, arabicFont),
//               _buildProgressIndicator('العلوم الشرعية',
//                   islamicStudiesPercentage, PdfColors.brown800, arabicFont),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Helper to build info rows
//   pw.Widget _buildInfoRow(String label, String value, pw.Font arabicFont) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 3),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.end,
//         children: [
//           pw.Text(
//             value,
//             style: pw.TextStyle(font: arabicFont, fontSize: 14),
//             textDirection: pw.TextDirection.rtl,
//           ),
//           pw.SizedBox(width: 5),
//           pw.Text(
//             label,
//             style: pw.TextStyle(
//               font: arabicFont,
//               fontSize: 14,
//               fontWeight: pw.FontWeight.bold,
//             ),
//             textDirection: pw.TextDirection.rtl,
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Helper to build progress indicators
//   pw.Widget _buildProgressIndicator(
//       String label, double percentage, PdfColor color, pw.Font arabicFont) {
//     return pw.Column(
//       children: [
//         pw.Container(
//           width: 100,
//           height: 100,
//           child: pw.Stack(
//             alignment: pw.Alignment.center,
//             children: [
//               pw.Container(
//                 width: 100,
//                 height: 100,
//                 child: pw.Center(
//                   child: pw.Text(
//                     '${percentage.toStringAsFixed(0)}%',
//                     style: pw.TextStyle(
//                       font: arabicFont,
//                       fontSize: 16,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               pw.CircularProgressIndicator(
//                 value: percentage / 100,
//                 backgroundColor: PdfColors.grey300,
//                 color: color,
//                 strokeWidth: 10,
//               ),
//             ],
//           ),
//         ),
//         pw.SizedBox(height: 10),
//         pw.Text(
//           label,
//           style: pw.TextStyle(
//             font: arabicFont,
//             fontSize: 14,
//             fontWeight: pw.FontWeight.bold,
//           ),
//           textDirection: pw.TextDirection.rtl,
//         ),
//       ],
//     );
//   }
//
//   // Calculate completion percentage based on Surah progress
//   double _calculateCompletionPercentage(
//     String? plannedStartSurah,
//     String? plannedEndSurah,
//     String? executedStartSurah,
//     String? executedEndSurah,
//   ) {
//     // Simple placeholder calculation (in a real app, you'd have more complex logic)
//     if (executedStartSurah == null || executedEndSurah == null) {
//       return 0.0;
//     }
//     if (executedStartSurah == plannedStartSurah &&
//         executedEndSurah == plannedEndSurah) {
//       return 100.0;
//     }
//     if (executedStartSurah == plannedStartSurah) {
//       return 50.0; // Started but not completed
//     }
//     return 25.0; // Default fallback
//   }
//
//   // Save and open the PDF file
//   Future<void> savePdfFile(Uint8List pdfBytes, String fileName) async {
//     try {
//       final output = await getTemporaryDirectory();
//       final file = File('${output.path}/$fileName');
//       await file.writeAsBytes(pdfBytes);
//
//       // Return the file path to allow external access
//       return;
//     } catch (e) {
//       print('Error saving PDF: $e');
//       throw Exception('Error saving PDF: $e');
//     }
//   }
//
//   // Print the PDF to debugPrinter or show in preview
//   Future<void> printPdf(Uint8List pdfBytes, String documentName) async {
//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => pdfBytes,
//       name: documentName,
//     );
//   }
// }
//
// // Create a singleton instance for easy access
// final pdfService = PdfService();
