import 'package:al_furqan/controllers/TeacherController.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/current_user.dart';
import 'package:al_furqan/models/provider/user_provider.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/views/SchoolDirector/edit_teacher.dart';
import 'package:al_furqan/views/SchoolDirector/teacher_request.dart';
import 'package:provider/provider.dart';

class TeacherList extends StatefulWidget {
  const TeacherList({super.key});

  @override
  State<TeacherList> createState() => _TeacherListState();
}

class _TeacherListState extends State<TeacherList>
// with UserDataMixin
{
  String _searchQuery = '';
  UserModel? user = CurrentUser.user;
  // List<UserModel> _filteredTeachers = [];
  bool _isSearching = false;
  bool _isRefreshing = false; // Local loading state for refresh operations
  bool _hasInitialized = false;
  bool _forceShowContent = false; // إضافة متغير جديد للتحكم في عرض المحتوى
  int _pendingActivationsCount = 0; // عدد طلبات التفعيل المعلقة

  @override
  void initState() {
    super.initState();
    _initializeTeachers();
  }

  Future<void> _initializeTeachers() async {
    debugPrint("TeacherList: _initializeTeachers started");
    // await fetchUserData();

    // If UserDataMixin didn't load teachers properly, load them directly
    if (teacherController.teachers.isEmpty && user!.schoolID != null) {
      debugPrint(
          "TeacherList: No teachers found after mixin initialization, fetching directly");
      // await _directFetchTeachers();
    } else {
      debugPrint(
          "TeacherList: ${teacherController.teachers.length} teachers found after mixin initialization");
      // _updateFilteredTeachers();
    }

    // التحقق من وجود طلبات تفعيل معلقة
    await _checkPendingActivations();

    _hasInitialized = true;
    _forceShowContent = true; // إضافة تعيين قيمة true للمتغير الجديد
    setState(() {});
    debugPrint("TeacherList: _initializeTeachers completed");
  }

  // التحقق من وجود طلبات تفعيل معلقة
  Future<void> _checkPendingActivations() async {
    if (user!.schoolID != null) {
      try {
        // استخدام الدالة الثابتة من TeacherRequest للتحقق من طلبات التفعيل
        _pendingActivationsCount =
            await TeacherRequest.checkPendingActivationsCount(user!.schoolID!);
        debugPrint(
            "TeacherList: Found $_pendingActivationsCount pending activations");
      } catch (e) {
        debugPrint("TeacherList: Error checking pending activations - $e");
        _pendingActivationsCount = 0;
      }
      setState(() {});
    }
  }

  // Direct fetch method that doesn't rely on the mixin
  // Future<void> _directFetchTeachers() async {
  //   if (user!.schoolID == null) {
  //     debugPrint("TeacherList: _directFetchTeachers - schoolID is null");
  //     return;
  //   }

  //   setState(() {
  //     _isRefreshing = true;
  //   });

  //   debugPrint("TeacherList: Directly fetching teachers for schoolID: ${user!.schoolID}");
  //   try {
  //     await teacherController.getTeachersBySchoolID(user!.schoolID!);
  //     _updateFilteredTeachers();
  //     debugPrint(
  //         "TeacherList: Direct fetch complete, found ${_filteredTeachers.length} teachers");
  //   } catch (e) {
  //     debugPrint("TeacherList: Error in direct fetch - $e");
  //   } finally {
  //     setState(() {
  //       _isRefreshing = false;
  //     });
  //   }
  // }

  // void _updateFilteredTeachers() {
  //   // تصفية المعلمين أولاً بناءً على isActivate = 1
  //   List<UserModel> activatedTeachers = teacherController.teachers
  //       .where((teacher) => teacher.isActivate == 1)
  //       .toList();

  //   if (_searchQuery.isEmpty) {
  //     _filteredTeachers = List.from(activatedTeachers);
  //   } else {
  //     _filteredTeachers = activatedTeachers.where((teacher) {
  //       final fullName =
  //           '${teacher.first_name ?? ''} ${teacher.middle_name ?? ''} ${teacher.last_name ?? ''}'
  //               .toLowerCase();
  //       return fullName.contains(_searchQuery.toLowerCase());
  //     }).toList();
  //   }
  //   // Debug print
  //   debugPrint("Filtered teachers updated - count: ${_filteredTeachers.length}");
  //   setState(() {});
  // }

  // Future<void> _refreshTeachers() async {
  //   if (schoolID != null) {
  //     debugPrint("Refreshing teachers for schoolID: $schoolID");
  //     setState(() {
  //       _isRefreshing = true;
  //     });

  //     try {
  //       await teacherController.getTeachersBySchoolID(schoolID!);
  //       debugPrint(
  //           "Teachers refreshed - count: ${teacherController.teachers.length}");
  //       _updateFilteredTeachers();

  //       // تحديث عدد طلبات التفعيل المعلقة
  //       await _checkPendingActivations();
  //     } catch (e) {
  //       debugPrint("Error refreshing teachers: $e");
  //     } finally {
  //       setState(() {
  //         _isRefreshing = false;
  //       });
  //     }
  //   } else {
  //     debugPrint("Cannot refresh - schoolID is null");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSearchBar(),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Selector<UserProvider, int>(
                        builder: (context, prov, child) => Text(
                              'عدد المعلمين المفعلين: $prov',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                        selector: (_, s) => s.teacherCount),
                    const Text(
                      '(يتم عرض المعلمين المفعلين فقط)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () =>
                      (context).read<UserProvider>().loadTeachers(),
                  tooltip: 'تحديث البيانات',
                  color: const Color.fromARGB(255, 1, 117, 70),
                ),
              ],
            ),
          ),
          Expanded(
            child: (_isRefreshing && !_forceShowContent) // تعديل الشرط هنا
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color.fromARGB(255, 1, 117, 70),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'جاري تحميل بيانات المعلمين...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : Consumer<UserProvider>(
                    builder: (context, prov, child) => prov.teachers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'لا يوجد معلمين مفعلين بهذا الاسم'
                                      : 'لا يوجد معلمين مفعلين في هذه المدرسة',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                        _isSearching = false;
                                        // _updateFilteredTeachers();
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 1, 117, 70),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('إظهار جميع المعلمين'),
                                  ),
                                ],
                                // Add a refresh button when no teachers are found
                                if (_searchQuery.isEmpty) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('تحديث البيانات'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 1, 117, 70),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: prov.teachers.length,
                            itemBuilder: (context, index) {
                              final UserModel? teacher = prov.teachers[index];
                              return _buildTeacherCard(prov.teachers[index]!);
                            },
                          ),
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'بحث عن معلم...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _isSearching
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _isSearching = false;
                    // _updateFilteredTeachers();
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 1, 117, 70), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
          _isSearching = value.isNotEmpty;
          // _updateFilteredTeachers();
        });
      },
    );
  }

  Widget _buildTeacherCard(UserModel teacher) {
    final fullName =
        '${teacher.first_name ?? ''} ${teacher.middle_name ?? ''} ${teacher.last_name ?? ''}'
            .trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Color.fromARGB(255, 1, 117, 70),
                  child: Text(
                    teacher.first_name?.substring(0, 1) ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (teacher.email != null && teacher.email!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            teacher.email!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      // إضافة مؤشر حالة التفعيل
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: const Text(
                            'حساب مفعل',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildContactInfo(teacher),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, // المسافة بين الأزرار أفقياً
              runSpacing: 8, // المسافة بين الصفوف
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // View teacher details
                    // Show a dialog with teacher details
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('تفاصيل المعلم'),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    'الاسم: ${teacher.first_name} ${teacher.middle_name} ${teacher.last_name}'),
                                const SizedBox(height: 8),
                                Text(
                                    'البريد الإلكتروني: ${teacher.email ?? 'غير متوفر'}'),
                                const SizedBox(height: 8),
                                Text(
                                    'رقم الهاتف: ${teacher.phone_number ?? 'غير متوفر'}'),
                                const SizedBox(height: 8),
                                Text(
                                    'رقم الهاتف الثابت: ${teacher.telephone_number ?? 'غير متوفر'}'),
                                const SizedBox(height: 8),
                                Text(
                                    'تاريخ الميلاد: ${teacher.date ?? 'غير متوفر'}'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('إغلاق'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('عرض'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 1, 117, 70),
                    side: const BorderSide(
                        color: Color.fromARGB(255, 1, 117, 70)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    _showDeleteConfirmationDialog(teacher);
                  },
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: const Text('حذف'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTeacher(teacher: teacher),
                      ),
                    ).then((value) {
                      if (value == true) {
                        // Refresh the teacher list if edit was successful
                        (context).read<UserProvider>().loadTeachers();
                      }
                    });
                  },
                  icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                  label: const Text('تعديل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 117, 70),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(UserModel teacher) {
    return Column(
      children: [
        if (teacher.phone_number != null && teacher.phone_number != 0)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                const Icon(Icons.phone, color: Color.fromARGB(255, 1, 117, 70)),
            title: const Text('رقم الجوال'),
            subtitle: Text(teacher.phone_number.toString()),
            dense: true,
          ),
        if (teacher.telephone_number != null && teacher.telephone_number != 0)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.phone_in_talk,
                color: Color.fromARGB(255, 1, 117, 70)),
            title: const Text('رقم الهاتف'),
            subtitle: Text(teacher.telephone_number.toString()),
            dense: true,
          ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(UserModel teacher) {
    final fullName =
        '${teacher.first_name ?? ''} ${teacher.middle_name ?? ''} ${teacher.last_name ?? ''}'
            .trim();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف المعلم "$fullName"؟'),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          icon: const Icon(
            Icons.warning,
            color: Colors.red,
            size: 50,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق مربع الحوار
              },
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  color: Color.fromARGB(255, 1, 117, 70),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // إغلاق مربع الحوار
                await _deleteTeacher(teacher);
              },
              child: const Text(
                'حذف',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTeacher(UserModel teacher) async {
    try {
      // عرض مؤشر التحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Color.fromARGB(255, 1, 117, 70),
                ),
                SizedBox(height: 16),
                Text('جاري حذف المعلم...'),
              ],
            ),
          );
        },
      );

      // حذف المعلم باستخدام الـ controller
      if (teacher.user_id != null) {
        await userController.deleteUser(teacher.user_id!);

        // تحديث القائمة بعد الحذف
        await (context).read<UserProvider>().loadTeachers();

        // إغلاق مؤشر التحميل
        if (!mounted) return;
        Navigator.of(context).pop();

        // عرض رسالة نجاح
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المعلم بنجاح'),
            backgroundColor: Color.fromARGB(255, 1, 117, 70),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // إغلاق مؤشر التحميل في حالة حدوث خطأ
      if (!mounted) return;
      Navigator.of(context).pop();

      // عرض رسالة الخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء حذف المعلم: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
