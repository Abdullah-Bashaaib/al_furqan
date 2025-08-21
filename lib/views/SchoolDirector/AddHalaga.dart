import 'dart:developer';

import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/main.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import '../../../controllers/TeacherController.dart';

class AddHalaqaScreen extends StatefulWidget {
  @override
  _AddHalaqaScreenState createState() => _AddHalaqaScreenState();
  const AddHalaqaScreen({
    super.key,
  });
}

class _AddHalaqaScreenState extends State<AddHalaqaScreen> {
  int? schoolId = perf.getInt("schoolId");
  final _formKey = GlobalKey<FormState>();
  final HalagaModel _halaqaModel = HalagaModel();
  final TextEditingController halqaNameController = TextEditingController();
  final TextEditingController islamicStudiesSubjectController =
      TextEditingController();
  final TextEditingController islamicStudiesContentController =
      TextEditingController();

  // تواريخ خطة الحفظ
  DateTime? conservationStartDate;
  DateTime? conservationEndDate;

  // تواريخ خطة التلاوة
  DateTime? recitationStartDate;
  DateTime? recitationEndDate;

  List<UserModel> teachers = [];
  UserModel? selectedTeacher; // المتغير الذي يخزن المعلم المختار

  List<StudentModel> studentsWithoutHalaga = [];
  Map<String, bool> selectedStudents = {}; // تخزين الطلاب المحددين
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTeachers(); // استدعاء دالة تحميل المعلمين
  }

  // void _loadTeachers() async {
  //   if (mounted) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //   }
  //   try {
  //     // جلب المعلمين حسب SchoolID
  //     await teacherController.getTeachersBySchoolID(schoolId!);

  //     // ترتيب المعلمين: المتاحين أولاً ثم المرتبطين بحلقات
  //     List<UserModel> availableTeachers = [];
  //     List<UserModel> assignedTeachers = [];

  //     for (var teacher in teacherController.teachers) {
  //       if (teacher.elhalagatID == null) {
  //         availableTeachers.add(teacher);
  //       } else {
  //         assignedTeachers.add(teacher);
  //       }
  //     }

  //     // دمج القائمتين مع وضع المتاحين أولاً
  //     if (mounted) {
  //       setState(() {
  //         teachers = [...availableTeachers, ...assignedTeachers];
  //         _isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         _errorMessage = "حدث خطأ أثناء جلب المعلمين: $e";
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  void _loadTeachers() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      await teacherController.getTeachersBySchoolID(schoolId!);

      // تصفية المعلمين الذين ليس لديهم حلقة
      List<UserModel> availableTeachers =
          teacherController.teachers.where((teacher) {
        return teacher.elhalagatID == null ||
            teacher.elhalagatID.toString().toLowerCase() == 'null';
      }).toList();
      log("message : teacher List Length : ${availableTeachers.length}");
      if (mounted) {
        setState(() {
          teachers = availableTeachers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "حدث خطأ أثناء جلب المعلمين: $e";
          _isLoading = false;
        });
      }
    }
  }

  // جلب الطلاب الذين ليس لديهم حلقة
  Future<void> _loadStudentsWithoutHalaga() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final students =
          await studentController.getStudentsWithoutHalaga(schoolId!);
      if (mounted) {
        setState(() {
          studentsWithoutHalaga = students;
          // تهيئة قائمة الطلاب المحددين
          for (var student in students) {
            selectedStudents[student.studentID!] = false;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "حدث خطأ أثناء جلب الطلاب: $e";
          _isLoading = false;
        });
      }
    }
  }

  // عدد الطلاب المحددين
  int get selectedStudentCount {
    return selectedStudents.values.where((isSelected) => isSelected).length;
  }

  // تنسيق التاريخ
  // String _formatDate(DateTime? date) {
  //   if (date == null) return 'لم يتم التحديد';
  //   return DateFormat('yyyy-MM-dd').format(date);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة حلقة', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextFormField(
                  controller: halqaNameController,
                  label: 'اسم الحلقة',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم الحلقة';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                // القائمة المنسدلة لاختيار المعلم
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<UserModel>(
                            value: selectedTeacher,
                            items: teachers
                                .where((teacher) =>
                                    teacher.elhalagatID == null ||
                                    teacher.elhalagatID
                                            .toString()
                                            .toLowerCase() ==
                                        'null')
                                .map((teacher) {
                              return DropdownMenuItem<UserModel>(
                                value: teacher,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person_outlined,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '${teacher.first_name} ${teacher.middle_name} ${teacher.last_name}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedTeacher = value; // تعيين المعلم المختار
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'اختر المعلم',
                              border: OutlineInputBorder(),
                              hintText: 'اختر معلم غير مرتبط بحلقة',
                            ),
                            isExpanded:
                                true, // للتأكد من أن النص يظهر بشكل كامل
                          ),

                          // إضافة ملاحظة توضيحية حول المعلمين
                          if (teachers.any((teacher) =>
                              (teacher.elhalagatID == 'null' &&
                                  teacher.elhalagatID != 'NULL' &&
                                  teacher.elhalagatID != null)))
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      size: 16, color: Colors.green),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'فقط المعلمون الغير مرتبطين بحلقات متاحون للاختيار',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // إضافة رسالة عندما لا يوجد معلمين متاحين
                          if (teachers.every((teacher) =>
                                  (teacher.elhalagatID != 'null' &&
                                      teacher.elhalagatID != 'NULL' &&
                                      teacher.elhalagatID != null)) &&
                              teachers.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber,
                                      size: 16, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'جميع المعلمين مرتبطين بحلقات حالياً. يمكنك تحرير حلقة لإلغاء ارتباط معلم.',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                SizedBox(height: 20),

                // زر لعرض الطلاب الذين ليس لديهم حلقة
                ElevatedButton.icon(
                  onPressed: _loadStudentsWithoutHalaga,
                  icon:
                      Icon(Icons.people, color: Theme.of(context).primaryColor),
                  label: Text('عرض الطلاب بدون حلقة',
                      style: TextStyle(color: Theme.of(context).primaryColor)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),

                SizedBox(height: 10),

                // عرض عدد الطلاب المحددين
                if (selectedStudentCount > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'الطلاب المحددين: $selectedStudentCount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: selectedStudentCount >= 5
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),

                // عرض رسالة الخطأ إذا وجدت
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                // عرض مؤشر التحميل
                if (_isLoading) Center(child: CircularProgressIndicator()),

                // قائمة الطلاب مع صناديق الاختيار
                if (studentsWithoutHalaga.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    height: 300,
                    child: ListView.builder(
                      itemCount: studentsWithoutHalaga.length,
                      itemBuilder: (context, index) {
                        final student = studentsWithoutHalaga[index];
                        return CheckboxListTile(
                          title: Text(
                              '${student.firstName} ${student.middleName} ${student.lastName}'),
                          subtitle: Text('رقم الحلقة: ${student.elhalaqaID}'),
                          value: selectedStudents[student.studentID] ?? false,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (bool? value) {
                            setState(() {
                              selectedStudents[student.studentID!] = value!;
                            });
                          },
                        );
                      },
                    ),
                  ),

                SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                late BuildContext dialogContext;
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext ctx) {
                                    dialogContext = ctx;
                                    return PopScope(
                                      canPop: false,
                                      child: AlertDialog(
                                        content: Row(
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                  'جاري إضافة البيانات...\nيرجى الانتظار'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );

                                try {
                                  // التحقق من صحة النموذج وعدد الطلاب المحددين

                                  if (_formKey.currentState!.validate()) {
                                    if (selectedStudentCount < 5) {
                                      setState(() {
                                        _errorMessage =
                                            "يجب اختيار 5 طلاب على الأقل";
                                      });
                                      return;
                                    }

                                    // إضافة الحلقة مع البيانات
                                    _halaqaModel.SchoolID = schoolId;
                                    _halaqaModel.Name =
                                        halqaNameController.text;

                                    // تعيين عدد الطلاب في نموذج الحلقة
                                    int studentCount = selectedStudentCount;
                                    _halaqaModel.NumberStudent = studentCount;

                                    // إضافة الحلقة
                                    await halagaController.addHalaga(
                                        _halaqaModel, 1);

                                    // الحصول على قائمة معرفات الطلاب المحددين
                                    List<String> selectedStudentIds = [];
                                    selectedStudents
                                        .forEach((studentId, isSelected) {
                                      if (isSelected) {
                                        selectedStudentIds.add(studentId);
                                      }
                                    });

                                    // إضافة الطلاب للحلقة
                                    await studentController
                                        .assignStudentsToHalaga(
                                            selectedStudentIds,
                                            _halaqaModel.halagaID!);

                                    // إضافة المعلم للحلقة (إذا تم اختياره)
                                    if (selectedTeacher != null) {
                                      // التحقق من أن المعلم غير مرتبط بحلقة أخرى
                                      if (selectedTeacher!.elhalagatID !=
                                              null &&
                                          selectedTeacher!.elhalagatID
                                                  .toString()
                                                  .toLowerCase() !=
                                              'null') {
                                        setState(() {
                                          _errorMessage =
                                              "المعلم المختار مرتبط بحلقة أخرى بالفعل";
                                        });
                                        return;
                                      }
                                      // تأكيد تعيين عدد الطلاب قبل تحديث الحلقة
                                      _halaqaModel.NumberStudent = studentCount;
                                      await halagaController.updateHalaga(
                                          _halaqaModel, 1);
                                      // await halagaController.updateTeacherAssignment(
                                      //     selectedTeacher!.user_id!,
                                      //     _halaqaModel.halagaID!);
                                      // تحديث elhalagatID للمعلم
                                      selectedTeacher!.elhalagatID =
                                          _halaqaModel.halagaID;
                                      await userController.updateUser(
                                          selectedTeacher!, 1);
                                      log("تم تحديث المعلم ${selectedTeacher!.first_name} ${selectedTeacher!.last_name} بحلقة رقم ${_halaqaModel.halagaID}");
                                    }
                                    Navigator.of(dialogContext).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('تم إضافة الحلقة بنجاح'),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  Navigator.of(dialogContext).pop();
                                  setState(() {
                                    _errorMessage =
                                        "حدث خطأ أثناء إضافة الحلقة: $e";
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(context).primaryColor,
                          side:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        child: Text('إضافة'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red),
                        ),
                        child: Text('الغاء'),
                      ),
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

  // تصميم حقل إدخال نصي
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?)? validator,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }
}
