import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/TeacherController.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/SchoolDirector/add_students_to_halqa_screen.dart';
import 'package:flutter/material.dart';

class EditHalagaScreen extends StatefulWidget {
  final HalagaModel halga;
  final String teacher;
  const EditHalagaScreen(
      {super.key, required this.halga, required this.teacher});

  @override
  _EditHalagaScreenState createState() => _EditHalagaScreenState();
}

class _EditHalagaScreenState extends State<EditHalagaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  List<StudentModel> students = [];
  List<UserModel> teachers = [];
  String? selectedTeacherId;
  bool _isLoading = false;
  bool _isLoadingTeachers = false;
  final _sqlDb = SqlDb();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.halga.Name ?? '';
    _loadTeachers();
    _loadStudents();
  }

  Future<void> _loadTeachers() async {
    if (widget.halga.SchoolID == null) {
      debugPrint("SchoolID is null");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ: معرف المدرسة غير متوفر')),
        );
      }
      return;
    }

    try {
      setState(() => _isLoadingTeachers = true);

      // استخدام teacherController لاسترجاع جميع المعلمين المنتمين للمدرسة
      await teacherController.getTeachersBySchoolID(widget.halga.SchoolID!);

      if (mounted) {
        setState(() {
          teachers = teacherController.teachers;

          // طلب معلم الحلقة الحالي
          final String currentTeacherName = widget.teacher;
          if (currentTeacherName != 'لا يوجد معلم للحلقة') {
            // البحث عن المعلم الحالي بالاسم
            final nameParts = currentTeacherName.trim().split(' ');
            if (nameParts.isNotEmpty) {
              final firstName = nameParts[0];
              final lastName = nameParts.length > 1 ? nameParts[1] : '';

              // البحث عن مطابقة بالاسم أو بمعرف الحلقة
              for (final teacher in teachers) {
                final teacherFirstName = teacher.first_name ?? '';
                final teacherLastName = teacher.last_name ?? '';
                final teacherHalqaID = teacher.elhalagatID;

                if ((teacherFirstName == firstName &&
                        teacherLastName == lastName) ||
                    teacherHalqaID == widget.halga.halagaID) {
                  selectedTeacherId = teacher.user_id;
                  break;
                }
              }
            }
          } else {
            // في حالة عدم وجود معلم للحلقة، ابحث عن معلم بدون حلقة للاقتراح
            for (final teacher in teachers) {
              if (teacher.elhalagatID == null) {
                // لا تعين تلقائيًا، فقط سنقوم بتمييز هؤلاء المعلمين في واجهة المستخدم
                break;
              }
            }
          }

          // ترتيب المعلمين - المعلمين الذين ليس لديهم حلقات أولاً
          teachers.sort((a, b) {
            if (a.elhalagatID == null && b.elhalagatID != null) {
              return -1; // a بدون حلقة، b له حلقة
            } else if (a.elhalagatID != null && b.elhalagatID == null) {
              return 1; // a له حلقة، b بدون حلقة
            } else {
              // ترتيب أبجدي إذا كان كلاهما متشابهين من حيث وجود حلقة
              return (a.first_name ?? '').compareTo(b.first_name ?? '');
            }
          });

          _isLoadingTeachers = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading teachers: $e");
      if (mounted) {
        setState(() => _isLoadingTeachers = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في جلب المعلمين: $e')),
        );
      }
    }
  }

  Future<void> _loadStudents() async {
    if (widget.halga.halagaID == null) {
      debugPrint("halagaID is null");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ: معرف الحلقة غير متوفر')),
        );
      }
      return;
    }
    try {
      if (mounted) setState(() => _isLoading = true);
      final fetchedStudents =
          await studentController.getStudents(widget.halga.halagaID!);
      if (mounted) {
        setState(() {
          students = fetchedStudents;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading students: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في جلب الطلاب: $e')),
        );
      }
    }
  }

  Future<void> _removeStudent(String studentId) async {
    try {
      await studentController.removeStudentFromHalqa(studentId);
      if (mounted) {
        setState(() {
          students.removeWhere((student) => student.studentID == studentId);
        });
        // تحديث عدد الطلاب في الحلقة
        final count =
            await halagaController.getStudentCount(widget.halga.halagaID!);
        await _sqlDb.updateData(
            "UPDATE Elhalagat SET NumberStudent = $count WHERE halagaID = ${widget.halga.halagaID}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إلغاء ارتباط الطالب بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error removing student: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في إلغاء ارتباط الطالب: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // التحقق من وجود معرف الحلقة قبل المتابعة
      if (widget.halga.halagaID == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('خطأ: معرف الحلقة غير متوفر'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      try {
        setState(() => _isLoading = true);

        // تسجيل للتشخيص
        debugPrint("بدء عملية تحديث الحلقة...");
        debugPrint("معرف المعلم المحدد: $selectedTeacherId");
        String idTeacher = selectedTeacherId!;

        // بناء نموذج الحلقة المحدثة
        final updatedHalaga = HalagaModel(
          halagaID: widget.halga.halagaID,
          Name: nameController.text,
          SchoolID: widget.halga.SchoolID,
          NumberStudent: students.length,
        );

        // طباعة بيانات الحلقة المحدثة للتشخيص
        debugPrint(
            "الحلقة المحدثة - الاسم: ${updatedHalaga.Name}, ID: ${updatedHalaga.halagaID}");

        // استدعاء دالة تحديث الحلقة مع تسجيلمرير معرف المعلم المحدد
        await halagaController.updateHalaga(updatedHalaga, 1);
        await halagaController.updateTeacherAssignment(
            updatedHalaga.halagaID!, idTeacher);
        debugPrint("تم تحديث الحلقة بنجاح");

        setState(() => _isLoading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تعديل بيانات الحلقة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // إرجاع true للإشارة إلى أنه تم التحديث
        }
      } catch (e) {
        setState(() => _isLoading = false);
        debugPrint("خطأ في تحديث الحلقة: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في تعديل الحلقة: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل بيانات الحلقة'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading && _isLoadingTeachers
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  // عنوان الصفحة مع معلومات الحلقة
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child:
                                  const Icon(Icons.groups, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'حلقة: ${widget.halga.Name}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'عدد الطلاب: ${students.length}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // محتوى الصفحة
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // بطاقة معلومات الحلقة
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'معلومات الحلقة',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // حقل اسم الحلقة
                                    TextFormField(
                                      controller: nameController,
                                      decoration: InputDecoration(
                                        labelText: 'اسم الحلقة',
                                        hintText: 'أدخل اسم الحلقة',
                                        prefixIcon: const Icon(Icons.title),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'الرجاء إدخال اسم الحلقة';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // قائمة المعلمين
                                    _isLoadingTeachers
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : _buildTeacherDropdown(),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // قسم الطلاب
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // عنوان القسم مع زر إضافة
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.groups,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                            const SizedBox(width: 10),
                                            const Text(
                                              'الطلاب',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextButton.icon(
                                          onPressed: () {
                                            if (widget.halga.halagaID == null ||
                                                widget.halga.SchoolID == null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'خطأ: معرف الحلقة أو المدرسة غير متوفر')),
                                              );
                                              return;
                                            }
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddStudentsToHalqaScreen(
                                                  halqaID:
                                                      widget.halga.halagaID,
                                                  schoolID:
                                                      widget.halga.SchoolID,
                                                ),
                                              ),
                                            ).then((_) => _loadStudents());
                                          },
                                          icon: Icon(Icons.add,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          label: Text(
                                            'إضافة طلاب',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // قائمة الطلاب
                                  Container(
                                    constraints:
                                        const BoxConstraints(maxHeight: 250),
                                    child: _isLoading
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : students.isEmpty
                                            ? Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      20.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.person_off,
                                                          size: 48,
                                                          color:
                                                              Colors.grey[400]),
                                                      const SizedBox(
                                                          height: 16),
                                                      const Text(
                                                        'لا يوجد طلاب في هذه الحلقة',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : ListView.separated(
                                                shrinkWrap: true,
                                                padding: EdgeInsets.zero,
                                                itemCount: students.length,
                                                separatorBuilder: (context,
                                                        index) =>
                                                    const Divider(height: 1),
                                                itemBuilder: (context, index) {
                                                  final student =
                                                      students[index];
                                                  return ListTile(
                                                    leading: CircleAvatar(
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .primaryColor
                                                              .withOpacity(0.2),
                                                      child: Text(
                                                        student.firstName
                                                                ?.substring(
                                                                    0, 1)
                                                                .toUpperCase() ??
                                                            'ط',
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    title: Text(
                                                      '${student.firstName ?? ''} ${student.middleName ?? ''} ${student.grandfatherName ?? ''} ${student.lastName ?? ''}'
                                                          .trim(),
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                    trailing: IconButton(
                                                      icon: const Icon(
                                                          Icons.delete_outline,
                                                          color: Colors.red),
                                                      tooltip:
                                                          'إزالة الطالب من الحلقة',
                                                      onPressed: () =>
                                                          _confirmRemoveStudent(
                                                              student),
                                                    ),
                                                  );
                                                },
                                              ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // أزرار الإجراءات
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text('جاري الحفظ...'),
                                    ],
                                  )
                                : const Text(
                                    'حفظ التعديلات',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // عرض مربع حوار تأكيد إزالة طالب
  void _confirmRemoveStudent(StudentModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد إزالة الطالب'),
        content: Text(
            'هل أنت متأكد من رغبتك في إزالة الطالب "${student.firstName} ${student.lastName}" من الحلقة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeStudent(student.studentID!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('إزالة'),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherDropdown() {
    // تعيين قائمة للمعلمين الذين ليس لديهم حلقات
    final List<UserModel> availableTeachers = teachers
        .where((teacher) =>
            teacher.elhalagatID == null ||
            teacher.elhalagatID == widget.halga.halagaID)
        .toList();

    // تعيين قائمة للمعلمين الذين لديهم حلقات
    final List<UserModel> assignedTeachers = teachers
        .where((teacher) =>
            teacher.elhalagatID != null &&
            teacher.elhalagatID != widget.halga.halagaID)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String?>(
          value: selectedTeacherId,
          decoration: InputDecoration(
            labelText: 'اختر المعلم',
            hintText: 'اختر معلم للحلقة',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: [
            // خيار "بدون معلم"
            DropdownMenuItem<String>(
              value: null,
              child: Row(
                children: [
                  const Icon(Icons.person_off, color: Colors.grey),
                  const SizedBox(width: 10),
                  const Text(
                    'بدون معلم',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // إذا كان هناك معلمون متاحون، نضع عنوان لهم
            if (availableTeachers.isNotEmpty)
              DropdownMenuItem<String>(
                enabled: false,
                value: "999", // قيمة غير صالحة للاختيار
                child: Text(
                  '-- المعلمون المتاحون --',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

            // قائمة المعلمين المتاحين (الذين ليس لديهم حلقات)
            ...availableTeachers.map((teacher) {
              final bool isCurrentTeacher =
                  teacher.elhalagatID == widget.halga.halagaID;

              return DropdownMenuItem<String?>(
                value: teacher.user_id!,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isCurrentTeacher
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).primaryColor.withOpacity(0.2),
                      radius: 14,
                      child: Text(
                        teacher.first_name?.substring(0, 1).toUpperCase() ??
                            'م',
                        style: TextStyle(
                          color: isCurrentTeacher
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${teacher.first_name ?? ''} ${teacher.last_name ?? ''}'
                            .trim(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isCurrentTeacher
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isCurrentTeacher)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'معلم الحلقة الحالي',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (teacher.elhalagatID == null)
                      Icon(Icons.check_circle, color: Colors.green, size: 18),
                  ],
                ),
              );
            }),

            // إذا كان هناك معلمون مشغولون، نضع عنوان لهم
            if (assignedTeachers.isNotEmpty)
              DropdownMenuItem<String>(
                enabled: false,
                value: "-998", // قيمة غير صالحة للاختيار
                child: Text(
                  '-- المعلمون المرتبطون بحلقات أخرى --',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

            // قائمة المعلمين المشغولين (الذين لديهم حلقات)
            ...assignedTeachers.map((teacher) {
              return DropdownMenuItem<String>(
                value: teacher.user_id,
                enabled: false, // تعطيل المعلمين المرتبطين بحلقات أخرى
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      radius: 14,
                      child: Text(
                        teacher.first_name?.substring(0, 1).toUpperCase() ??
                            'م',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${teacher.first_name ?? ''} ${teacher.last_name ?? ''}'
                            .trim(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const Text(
                      '(مرتبط بحلقة أخرى)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              selectedTeacherId = value;
            });
          },
          hint: const Text('اختر معلم'),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          iconSize: 30,
          menuMaxHeight: 350,
        ),
        if (availableTeachers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'المعلمون بعلامة ${String.fromCharCode(0x2705)} متاحون للتعيين مباشرة',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
