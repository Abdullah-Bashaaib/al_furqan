import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/fathers_controller.dart';
import 'package:al_furqan/models/users_model.dart';

// import 'package:al_furqan/views/SchoolDirector/handling_excel_file.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import '../../controllers/excel_testing.dart';

class AddStudentScreen extends StatefulWidget {
  final UserModel? user;
  const AddStudentScreen({super.key, required this.user});

  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
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
  final _dateFatherStudent = TextEditingController();

  final studentModel = StudentModel();
  final fatherModel = UserModel();
  final _connectivity = Connectivity().checkConnectivity();

  void _submitForm() async {
    int? SchoolID = widget.user!.schoolID;
    print("معرف المدرسة للطالب الجديد: $SchoolID");

    if (_formKey.currentState!.validate()) {
      // بيانات الطالب
      studentModel.firstName = firstNameController.text;
      studentModel.middleName = middleNameController.text;
      studentModel.grandfatherName = grandfatherNameController.text;
      studentModel.lastName = lastNameController.text;
      studentModel.schoolId = SchoolID; // تأكد من تعيين معرف المدرسة للطالب

      // بيانات ولي الامر
      fatherModel.schoolID = widget.user!.schoolID;
      fatherModel.first_name = middleNameController.text;
      fatherModel.middle_name = grandfatherNameController.text;
      fatherModel.grandfather_name = grandFatherNameForFatherStudent.text;
      fatherModel.last_name = lastNameController.text;
      fatherModel.email = gmailOfFatherStudent.text;
      fatherModel.phone_number = int.tryParse(phoneFatherStudent.text);
      fatherModel.date = _dateFatherStudent.text;
      fatherModel.telephone_number = int.tryParse(telephoneFatherStudent.text);
      fatherModel.password = 12345678; //defualt Just for fathers
      fatherModel.roleID = 3; // 3 means fathers in display later
      fatherModel.schoolID = widget.user!.schoolID;
      print("معرف المدرسة لولي الأمر: ${fatherModel.schoolID}");
      fatherModel.isActivate = 0; // not actinates

      try {
        // أولاً: إضافة ولي الأمر
        fatherModel.user_id = await fathersController.addFather(fatherModel);
        print("تم إضافة ولي الأمر بمعرف: ${fatherModel.user_id}");

        // ثانيًا: ربط الطالب بولي الأمر
        studentModel.userID = fatherModel.user_id;

        // ثالثًا: إضافة الطالب إلى قاعدة البيانات المحلية
        int studentID = await studentController.addStudent(studentModel);
        print("تم إضافة الطالب محليًا بمعرف: $studentID");

        // رابعًا: تحديث معرف الطالب في النموذج
        studentModel.studentID = studentID;

        // خامسًا: إضافة الطالب إلى Firebase
        // التحقق من وجود اتصال بالإنترنت
        var connect = await InternetConnectionChecker.createInstance().hasConnection;
        print("Connection Status : $connect");

        if (connect == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'تم إضافة الطالب محلياً، لكن لا يمكن مزامنته مع Firebase بسبب عدم وجود اتصال بالإنترنت'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
          // نتابع مع إظهار رسالة النجاح دون توقف عند هذه النقطة
        } else {
          // لدينا اتصال بالإنترنت، نحاول إضافة الطالب إلى Firebase
          if (SchoolID != null) {
            try {
              await studentController.addStudentToFirebase(
                  studentModel, SchoolID);
              print("تم إضافة الطالب إلى Firebase");
            } catch (firebaseError) {
              print("خطأ في إضافة الطالب إلى Firebase: $firebaseError");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'تم إضافة الطالب محلياً، لكن حدث خطأ أثناء المزامنة مع Firebase'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          } else {
            print("تحذير: معرف المدرسة غير متوفر، لم يتم الإضافة إلى Firebase");
          }
        }

        // إظهار رسالة النجاح النهائية
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت إضافة الطالب بنجاح'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        print("حدث خطأ أثناء إضافة الطالب: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في إضافة الطالب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final _schoolId = widget.user?.schoolID;
    return Scaffold(
      appBar: AppBar(title: Text('إضافة طالب')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(firstNameController, 'الاسم الأول'),
                _buildTextField(middleNameController, 'الاسم الأوسط'),
                _buildTextField(grandfatherNameController, 'اسم الجد'),
                _buildTextField(lastNameController, 'اسم العائلة'),
                dataOfFatherStudent(),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // await _submit2(_schoolId, context);
                          _submitForm();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: Text(
                          'إضافة',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          /// export excel file
                          await ExcelTesting(schoolID: widget.user?.schoolID)
                              .readExcelFile(context)
                              .then((_) {
                            Navigator.pop(context);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: Text(
                          'جلب ملف إكسل',
                          style: TextStyle(color: Colors.white),
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
              _builtTextFieldNumber("رقم الجوال", phoneFatherStudent, 9),
              _builtTextFieldNumber("رقم البيت", telephoneFatherStudent, 6),
            ],
          ),
        ));
  }

  Padding _buildTextFieldData() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        textInputAction: TextInputAction.next,
        controller: _dateFatherStudent,
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
              _dateFatherStudent.text = formattedDate;
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

  Widget _buildTextField(TextEditingController controller, String label) {
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
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _builtTextFieldNumber(
      String label, TextEditingController controller, int maxLength) {
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
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}
