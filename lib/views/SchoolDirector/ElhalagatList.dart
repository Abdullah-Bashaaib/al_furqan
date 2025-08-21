import 'dart:developer';

import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/main.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/provider/halaqa_provider.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:al_furqan/views/SchoolDirector/AddHalaga.dart';
import 'package:al_furqan/views/Teacher/HalqaReportScreen.dart';
import 'package:al_furqan/views/SchoolDirector/halagaDetails.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class HalqatListPage extends StatefulWidget {
  int? schoolIdS;
  HalqatListPage({super.key, this.schoolIdS});

  @override
  State<HalqatListPage> createState() => _HalqatListPageState();
}

class _HalqatListPageState extends State<HalqatListPage> {
  // قائمة الحلقات
  List<HalagaModel> halaqat = [];
  // خريطة لتخزين أسماء المعلمين بناءً على halagaID
  Map<String, String> teacherNames = {};
  final HalagaController halagaController = HalagaController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      (context).read<HalaqaProvider>().loadHalaqatFromFirebase();
    });
    // استدعاء جلب الحلقات من Firebase وتحميل البيانات
    _loadHalaqat();
  }

  // دالة لجلب الحلقات وأسماء المعلمين
  Future<void> _loadHalaqat() async {
    setState(() {
      halaqat = []; // تهيئة القائمة عند تحميل البيانات
      teacherNames = {}; // تهيئة خريطة أسماء المعلمين
    });
    int? schoolID = widget.schoolIdS ?? perf.getInt("schoolId");

    if (schoolID != null) {
      try {
        // جلب الحلقات
        List<HalagaModel>? loadedHalaqat =
            await halagaController.getData(schoolID);
        if (loadedHalaqat.isNotEmpty) {
          halaqat = loadedHalaqat;

          debugPrint('تم تحميل ${halaqat.length} حلقة');

          // جلب أسماء المعلمين لكل حلقة
          for (var halqa in halaqat) {
            halqa.teacherName =
                await halagaController.getTeacher(halqa.halagaID!);
            debugPrint(halqa.teacherName);
          }
        } else {
          halaqat = [];
          debugPrint("لا يوجد حلقات");
        }
        setState(() {}); // تحديث الواجهة بعد جلب البيانات
      } catch (e) {
        debugPrint("خطأ أثناء تحميل الحلقات: $e");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تحميل الحلقات: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      debugPrint("schoolID is null");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('معرف المدرسة غير متوفر'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('الحلقات الدراسية',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // زر تحديث البيانات
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            tooltip: 'تحديث البيانات',
            onPressed: () {
              // إظهار رسالة تأكيد تحديث البيانات
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('جاري تحديث البيانات...'),
                  duration: Duration(seconds: 1),
                ),
              );
              _loadHalaqat(); // استدعاء دالة تحميل البيانات
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHalaqat,
        child: Column(
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'إجمالي الحلقات: ${halaqat.length}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: halaqat.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school_outlined,
                              size: 64, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            'لا توجد حلقات مضافة.',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'اضغط على زر الإضافة لإنشاء حلقة جديدة',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: halaqat.length,
                      itemBuilder: (context, index) {
                        final halqa = halaqat[
                            index]; // الحصول على الحلقة بناءً على الفهرس
                        // تحديد لون المعلم بناء على وجوده
                        Color teacherTextColor =
                            halqa.teacherName == 'لا يوجد معلم للحلقة'
                                ? Colors.red
                                : Colors.green[700]!;
                        return _buildHalqaCard(
                            halqa, halqa.teacherName ?? '', teacherTextColor);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'إضافة حلقة جديدة',
        onPressed: () {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddHalaqaScreen()))
              .then((_) {
            _loadHalaqat();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم تحديث قائمة الحلقات'),
                duration: Duration(seconds: 2),
              ),
            );
          });
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // دالة لإنشاء كارد الحلقة
  Widget _buildHalqaCard(
      HalagaModel halqa, String teacherName, Color teacherTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: Colors.teal.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HalqaDetailsPage(
                  halqa: halqa,
                  teacher: teacherName,
                ),
              ),
            );

            if (result == true) {
              await _loadHalaqat();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم تحديث بيانات الحلقة'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.teal,
                      radius: 24,
                      child: Icon(Icons.school, color: Colors.white, size: 28),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            halqa.Name ?? 'اسم غير متوفر',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person,
                                  size: 16, color: teacherTextColor),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  halqa.teacherName ?? '',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: teacherTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.groups, size: 16, color: Colors.blue[700]),
                        SizedBox(width: 4),
                        Text(
                          'عدد الطلاب: ${halqa.NumberStudent}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.picture_as_pdf,
                              color: Colors.orange, size: 20),
                          tooltip: 'تقرير PDF',
                          onPressed: () {
                            _showPdfFeatureDialog(context, halqa);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red, size: 20),
                          tooltip: 'حذف الحلقة',
                          onPressed: () {
                            _showDeleteConfirmationDialog(halqa);
                          },
                        ),
                        Icon(Icons.arrow_forward_ios,
                            color: Colors.teal, size: 16),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // عرض مربع حوار لتأكيد حذف الحلقة
  void _showDeleteConfirmationDialog(HalagaModel halqa) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد الحذف'),
          content: Text(
              'هل أنت متأكد من حذف حلقة "${halqa.Name}"؟\n\nسيتم إلغاء ارتباط الطلاب والمعلمين بهذه الحلقة.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق مربع الحوار
              },
              child: Text('إلغاء',
                  style: TextStyle(color: Theme.of(context).primaryColor)),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // إغلاق مربع الحوار
                await _deleteHalaga(halqa); // حذف الحلقة
              },
              child: Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // دالة حذف الحلقة
  Future<void> _deleteHalaga(HalagaModel halqa) async {
    try {
      // عرض مؤشر التحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // حذف الحلقة من قاعدة البيانات
      await halagaController.deleteHalaga(halqa.halagaID!);
      await firebasehelper.delete(halqa.halagaID!, 'Elhalaga');

      // إغلاق مؤشر التحميل
      if (!mounted) return;
      Navigator.of(context).pop();

      // تحديث القائمة
      await _loadHalaqat();

      // إظهار رسالة نجاح الحذف
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف الحلقة "${halqa.Name}" بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // إغلاق مؤشر التحميل في حالة حدوث خطأ
      Navigator.of(context).pop();
      log('حدث خطأ أثناء حذف الحلقة: $e');
      // إظهار رسالة الخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء حذف الحلقة: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Show PDF feature explanation dialog
  void _showPdfFeatureDialog(BuildContext context, HalagaModel halqa) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.orange),
              SizedBox(width: 10),
              Text('تقارير PDF للحلقات'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'يمكنك الآن إنشاء تقارير PDF لكل حلقة تعرض:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildFeaturePoint('خطط الحفظ والتلاوة المخططة والمنفذة'),
              _buildFeaturePoint(
                  'محتويات العلوم الشرعية وأسباب التأخر إن وجدت'),
              _buildFeaturePoint('نسب الإنجاز في مختلف جوانب الحلقة'),
              SizedBox(height: 10),
              Text(
                'يمكنك طباعة التقرير أو حفظه كملف PDF.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HalqaReportScreen(halqa: halqa),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text('فتح التقرير'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to build feature points
  Widget _buildFeaturePoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
