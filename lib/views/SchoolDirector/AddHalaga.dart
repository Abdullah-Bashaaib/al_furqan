import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:intl/intl.dart';

import '../../controllers/TeacherController.dart';

class AddHalaqaScreen extends StatefulWidget {
  @override
  _AddHalaqaScreenState createState() => _AddHalaqaScreenState();
  final UserModel user;
  const AddHalaqaScreen({super.key, required this.user});
}

class _AddHalaqaScreenState extends State<AddHalaqaScreen> {
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
  Map<int, bool> selectedStudents = {}; // تخزين الطلاب المحددين
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTeachers(); // استدعاء دالة تحميل المعلمين
  }

  void _loadTeachers() async {
    // جلب المعلمين حسب SchoolID
    await teacherController.getTeachersBySchoolID(widget.user.schoolID!);
    setState(() {
      teachers = teacherController.teachers; // تعيين المعلمين في القائمة
    });
  }

  // جلب الطلاب الذين ليس لديهم حلقة
  Future<void> _loadStudentsWithoutHalaga() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final students = await studentController
          .getStudentsWithoutHalaga(widget.user.schoolID!);
      setState(() {
        studentsWithoutHalaga = students;
        // تهيئة قائمة الطلاب المحددين
        for (var student in students) {
          selectedStudents[student.studentID!] = false;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "حدث خطأ أثناء جلب الطلاب: $e";
        _isLoading = false;
      });
    }
  }

  // عدد الطلاب المحددين
  int get selectedStudentCount {
    return selectedStudents.values.where((isSelected) => isSelected).length;
  }

  // اختيار تاريخ
  Future<void> _selectDate(BuildContext context,
      {required bool isStart, required bool isConservation}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isConservation) {
          if (isStart) {
            conservationStartDate = picked;
          } else {
            conservationEndDate = picked;
          }
        } else {
          if (isStart) {
            recitationStartDate = picked;
          } else {
            recitationEndDate = picked;
          }
        }
      });
    }
  }

  // تنسيق التاريخ
  String _formatDate(DateTime? date) {
    if (date == null) return 'لم يتم التحديد';
    return DateFormat('yyyy-MM-dd').format(date);
  }

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
              DropdownButtonFormField<UserModel>(
                value: selectedTeacher,
                items: teachers.map((teacher) {
                  return DropdownMenuItem<UserModel>(
                    value: teacher,
                    child: Text('${teacher.first_name} ${teacher.last_name}'),
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
                ),
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
                          subtitle: Text('رقم الطالب: ${student.studentID}'),
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
                        onPressed: () async {
                          // التحقق من صحة النموذج وعدد الطلاب المحددين
                        if (_formKey.currentState!.validate()) {
                            if (selectedStudentCount < 5) {
                              setState(() {
                                _errorMessage = "يجب اختيار 5 طلاب على الأقل";
                              });
                              return;
                            }

                          // إضافة الحلقة مع البيانات
                          _halaqaModel.SchoolID = widget.user.schoolID;
                          _halaqaModel.Name = halqaNameController.text;

                            // إضافة خطة الحفظ
                            if (conservationStartDate != null &&
                                conservationEndDate != null) {
                              _halaqaModel.conservationPlanStart =
                                  _formatDate(conservationStartDate);
                              _halaqaModel.conservationPlanEnd =
                                  _formatDate(conservationEndDate);
                            }

                            // إضافة خطة التلاوة
                            if (recitationStartDate != null &&
                                recitationEndDate != null) {
                              _halaqaModel.recitationPlanStart =
                                  _formatDate(recitationStartDate);
                              _halaqaModel.recitationPlanEnd =
                                  _formatDate(recitationEndDate);
                            }

                            // إضافة العلوم الشرعية
                            if (islamicStudiesSubjectController
                                .text.isNotEmpty) {
                              _halaqaModel.islamicStudiesSubject =
                                  islamicStudiesSubjectController.text;
                              _halaqaModel.islamicStudiesContent =
                                  islamicStudiesContentController.text;
                            }

                            try {
                              // إضافة الحلقة
                              await halagaController.addHalaga(_halaqaModel);

                              // الحصول على قائمة معرفات الطلاب المحددين
                              List<int> selectedStudentIds = [];
                              selectedStudents.forEach((studentId, isSelected) {
                                if (isSelected) {
                                  selectedStudentIds.add(studentId);
                                }
                              });

                              // إضافة الطلاب للحلقة
                              await studentController.assignStudentsToHalaga(
                                  selectedStudentIds, _halaqaModel.halagaID!);

                              // إضافة المعلم للحلقة (إذا تم اختياره)
                              if (selectedTeacher != null) {
                                await halagaController.updateHalaga(
                                    _halaqaModel, selectedTeacher!.user_id);
                              }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم إضافة الحلقة بنجاح'),
                            ),
                          );
                          Navigator.pop(context);
                            } catch (e) {
                              setState(() {
                                _errorMessage =
                                    "حدث خطأ أثناء إضافة الحلقة: $e";
                              });
                            }
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
