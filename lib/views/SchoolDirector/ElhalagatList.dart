
import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/SchoolDirector/AddHalaga.dart';
import 'package:al_furqan/views/SchoolDirector/halagaDetails.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class HalqatListPage extends StatefulWidget {
  UserModel? user;
  HalqatListPage({super.key, required this.user});

  @override
  State<HalqatListPage> createState() => _HalqatListPageState();
}

class _HalqatListPageState extends State<HalqatListPage> {
  // قائمة افتراضية تحتوي على بيانات الحلقات
  List<HalagaModel> halaqat = [];
  @override
  void initState() {
    super.initState();
    _loadHalaqat(); // استدعاء دالة جلب الحلقات عند تهيئة الصفحة
  }

  // دالة لجلب الحلقات من قاعدة البيانات
  Future<void> _loadHalaqat() async {
    setState(() {
      halaqat = []; // تهيئة القائمة عند تحميل البيانات
    });

    int? schoolID = widget.user?.schoolID;

    if (schoolID != null) {
      // التأكد من أن القيمة التي تُرجعها gitData ليست null
      List<HalagaModel>? loadedHalaqat =
          await halagaController.getData(schoolID);
      setState(() {
        if (loadedHalaqat!.isNotEmpty) {
          halaqat = loadedHalaqat;
          print('تم تحميل ${halaqat.length} حلقة');
        } else {
          // عرض رسالة توضيحية عندما تكون القائمة فارغة أو null
          halaqat = [];
          print("لا يوجد حلقات");
        }
      });
    } else {
      print("schoolID is null");
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
                            halqa.TeacherName == 'لا يوجد معلم للحلقة'
                                ? Colors.red
                                : Colors.green[700]!;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                  color: Colors.teal.withOpacity(0.3),
                                  width: 1),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () async {
                                //الانتقال إلى صفحة تفاصيل الحلقة
                                final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            HalqaDetailsPage(halqa: halqa)));

                                // تحديث القائمة بعد العودة إذا تم التعديل
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
                                          child: Icon(Icons.school,
                                              color: Colors.white, size: 28),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                halqa.Name ??
                                                    'اسم غير متوفر', // عرض اسم الحلقة
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.person,
                                                      size: 16,
                                                      color: teacherTextColor),
                                                  SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      halqa.TeacherName ??
                                                          'لا يوجد معلم للحلقة',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              teacherTextColor,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.groups,
                                                size: 16,
                                                color: Colors.blue[700]),
                                            SizedBox(width: 4),
                                            Text(
                                              'عدد الطلاب: ${halqa.NumberStudent}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.blue[700],
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            // زر حذف الحلقة
                                            IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.red, size: 20),
                                              tooltip: 'حذف الحلقة',
                                              onPressed: () {
                                                _showDeleteConfirmationDialog(
                                                    halqa);
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
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // الانتقال لصفحة إضافة حلقة جديدة
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AddHalaqaScreen(user: widget.user!))).then((_) {
            // تحديث القائمة بعد العودة من إضافة حلقة
            _loadHalaqat();
            // إظهار رسالة تأكيد تحديث البيانات
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم تحديث قائمة الحلقات'),
                duration: Duration(seconds: 2),
              ),
            );
          });
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, color: Colors.white),
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

      // إغلاق مؤشر التحميل
      Navigator.of(context).pop();

      // تحديث القائمة
      await _loadHalaqat();

      // إظهار رسالة نجاح الحذف
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
}
