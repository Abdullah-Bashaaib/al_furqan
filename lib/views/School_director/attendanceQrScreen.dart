import 'dart:math';

import 'package:al_furqan/controllers/School_directore_controller.dart';
import 'package:al_furqan/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceQRScreen extends StatefulWidget {
  const AttendanceQRScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceQRScreen> createState() => _AttendanceQRScreenState();
}

class _AttendanceQRScreenState extends State<AttendanceQRScreen> {
  String attendanceCode = "";
  String lastUpdated = "";
  String schoolId = ""; // إضافة معرف المدرسة
  String schoolName = ""; // إضافة اسم المدرسة
  final TextEditingController _controller = TextEditingController();
  final CollectionReference qrCollection =
      FirebaseFirestore.instance.collection('attendanceCodes');

  @override
  void initState() {
    super.initState();
    _loadSchoolInfo();
  }

  // دالة جديدة لتحميل معلومات المدرسة
  Future<void> _loadSchoolInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('schoolId');
    schoolName = await schoolDirectorController.getSchoolName(id!);

    if (id != null) {
      setState(() {
        schoolId = id.toString();
      });
      _loadAttendanceCode();
    }
  }

  Future<void> _loadAttendanceCode() async {
    try {
      DocumentSnapshot snapshot = await qrCollection.doc(schoolId).get();
      if (snapshot.exists) {
        setState(() {
          attendanceCode = snapshot['code'] ?? 'default_code';
          lastUpdated = snapshot['lastUpdated'] ?? 'غير متوفر';
          _controller.text = attendanceCode;
        });
      } else {
        // إنشاء كود جديد للمدرسة إذا لم يكن موجوداً
        String newCode = _generateRandomCode();
        await qrCollection.doc(schoolId).set({
          'code': newCode,
          'lastUpdated': DateTime.now().toIso8601String(),
          'school_id': schoolId,
        });
        setState(() {
          attendanceCode = newCode;
          lastUpdated = DateTime.now().toIso8601String();
          _controller.text = newCode;
        });
      }
    } catch (e) {
      Utils.showToast('حدث خطأ أثناء تحميل كود الحضور: $e',
          backgroundColor: Colors.red);
    }
  }

  Future<void> _saveAttendanceCode(String code) async {
    try {
      await qrCollection.doc(schoolId).update({
        'code': code,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      setState(() {
        attendanceCode = code;
        lastUpdated = DateTime.now().toIso8601String();
        _controller.text = code;
      });
      Utils.showToast('تم تحديث كود الحضور');
    } catch (e) {
      Utils.showToast('حدث خطأ أثناء حفظ كود الحضور: $e',
          backgroundColor: Colors.red);
    }
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        10,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      DateTime parsedDate = DateTime.parse(isoDate);
      return "${parsedDate.year}/${parsedDate.month}/${parsedDate.day} - ${parsedDate.hour}:${parsedDate.minute}";
    } catch (e) {
      return "تاريخ غير معروف";
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    // تحميل الخط العربي
    final arabicFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/RB_Regular.ttf'),
    );

    // إنشاء QR Code كصورة
    final qrCode = await QrPainter(
      data: "$attendanceCode:$schoolId", // دمج الكود مع معرف المدرسة
      version: QrVersions.auto,
      gapless: false,
    ).toImageData(300);

    final qrImage =
        qrCode != null ? pw.MemoryImage(qrCode.buffer.asUint8List()) : null;

    // تحميل شعار المدرسة (إذا كان متوفراً)
    pw.MemoryImage? logoImage;
    try {
      final ByteData byteData =
          await rootBundle.load('assets/pictures/al_furqan.png');
      final Uint8List logoBytes = byteData.buffer.asUint8List();
      logoImage = pw.MemoryImage(logoBytes);
    } catch (e) {
      // تجاهل الخطأ إذا لم يكن الشعار متوفراً
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.SizedBox(height: 20),
              if (logoImage != null) ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Image(logoImage, width: 300, height: 300),
                  ],
                ),
              ] else
                pw.Text(
                  'جمعية الفرقان',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              pw.SizedBox(height: 10),
              pw.Text(
                'كود تسجيل حضور المعلمين',
                style: pw.TextStyle(
                  font: arabicFont,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 30),
              if (qrImage != null)
                pw.Image(qrImage, width: 200, height: 200)
              else
                pw.Container(
                  width: 200,
                  height: 200,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'QR Code غير متوفر',
                      style: pw.TextStyle(font: arabicFont),
                    ),
                  ),
                ),
              pw.SizedBox(height: 20),
              pw.SizedBox(height: 10),
              pw.Text(
                'آخر تحديث: ${_formatDate(lastUpdated)}',
                style: pw.TextStyle(
                  font: arabicFont,
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                ' مدرسة: $schoolName',
                style: pw.TextStyle(
                  font: arabicFont,
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                'يرجى مسح هذا الكود لتسجيل الحضور',
                style: pw.TextStyle(
                  font: arabicFont,
                  fontSize: 14,
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'QR Code لتحضير المعلمين',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _loadAttendanceCode,
              tooltip: 'تحديث الكود',
            ),
            IconButton(
              icon: Icon(Icons.print),
              onPressed: _generatePdf,
              tooltip: 'طباعة الكود',
            ),
          ],
        ),
        body: attendanceCode.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // const Text(
                      //   ' امسح الكود لتأكيد حضور المعلمين',
                      //   style: TextStyle(
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _generatePdf,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              icon: const Icon(Icons.print),
                              label: const Text(
                                'طباعة كود QR',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.2),
                                blurRadius: 15,
                                spreadRadius: 3,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            border: Border.all(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.1),
                                width: 1.5),
                          ),
                          child: Column(
                            children: [
                              QrImageView(
                                data:
                                    "$attendanceCode:$schoolId", // دمج الكود مع معرف المدرسة
                                version: QrVersions.auto,
                                size: 250.0,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'اسم المدرسة: $schoolName',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'آخر تحديث: ${_formatDate(lastUpdated)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: '🔄 تغيير كود الحضور',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _saveAttendanceCode(_controller.text),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.save,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'حفظ الكود الجديد',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                String newCode = _generateRandomCode();
                                _saveAttendanceCode(newCode);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                              label: const Text(
                                ' انشاء كود عشوائي',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
