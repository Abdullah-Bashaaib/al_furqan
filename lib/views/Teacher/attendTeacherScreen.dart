import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceScannerPage extends StatefulWidget {
  const AttendanceScannerPage({super.key});

  @override
  State<AttendanceScannerPage> createState() => _AttendanceScannerPageState();
}

class _AttendanceScannerPageState extends State<AttendanceScannerPage> {
  bool _scanned = false;
  bool _attendanceDone = false;
  String _teacherName = '';
  String? _currentAttendanceCode; // ✅ الكود اللي بيجي من Firebase
  final MobileScannerController _controller = MobileScannerController();

  // وقت التحضير المسموح (تقدر تغيره براحتك)
  final int allowedStartHour = 18; //
  final int allowedEndHour = 18; //
  final int lateMinuteThreshold =
      30; // يعتبر متأخر بعد 30 دقيقة من بداية الدوام

  @override
  void initState() {
    super.initState();
    _fetchCurrentAttendanceCode();
    _trySubmitPendingAttendance(); //  نحاول نرفع أي تحضير سابق محفوظ
    _checkIfAlreadyMarked();
  }

  Future<void> _trySubmitPendingAttendance() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? pendingTeacherName = prefs.getString('pending_attendance');
      String? pendingDate = prefs.getString('pending_attendance_date');
      String? pendingStatus = prefs.getString('pending_attendance_status');
      int? teacherId = prefs.getInt('pending_teacher_id');
      int? schoolId = prefs.getInt('pending_school_id');

