// ignore: file_names
// ignore_for_file: library_private_types_in_public_api
import 'dart:developer';

import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/fathers_controller.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/users_model.dart';

class EditStudentScreen extends StatefulWidget {
  // final UserModel? user;
  final StudentModel student; // استلام بيانات الطالب لتعديلها
  final UserModel father;

  const EditStudentScreen(
      {super.key, required this.student, required this.father});

  @override
  _EditStudentScreenState createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final grandfatherNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final grandFatherNameForFatherStudent = TextEditingController();
  final gmailOfFatherStudent = TextEditingController();
  final passwordFatherStudent = TextEditingController();
  final phoneFatherStudent = TextEditingController();
  final telephoneFatherStudent = TextEditingController();
  final dateFatherStudent = TextEditingController();
  var father = fathersController.fatherByID;

  // final studentModel = StudentModel();

  @override
  void initState() {
    super.initState();
    _fetchFatherStudent();
    // تعبئة الحقول بالبيانات الحالية للطالب
    // initTextContoller();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    telephoneFatherStudent.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    grandfatherNameController.dispose();
    dateFatherStudent.dispose();
    lastNameController.dispose();
    grandFatherNameForFatherStudent.dispose();
    gmailOfFatherStudent.dispose();
    passwordFatherStudent.dispose();
    phoneFatherStudent.dispose();
    super.dispose();
  }

  void initTextContoller() async {
    // تعبئة الحقول بالبيانات الحالية للطالب
    log("-------> this's initTextColtoller method");
    debugPrint(
        "----------> Student ID in initTextColtoller method : ${father.first_name}");
    firstNameController.text = widget.student.firstName ?? '';
    middleNameController.text = widget.student.middleName ?? '';
    grandfatherNameController.text = widget.student.grandfatherName ?? '';
    grandFatherNameForFatherStudent.text = father.grandfather_name ?? '';
    lastNameController.text = widget.student.lastName ?? '';
    dateFatherStudent.text = father.date ?? '';
    gmailOfFatherStudent.text = father.email ?? '';
    phoneFatherStudent.text = father.phone_number.toString();
    telephoneFatherStudent.text = father.telephone_number.toString();
  }

  Future<void> _fetchFatherStudent() async {
    await fathersController.getFathersStudentsByStudentID(
        widget.student.schoolId!, widget.student.studentID!);
    initTextContoller();
  }

  Future<void> _refreshData() async {
    List<StudentModel>? loadedStudent =
        await studentController.getSchoolStudents(widget.student.schoolId!);
    debugPrint("Hi this's refreshing data");
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );
      // التحقق من صحة النموذج
      widget.student.firstName = firstNameController.text;
      widget.student.middleName = middleNameController.text;
      widget.student.grandfatherName = grandfatherNameController.text;
      widget.student.lastName = lastNameController.text;
      father.first_name = middleNameController.text;
      father.middle_name = grandfatherNameController.text;
      father.grandfather_name = grandFatherNameForFatherStudent.text;
      father.last_name = lastNameController.text;
      father.phone_number = int.parse(phoneFatherStudent.text);
      father.telephone_number = int.parse(telephoneFatherStudent.text);
      father.email = gmailOfFatherStudent.text;
      father.date = dateFatherStudent.text;
      widget.student.userID = father.user_id;
      log("---------> Update Student in SupmitForm [Father ID is : ${widget.student.userID}]");
      await studentController.updateStudent(
          widget.student, 1); // استخدام الدالة لتحديث بيانات الطالب
      await userController.updateUser(father, 1).then((_) async {
        // تحميل البيانات من القاعدة المحلية

        // إذا لم يكن هناك اتصال بالإنترنت، يتم تحميل البيانات من القاعدة المحلية فقط
        await _refreshData();
        if (!mounted) return;
        Navigator.pop(context); // العودة إلى الصفحة السابقة
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else {
      debugPrint("Form validation failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تعديل بيانات الطالب',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // قسم بيانات الطالب
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.blue.shade100, width: 1),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          "بيانات الطالب",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(firstNameController, 'الاسم الأول',
                                Icons.person),
                            _buildTextField(middleNameController,
                                'الاسم الأوسط', Icons.person),
                            _buildTextField(grandfatherNameController,
                                'اسم الجد', Icons.person),
                            _buildTextField(lastNameController, 'اسم العائلة',
                                Icons.family_restroom),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // قسم بيانات ولي الأمر
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.teal.shade100, width: 1),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          "بيانات ولي الأمر",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(middleNameController,
                                "اسم ولى الأمر", Icons.person),
                            _buildTextField(grandfatherNameController,
                                "الاسم الاوسط لولي الامر", Icons.person),
                            _buildTextField(grandFatherNameForFatherStudent,
                                "اسم جد ولي الامر", Icons.person),
                            _buildTextField(lastNameController, "القبيلة",
                                Icons.family_restroom),
                            _buildTextFieldData(),
                            _buildTextField(gmailOfFatherStudent,
                                "البريد الالكتروني", Icons.email),
                            _builtTextFieldNumber("رقم الجوال",
                                phoneFatherStudent, 9, Icons.phone),
                            _builtTextFieldNumber("رقم البيت",
                                telephoneFatherStudent, 6, Icons.phone_in_talk),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                // أزرار العمليات
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: Icon(Icons.save, color: Colors.white),
                        label: Text(
                          'تعديل',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // العودة بدون حفظ التعديلات
                        },
                        icon: Icon(Icons.cancel, color: Colors.white),
                        label: Text(
                          'إلغاء',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 3,
                        ),
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

  Container dataOfFatherStudent() {
    return Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  "بيانات ولي الامر",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              _buildTextField(middleNameController, "اسم ولى الامر"),
              _buildTextField(
                  grandfatherNameController, "الاسم الاوسط لولي الامر"),
              _buildTextField(
                  grandFatherNameForFatherStudent, "اسم جد ولي الامر"),
              _buildTextField(lastNameController, "القبيلة"),
              _buildTextFieldData(),
              _buildTextField(gmailOfFatherStudent, "البريد الالكتروني"),
              _builtTextFieldNumber(
                  "رقم الجوال", phoneFatherStudent, 9, Icons.phone_android),
              _builtTextFieldNumber(
                  "رقم البيت", telephoneFatherStudent, 6, Icons.phone),
            ],
          ),
        ));
  }

  Padding _buildTextFieldData() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        textInputAction: TextInputAction.next,
        controller: dateFatherStudent,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'تاريخ الميلاد',
          border: OutlineInputBorder(),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1700),
            lastDate: DateTime(2300),
          );
          if (pickedDate != null) {
            String formattedDate = DateFormat.yMMMd().format(pickedDate);
            setState(() {
              dateFatherStudent.text = formattedDate;
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال تاريخ الميلاد';
          }
          return null;
        },
      ),
    );
  }

  Widget _builtTextFieldNumber(String label, TextEditingController controller,
      int maxLength, IconData? icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        maxLength: maxLength,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال $label';
          }
          return null;
        },
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          counterText: "",
          hintText: 'أدخل $label',
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      [IconData? icon]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'[0-9٠-٩]'))
        ],
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال $label';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          hintText: 'أدخل $label',
        ),
      ),
    );
  }
}
