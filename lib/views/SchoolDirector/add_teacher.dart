import 'package:al_furqan/controllers/TeacherController.dart';
import 'package:al_furqan/helper/user_helper.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddTeacher extends StatefulWidget {
  const AddTeacher({super.key});

  @override
  State<AddTeacher> createState() => _AddTeacherState();
}

class _AddTeacherState extends State<AddTeacher> with UserDataMixin {
  final UserModel _userModel = UserModel();
  final _formKey = GlobalKey<FormState>();
  final _firstname = TextEditingController();
  final _fathername = TextEditingController();
  final _grandfathername = TextEditingController();
  final _lastname = TextEditingController();
  final _phone = TextEditingController();
  final _telephone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _date = TextEditingController();
  bool _isActivate = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
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
        title: Text('إضافة معلم جديد'),
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
                        RegExp(r'^[a-zA-Z0-9@._\-]+@[gmail]+\.[com]');
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
      obscureText: !_isPasswordVisible,
      textInputAction: TextInputAction.next,
      maxLength: 8,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
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
        } else if (value.length < 8) {
          return 'كلمة المرور يجب أن تكون 8 أرقام';
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
      subtitle: Text(
        _isActivate
            ? 'سيتم تفعيل حساب المعلم مباشرة'
            : 'سيتم إضافة المعلم إلى قائمة طلبات تفعيل الحساب',
        style: TextStyle(
          fontSize: 12,
          color: _isActivate ? Colors.green : Colors.orange,
        ),
      ),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_isActivate ? Icons.verified_user : Icons.pending_actions),
            SizedBox(width: 10),
            Text(
              _isActivate
                  ? 'إضافة معلم وتفعيل حسابه'
                  : 'إضافة معلم لطلبات التفعيل',
              style: TextStyle(fontSize: 18),
            ),
          ],
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
      String elhagah = 'null';

      _userModel.first_name = _firstname.text;
      _userModel.middle_name = _fathername.text;
      _userModel.grandfather_name = _grandfathername.text;
      _userModel.last_name = _lastname.text;
      _userModel.phone_number = phone;
      _userModel.telephone_number = telephone;
      _userModel.email = _email.text;
      _userModel.password = password.toString();
      _userModel.date = _date.text;
      _userModel.isActivate = activate;
      _userModel.schoolID = schoolID;
      _userModel.elhalagatID = elhagah;

      await teacherController.addTeacher(_userModel);

      // تحديد نص الرسالة بناءً على حالة التفعيل
      String successMessage = _isActivate
          ? 'تمت إضافة المعلم بنجاح وتفعيل حسابه'
          : 'تمت إضافة المعلم بنجاح وإضافته إلى قائمة طلبات تفعيل الحساب';

      // إظهار حوار نجاح بدلاً من Snackbar
      debugPrint("تمت العملية بنجاح");
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('تمت العملية بنجاح'),
            content: Text(successMessage),
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
    } catch (error) {
      // إظهار حوار خطأ
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('خطأ'),
            content: Text("حدث خطأ أثناء إضافة المعلم: $error"),
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
    }
  }
}
