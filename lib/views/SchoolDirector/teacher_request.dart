import 'package:flutter/material.dart';
import 'package:al_furqan/controllers/TeacherController.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/user_helper.dart';
import 'package:al_furqan/models/users_model.dart';

class TeacherRequest extends StatefulWidget {
  const TeacherRequest({super.key});

  // دالة ثابتة للتحقق من وجود طلبات تفعيل معلمين
  static Future<int> checkPendingActivationsCount(int schoolID) async {
    // جلب جميع المعلمين في المدرسة
    await teacherController.getTeachersBySchoolID(schoolID);

    // تصفية المعلمين الذين في انتظار التفعيل
    List<UserModel> pendingTeachers = teacherController.teachers
        .where((teacher) => teacher.isActivate == 0)
        .toList();

    // إرجاع عدد المعلمين الذين ينتظرون التفعيل
    return pendingTeachers.length;
  }

  @override
  State<TeacherRequest> createState() => _TeacherRequestState();
}

class _TeacherRequestState extends State<TeacherRequest> with UserDataMixin {
  List<UserModel> pendingTeachers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUserData().then((_) {
      _loadPendingTeachers();
    });
  }

  // تحميل المعلمين الذين ينتظرون التفعيل
  Future<void> _loadPendingTeachers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (schoolID == null) {
        throw Exception("لم يتم العثور على معرف المدرسة");
      }

      // استخدام الدالة الموجودة بالفعل لجلب جميع المعلمين بحسب المدرسة
      await teacherController.getTeachersBySchoolID(schoolID!);

      setState(() {
        // تصفية المعلمين الذين لديهم isActivate = 0
        pendingTeachers = teacherController.teachers
            .where((teacher) => teacher.isActivate == 0)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "حدث خطأ أثناء تحميل طلبات التفعيل: $e";
        isLoading = false;
      });
    }
  }

  // تفعيل حساب المعلم
  Future<void> _activateTeacher(UserModel teacher) async {
    setState(() {
      isLoading = true;
    });

    try {
      // تحديث حالة المعلم إلى مفعل
      teacher.isActivate = 1;

      // استخدام userController لتحديث بيانات المستخدم مع نوع التحديث 1
      await userController.updateUser(teacher, 1);

      // تحديث القائمة
      await _loadPendingTeachers();

      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'تم تفعيل حساب المعلم ${teacher.first_name} ${teacher.last_name} بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      // عرض رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل تفعيل الحساب: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // تأكيد تفعيل حساب المعلم
  void _confirmActivation(UserModel teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد تفعيل الحساب'),
        content: Text(
            'هل أنت متأكد من رغبتك في تفعيل حساب المعلم "${teacher.first_name} ${teacher.last_name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _activateTeacher(teacher);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('تفعيل'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات تفعيل المعلمين'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث القائمة',
            onPressed: _loadPendingTeachers,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadPendingTeachers,
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : pendingTeachers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 70,
                            color: Colors.green.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'لا توجد طلبات تفعيل حالياً',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'جميع حسابات المعلمين مفعلة',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPendingTeachers,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: pendingTeachers.length,
                        itemBuilder: (context, index) {
                          final teacher = pendingTeachers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.2),
                                radius: 25,
                                child: Text(
                                  teacher.first_name
                                          ?.substring(0, 1)
                                          .toUpperCase() ??
                                      'م',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              title: Text(
                                '${teacher.first_name} ${teacher.middle_name} ${teacher.last_name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.phone,
                                          size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(teacher.phone_number.toString()),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.email,
                                          size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(teacher.email ??
                                          'لا يوجد بريد إلكتروني'),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.orange.shade300),
                                    ),
                                    child: const Text(
                                      'في انتظار التفعيل',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: ElevatedButton.icon(
                                onPressed: () => _confirmActivation(teacher),
                                icon: const Icon(Icons.check_circle, size: 18),
                                label: const Text('تفعيل'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
