import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/fathers_controller.dart';
import 'package:al_furqan/helper/new_id2.dart';
import 'package:al_furqan/models/provider/student_provider.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/SchoolDirector/studentListPage.dart';
// import 'package:al_furqan/views/SchoolDirector/handling_excel_file.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/excel_testing.dart';
import '../../controllers/users_controller.dart';

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
  bool _isLoading = false;
  bool _isStudentFormExpanded = true;
  bool _isFatherFormExpanded = true;

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      // إظهار رسالة للمستخدم بوجود حقول مطلوبة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء ملء جميع الحقول المطلوبة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // بدء التحميل
    });

    int? SchoolID = widget.user!.schoolID;
    debugPrint("معرف المدرسة للطالب الجديد: $SchoolID");

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
    fatherModel.password = '12345678'; //defualt Just for fathers
    fatherModel.roleID = 3; // 3 means fathers in display later
    fatherModel.schoolID = widget.user!.schoolID;
    debugPrint("معرف المدرسة لولي الأمر: ${fatherModel.schoolID}");
    fatherModel.isActivate = 0; // not actinates
    // fatherModel.isSync = 1;

    try {
      // أولاً: إضافة ولي الأمر
      // fatherModel.isSync = 0;
      fatherModel.user_id = await fathersController.addFather(fatherModel, 1);
      debugPrint("تم إضافة ولي الأمر بمعرف: ${fatherModel.user_id}");

      // ثانيًا: ربط الطالب بولي الأمر
      studentModel.userID = fatherModel.user_id;
      //  ثالثًا: إضافة الطالب إلى قاعدة البيانات المحلية والسحابية
      // int studentID =getMaxValue();
      // (context).read<StudentProvider>().students.add(value);
      Provider.of<StudentProvider>(context, listen: false)
          .students
          .add(studentModel);
      String? studentID = await studentController.addStudent(studentModel, 1);
      debugPrint("تم إضافة الطالب محليًا بمعرف: $studentID");

      // رابعًا: تحديث معرف الطالب في النموذج
      studentModel.studentID = studentID;

      // خامسًا: إضافة الطالب إلى Firebase
      // التحقق من وجود اتصال بالإنترنت باستخدام المكتبة الجديدة
      // bool hasConnection =
      //     await InternetConnectionChecker.createInstance().hasConnection;
      // debugPrint("حالة الاتصال بالإنترنت: $hasConnection");

      // if (!hasConnection) {
      //   if (mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text(
      //             'تم إضافة الطالب محلياً، لكن لا يمكن مزامنته مع Firebase بسبب عدم وجود اتصال بالإنترنت'),
      //         backgroundColor: Colors.orange,
      //         duration: Duration(seconds: 5),
      //         action: SnackBarAction(
      //           label: 'فهمت',
      //           textColor: Colors.white,
      //           onPressed: () async {
      //             // await studentController.addStudent(studentData);
      //           },
      //         ),
      //       ),
      //     );
      //   }
      //   // نتابع مع إظهار رسالة النجاح دون توقف عند هذه النقطة
      // } else {
      //   // لدينا اتصال بالإنترنت، نحاول إضافة الطالب إلى Firebase
      //   if (SchoolID != null) {
      //     try {
      //       await studentController.addStudentToFirebase(
      //           studentModel, SchoolID);
      //       debugPrint("تم إضافة الطالب إلى Firebase");
      //       // أيضاً: إضافة ولي الأمر إلى Firebase
      //       fatherModel.isSync = 1;
      //
      //       await userController.addFatherToFirebase(fatherModel, SchoolID);
      //       debugPrint("تم إضافة ولي الأمر إلى Firebase");
      //     } catch (firebaseError) {
      //       debugPrint("خطأ في إضافة الطالب إلى Firebase: $firebaseError");
      //       if (mounted) {
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           SnackBar(
      //             content: Text(
      //                 'تم إضافة الطالب محلياً، لكن حدث خطأ أثناء المزامنة مع Firebase'),
      //             backgroundColor: Colors.orange,
      //             duration: Duration(seconds: 3),
      //           ),
      //         );
      //       }
      //     }
      //   } else {
      //     debugPrint("تحذير: معرف المدرسة غير متوفر، لم يتم الإضافة إلى Firebase");
      //   }
      // }

      // إظهار رسالة النجاح النهائية
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('تمت إضافة الطالب بنجاح'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("حدث خطأ أثناء إضافة الطالب: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text('فشل في إضافة الطالب: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // إنهاء التحميل بغض النظر عن النتيجة
        });
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    firstNameController.dispose();
    middleNameController.dispose();
    grandfatherNameController.dispose();
    lastNameController.dispose();
    grandFatherNameForFatherStudent.dispose();
    gmailOfFatherStudent.dispose();
    passwordFatherStudent.dispose();
    phoneFatherStudent.dispose();
    telephoneFatherStudent.dispose();
    _dateFatherStudent.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('إضافة طالب', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('جاري إضافة الطالب...',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : SingleChildScrollView(
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
                          side:
                              BorderSide(color: Colors.blue.shade100, width: 1),
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
                              trailing: IconButton(
                                icon: Icon(
                                  _isStudentFormExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isStudentFormExpanded =
                                        !_isStudentFormExpanded;
                                  });
                                },
                              ),
                            ),
                            if (_isStudentFormExpanded)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTextField(firstNameController,
                                        'الاسم الأول', Icons.person),
                                    _buildTextField(middleNameController,
                                        'الاسم الأوسط', Icons.person),
                                    _buildTextField(grandfatherNameController,
                                        'اسم الجد', Icons.person),
                                    _buildTextField(lastNameController,
                                        'اسم العائلة', Icons.family_restroom),
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
                          side:
                              BorderSide(color: Colors.teal.shade100, width: 1),
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
                              trailing: IconButton(
                                icon: Icon(
                                  _isFatherFormExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.teal.shade700,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isFatherFormExpanded =
                                        !_isFatherFormExpanded;
                                  });
                                },
                              ),
                            ),
                            if (_isFatherFormExpanded)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTextField(middleNameController,
                                        "اسم ولى الأمر", Icons.person),
                                    _buildTextField(
                                        grandfatherNameController,
                                        "الاسم الأوسط لولي الأمر",
                                        Icons.person),
                                    _buildTextField(
                                        grandFatherNameForFatherStudent,
                                        "اسم جد ولي الأمر",
                                        Icons.person),
                                    _buildTextField(lastNameController,
                                        "القبيلة", Icons.family_restroom),
                                    _buildTextFieldData(),
                                    _buildTextField(gmailOfFatherStudent,
                                        "البريد الالكتروني", Icons.email),
                                    _builtTextFieldNumber("رقم الجوال",
                                        phoneFatherStudent, 9, Icons.phone),
                                    _builtTextFieldNumber(
                                        "رقم البيت",
                                        telephoneFatherStudent,
                                        6,
                                        Icons.phone_in_talk),
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
                              onPressed: _isLoading ? null : _submitForm,
                              icon: Icon(Icons.add_circle, color: Colors.white),
                              label: Text(
                                'إضافة الطالب',
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
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      late BuildContext dialogContext;
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext ctx) {
                                          dialogContext = ctx;
                                          return PopScope<void>(
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
                                        // 2. استدعي القراءة والإضافة
                                        await ExcelTesting(
                                                schoolID: widget.user?.schoolID)
                                            .readExcelFile(context)
                                            .then((_) =>
                                                Navigator.of(dialogContext)
                                                    .pop());
                                      } catch (e) {
                                        // 4. إعلام بالخطأ
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'خطأ في قراءة ملف الإكسل: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      } finally {
                                        // 5. أغلق الديالوج باستخدام نفس الـ dialogContext
                                        Navigator.of(dialogContext).pop();
                                      }
                                    },
                              icon:
                                  Icon(Icons.file_upload, color: Colors.white),
                              label: Text(
                                'جلب ملف إكسل',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal.shade700,
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

  Padding _buildTextFieldData() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        textInputAction: TextInputAction.next,
        controller: _dateFatherStudent,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'تاريخ الميلاد',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: Icon(Icons.calendar_today),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          hintText: 'اختر تاريخ الميلاد',
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: child!,
              );
            },
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

  Widget _buildTextField(
      TextEditingController controller, String label, IconData? icon) {
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
}
