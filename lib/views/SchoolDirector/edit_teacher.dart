import 'package:al_furqan/controllers/TeacherController.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/user_helper.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EditTeacher extends StatefulWidget {
  final UserModel teacher;

  const EditTeacher({super.key, required this.teacher});

  @override
  State<EditTeacher> createState() => _EditTeacherState();
}

class _EditTeacherState extends State<EditTeacher> with UserDataMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstname;
  late TextEditingController _fathername;
  late TextEditingController _grandfathername;
  late TextEditingController _lastname;
  late TextEditingController _phone;
  late TextEditingController _telephone;
  late TextEditingController _email;
  late TextEditingController _password;
  late TextEditingController _date;
  late bool _isActivate;
  bool _isPasswordVisible = false;
  // bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _initializeControllers();
  }

  void _initializeControllers() {
    _firstname = TextEditingController(text: widget.teacher.first_name);
    _fathername = TextEditingController(text: widget.teacher.middle_name);
    _grandfathername =
        TextEditingController(text: widget.teacher.grandfather_name);
    _lastname = TextEditingController(text: widget.teacher.last_name);
    _phone = TextEditingController(
        text: widget.teacher.phone_number?.toString() ?? '');
    _telephone = TextEditingController(
        text: widget.teacher.telephone_number?.toString() ?? '');
    _email = TextEditingController(text: widget.teacher.email);
    _password =
        TextEditingController(text: widget.teacher.password?.toString() ?? '');
    _date = TextEditingController(text: widget.teacher.date);
    _isActivate = widget.teacher.isActivate == 1;
  }

  @override
  void dispose() {
    _firstname.dispose();
    _fathername.dispose();
    _grandfathername.dispose();
    _lastname.dispose();
    _phone.dispose();
    _telephone.dispose();
    _email.dispose();
    _password.dispose();
    _date.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل بيانات المعلم'),
        backgroundColor: const Color.fromARGB(255, 1, 117, 70),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTextFormField(
                  controller: _firstname,
                  label: 'الاسم الأول',
                  maxLength: 20,
                  inputType: TextInputType.name,
                  validatorMsg: 'الرجاء إدخال الاسم الأول',
                ),
                SizedBox(height: 16),
                _buildTextFormField(
                  controller: _fathername,
                  label: 'اسم الأب',
                  maxLength: 20,
                  inputType: TextInputType.name,
                  validatorMsg: 'الرجاء إدخال اسم الأب',
                ),
                SizedBox(height: 16),
                _buildTextFormField(
                  controller: _grandfathername,
                  label: 'اسم الجد',
                  maxLength: 20,
                  inputType: TextInputType.name,
                  validatorMsg: 'الرجاء إدخال اسم الجد',
                ),
                SizedBox(height: 16),
                _buildTextFormField(
                  controller: _lastname,
                  label: 'القبيلة',
                  maxLength: 20,
                  inputType: TextInputType.name,
                  validatorMsg: 'الرجاء إدخال القبيلة',
                ),
                SizedBox(height: 16),
                _buildNumberFormField(
                  controller: _phone,
                  label: 'رقم الجوال',
                  maxLength: 9,
                  inputType: TextInputType.phone,
                  validatorMsg: 'الرجاء إدخال رقم الجوال',
                  additionalValidator: (value) {
                    if (value!.length < 9) {
                      return 'رقم الجوال يجب أن يكون 9 أرقام';
                    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'ادخل ارقاماً';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildNumberFormField(
                  controller: _telephone,
                  label: 'رقم البيت',
                  maxLength: 6,
                  inputType: TextInputType.phone,
                  validatorMsg: 'الرجاء إدخال رقم البيت',
                  additionalValidator: (value) {
                    if (value!.length < 6) {
                      return 'رقم البيت يجب أن يكون 6 أرقام';
                    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'ادخل ارقاماً';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextFormField(
                  controller: _email,
                  label: 'البريد الإلكتروني',
                  maxLength: 50,
                  inputType: TextInputType.emailAddress,
                  validatorMsg: 'الرجاء إدخال بريد إلكتروني',
                  additionalValidator: (value) {
                    final emailRegex =
                        RegExp(r'^[a-zA-Z@._\-]+@[gmail]+\.[com]');
                    if (!emailRegex.hasMatch(value!)) {
                      return 'البريد الإلكتروني غير صالح';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildPasswordFormField(),
                SizedBox(height: 16),
                _buildDateFormField(),
                SizedBox(height: 16),
                _buildActivateSwitch(),
                SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required int maxLength,
    required TextInputType inputType,
    required String validatorMsg,
    String? Function(String?)? additionalValidator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLength: maxLength,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'[0-9_\-!#\$%^&*(),?":{}|<>]'))
      ],
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: const Color.fromARGB(255, 1, 117, 70),
            width: 2,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMsg;
        }
        if (additionalValidator != null) {
          return additionalValidator(value);
        }
        return null;
      },
    );
  }

  TextFormField _buildNumberFormField({
    required TextEditingController controller,
    required String label,
    required int maxLength,
    required TextInputType inputType,
    required String validatorMsg,
    String? Function(String?)? additionalValidator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLength: maxLength,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.deny(
            RegExp(r'[ا-يa-zA-Z@._\-!#\$%^&*(),?":{}|<>]'))
      ],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: const Color.fromARGB(255, 1, 117, 70),
            width: 2,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMsg;
        }
        if (additionalValidator != null) {
          return additionalValidator(value);
        }
        return null;
      },
    );
  }

  TextFormField _buildPasswordFormField() {
    return TextFormField(
      controller: _password,
      keyboardType: TextInputType.number,
      obscureText: !_isPasswordVisible,
      maxLength: 8,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.deny(
            RegExp(r'[ا-يa-zA-Z@._\-!#\$%^&*(),?":{}|<>]'))
      ],
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: const Color.fromARGB(255, 1, 117, 70),
            width: 2,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال كلمة المرور';
        }
        if (value.length < 6) {
          return 'كلمة المرور يجب أن تكون 6 أرقام على الأقل';
        }
        return null;
      },
    );
  }

  TextFormField _buildDateFormField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      controller: _date,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'تاريخ الميلاد',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: const Color.fromARGB(255, 1, 117, 70),
            width: 2,
          ),
        ),
        suffixIcon: Icon(Icons.calendar_today),
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
            _date.text = formattedDate;
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال تاريخ الميلاد';
        }
        return null;
      },
    );
  }

  SwitchListTile _buildActivateSwitch() {
    return SwitchListTile(
      title: Text('تفعيل المعلم'),
      value: _isActivate,
      activeColor: const Color.fromARGB(255, 1, 117, 70),
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      onChanged: (bool value) {
        setState(() {
          _isActivate = value;
        });
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _submitForm();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 1, 117, 70),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'حفظ التعديلات',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    try {
      if (schoolID == null) {
        throw Exception("لم يتم العثور على معرف المدرسة الخاص بك");
      }

      int phone = int.parse(_phone.text);
      int telephone = int.parse(_telephone.text);
      String password = (_password.text);
      int activate = _isActivate ? 1 : 0;

      // Update the teacher model with new values
      UserModel updatedTeacher = UserModel(
        user_id: widget.teacher.user_id,
        first_name: _firstname.text,
        middle_name: _fathername.text,
        grandfather_name: _grandfathername.text,
        last_name: _lastname.text,
        phone_number: phone,
        telephone_number: telephone,
        email: _email.text,
        password: password.toString(),
        date: _date.text,
        isActivate: activate,
        roleID: 2, // Teacher role ID is 2
        schoolID: schoolID,
        elhalagatID: widget.teacher.elhalagatID,
        activityID: widget.teacher.activityID,
      );

      // Update teacher in database
      await userController.updateUser(updatedTeacher, 1);

      // Refresh teacher list
      if (schoolID != null) {
        await teacherController.getTeachersBySchoolID(schoolID!);
      }

      // إظهار حوار نجاح بدلاً من Snackbar
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('تمت العملية بنجاح'),
            content: const Text('تم تحديث بيانات المعلم بنجاح'),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            icon: const Icon(
              Icons.check_circle,
              color: Color.fromARGB(255, 1, 117, 70),
              size: 50,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // إغلاق مربع الحوار
                  Navigator.of(context)
                      .pop(true); // الرجوع إلى الشاشة السابقة مع نتيجة نجاح
                },
                child: const Text(
                  'موافق',
                  style: TextStyle(
                    color: Color.fromARGB(255, 1, 117, 70),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint("Error updating teacher: $e");

      // إظهار حوار خطأ
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('خطأ'),
            content: Text("حدث خطأ أثناء تحديث بيانات المعلم: $e"),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            icon: const Icon(
              Icons.error,
              color: Colors.red,
              size: 50,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'حسناً',
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
    } finally {
      // لا داعي لإعادة تعيين _isLoading هنا لأننا سنعود إلى الشاشة السابقة في حالة النجاح
    }
  }
}