      if (pendingTeacherName != null && pendingDate != null) {
        // تحقق مما إذا كان التاريخ المعلق هو نفس تاريخ اليوم
        String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

        // محاولة رفع التحضير المعلق مباشرة إلى Firebase
        if (pendingDate == today) {
          try {
            await FirebaseFirestore.instance
                .collection('attendance')
                .doc(pendingDate)
                .collection('teachers')
                .doc(teacherId?.toString() ?? pendingTeacherName)
                .set({
              'teacherId': teacherId,
              'schoolId': schoolId,
              'name': pendingTeacherName,
              'status': pendingStatus ?? "حاضر",
              'timestamp': FieldValue.serverTimestamp(),
            });

            // تم الرفع بنجاح، نحذف البيانات المعلقة
            await prefs.remove('pending_attendance');
            await prefs.remove('pending_attendance_date');
            await prefs.remove('pending_attendance_status');
            await prefs.remove('pending_teacher_id');
            await prefs.remove('pending_school_id');

            // تحديث حالة التحضير
            prefs.setString('last_attendance_date', today);
          } catch (e) {
            debugPrint("❌ فشل في رفع التحضير المعلق مباشرة: $e");
          }
        } else {
          // إذا كان التاريخ قديمًا، نحذف البيانات المعلقة
          await prefs.remove('pending_attendance');
          await prefs.remove('pending_attendance_date');
          await prefs.remove('pending_attendance_status');
          await prefs.remove('pending_teacher_id');
          await prefs.remove('pending_school_id');
        }
      }
    } catch (e) {
      debugPrint("❌ فشل في محاولة رفع التحضير المعلق: $e");
    }
  }

  Future<void> _fetchCurrentAttendanceCode() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? schoolId = prefs.getInt('schoolId');
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('attendanceCodes') //  الكولكشن اللي طلبته
          .doc(schoolId.toString()) //  الدوكمنت اللي طلبته
          .get();

      if (snapshot.exists) {
        setState(() {
          _currentAttendanceCode = snapshot['code'];
        });
      } else {
        _showDialog(
            "خطأ", "⚠️ لم يتم العثور على اسم المعلم. يرجى التحقق من حسابك.");
      }
    } catch (e) {
      _showDialog("خطأ", "❌ حدث خطأ أثناء جلب كود الحضور: $e");
    }
  }

  Future<void> _markAttendance(String teacherName) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? teacherId = prefs.getInt('user_id');
      int? schoolId = prefs.getInt('schoolId');
      String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // تحديد حالة الحضور بناءً على الوقت
      String attendanceStatus = "حاضر";
      TimeOfDay.now();

      // إذا كان الوقت بعد الساعة 7:30 صباحاً يعتبر متأخراً
      // يمكنك تعديل هذه القيم حسب سياسة المدرسة
      // تم تعليق التحقق من الوقت للاختبار
      if ((now.hour == allowedStartHour && now.minute > lateMinuteThreshold) ||
          now.hour > allowedStartHour) {
        attendanceStatus = "متأخر";
      }
      // للاختبار، دائماً يعتبر حاضر
      attendanceStatus = "حاضر";

      // التحقق من عدم وجود تسجيل سابق لهذا المعلم في هذا اليوم
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(date)
          .collection('teachers')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      if (snapshot.docs.isEmpty) {
        // إضافة تسجيل جديد مع حالة الحضور
        await FirebaseFirestore.instance
            .collection('attendance')
            .doc(date)
            .collection('teachers')
            .doc(teacherId?.toString() ?? teacherName)
            .set({
          'teacherId': teacherId,
          'schoolId': schoolId,
          'name': teacherName,
          'status': attendanceStatus,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // حفظ التاريخ محلياً لمنع التسجيل المتكرر
      prefs.setString('last_attendance_date', date);

      setState(() {
        _attendanceDone = true;
        _teacherName = teacherName;
      });
    } catch (e) {
      await _savePendingAttendance(teacherName); //  حفظ مؤقت
      _showDialog("لا يوجد اتصال",
          "❌ تم حفظ حضورك مؤقتًا وسيتم رفعه تلقائيًا عند توفر الإنترنت.");
    }
  }

  Future<void> _handleScan(BarcodeCapture barcodeCapture) async {
    await SharedPreferences.getInstance();
    if (_scanned) return;

    final String? scannedCode = barcodeCapture.barcodes.first.rawValue;
    if (scannedCode != null) {
      _scanned = true;
      _controller.stop();
      final now = TimeOfDay.now();
      // تم تعليق التحقق من الوقت للاختبار
      if (now.hour < allowedStartHour || (now.hour > allowedEndHour)) {
        _showDialog(
          "خارج الوقت المسموح",
          "يمكنك تسجيل الحضور من الساعه $allowedStartHour الى الساعة $allowedEndHour",
        );
        return;
      }

      // استخراج كود الحضور من الرمز المقروء (الذي قد يحتوي على معرف المدرسة)
      String extractedCode = scannedCode;
      if (scannedCode.contains(':')) {
        extractedCode =
            scannedCode.split(':')[0]; // أخذ الجزء قبل علامة ":" فقط
      }

      debugPrint('===== $_currentAttendanceCode =====');
      debugPrint('===== $scannedCode =====');
      debugPrint('===== استخراج الكود: $extractedCode =====');

      if (_currentAttendanceCode == null) {
        _showDialog("خطأ", "⚠️ كود الحضور غير متوفر حالياً. حاول لاحقاً.");
        return;
      }
      if (extractedCode == _currentAttendanceCode) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? teacherName = prefs.getString('user_name');

        if (teacherName == null) return;

        // Using the existing prefs variable
        String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        String? lastDate = prefs.getString('last_attendance_date');

        // تحديد حالة الحضور
        // تم تعليق التحقق من الوقت للاختبار
        if ((now.hour == allowedStartHour &&
                now.minute > lateMinuteThreshold) ||
            now.hour > allowedStartHour) {
          _attendanceStatus = "متأخر";
        } else {
          _attendanceStatus = "حاضر";
        }
        // للاختبار، دائماً يعتبر حاضر
        _attendanceStatus = "حاضر";

        if (lastDate == today) {
          _showDialog("تم تسجيل الحضور مسبقًا",
              "لقد قمت بتسجيل حضورك بالفعل اليوم! 👍");
        } else {
          await _markAttendance(teacherName);
        }
      } else {
        _showDialog(
          "رمز غير صحيح",
          "❌ الرجاء التأكد من أنك تمسح الرمز الصحيح.",
        );
      }
    }
  }

  Future<void> _savePendingAttendance(String teacherName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? teacherId = prefs.getInt('userId');
    int? schoolId = prefs.getInt('schoolId');
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // تحديد حالة الحضور بناءً على الوقت
    String attendanceStatus = "حاضر";
    TimeOfDay.now();

    // إذا كان الوقت بعد الساعة 7:30 صباحاً، يعتبر متأخراً
    // تم تعليق التحقق من الوقت للاختبار
    /* if ((now.hour == allowedStartHour && now.minute > lateMinuteThreshold) || now.hour > allowedStartHour) {
      attendanceStatus = "متأخر";
    } */
    // للاختبار، دائماً يعتبر حاضر
    attendanceStatus = "حاضر";

    // حفظ البيانات محلياً للرفع لاحقاً
    await prefs.setString('pending_attendance', teacherName);
    await prefs.setString('pending_attendance_date', date);
    await prefs.setString('pending_attendance_status', attendanceStatus);
    await prefs.setInt('pending_teacher_id', teacherId ?? 0);
    await prefs.setInt('pending_school_id', schoolId ?? 0);

    try {
      // محاولة رفع البيانات مباشرة
      await FirebaseFirestore.instance
          .collection('attendance')
          .doc(date)
          .collection('teachers')
          .doc(teacherId?.toString() ?? teacherName)
          .set({
        'teacherId': teacherId,
        'schoolId': schoolId,
        'name': teacherName,
        'status': attendanceStatus,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // تم التحضير بنجاح، نحذف البيانات من التخزين المحلي
      await prefs.remove('pending_attendance');
      await prefs.remove('pending_attendance_date');
      await prefs.remove('pending_attendance_status');
      await prefs.remove('pending_teacher_id');
      await prefs.remove('pending_school_id');

      setState(() {
        _attendanceDone = true;
        _teacherName = teacherName;
      });
    } catch (e) {
      // إذا فشلنا مرة أخرى، نخلي البيانات محفوظة.
      debugPrint("❗فشل رفع التحضير المؤقت: $e");
    }
  }

  Future<void> _checkIfAlreadyMarked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    String? lastMarkedDate = prefs.getString('last_attendance_date');

    if (lastMarkedDate == today) {
      setState(() {
        _attendanceDone = true;
      });
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _scanned = false;
              });
              _controller.start();
            },
            child: const Text("موافق"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // متغير لتخزين حالة الحضور
  String _attendanceStatus = "حاضر";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تحضير المعلمين'),
          backgroundColor: Color.fromARGB(255, 1, 117, 70),
          elevation: 0,
        ),
        body: _attendanceDone
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _attendanceStatus == "متأخر"
                            ? Icons.access_time
                            : Icons.check_circle_outline,
                        size: 100,
                        color: _attendanceStatus == "متأخر"
                            ? Colors.orange
                            : Colors.blueAccent,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _attendanceStatus == "متأخر"
                            ? "تم تسجيل حضورك بنجاح (متأخر) ⏰"
                            : "تم تسجيل حضورك بنجاح ✅",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _attendanceStatus == "متأخر"
                              ? Colors.orange
                              : Colors.blueAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _teacherName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text(
                          "رجوع",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: <Widget>[
                  const SizedBox(height: 20),
                  const Text(
                    '📷 امسح رمز QR لتسجيل الحضور ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blueAccent, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: MobileScanner(
                          controller: _controller,
                          onDetect: _handleScan,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
