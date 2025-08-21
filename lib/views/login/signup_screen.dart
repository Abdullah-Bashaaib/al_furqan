import 'package:al_furqan/controllers/school_controller.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/users_model.dart';
import '../Supervisor/add_school.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
  bool _isPasswordVisible = false;
  String? _selectedRole;
  int? _selectedSchoolId;
  List<DropdownMenuItem<int>> _schoolItems = [];

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  Future<void> _loadSchools() async {
    await schoolController.getData();
    setState(() {
      _schoolItems = schoolController.schools
          .map((school) => DropdownMenuItem<int>(
                value: school.schoolID,
                child: Text(school.school_name!),
              ))
          .toList();
      if (_schoolItems.isNotEmpty &&
          !_schoolItems.any((item) => item.value == _selectedSchoolId)) {
        _selectedSchoolId = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إنشاء حساب جديد'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                _buildTextFormField(
                  controller: _firstname,
                  labelText: 'الاسم الأول',
                  validatorText: 'الرجاء إدخال الاسم الأول',
                ),
                SizedBox(height: 10),
                _buildTextFormField(
                  controller: _fathername,
                  labelText: 'اسم الأب',
                  validatorText: 'الرجاء إدخال اسم الأب',
                ),
                SizedBox(height: 10),
                _buildTextFormField(
                  controller: _grandfathername,
                  labelText: 'اسم الجد',
                  validatorText: 'الرجاء إدخال اسم الجد',
                ),
                SizedBox(height: 10),
                _buildTextFormField(
                  controller: _lastname,
                  labelText: 'القبيلة',
                  validatorText: 'الرجاء إدخال القبيلة',
                ),
                SizedBox(height: 10),
                _buildPhoneFormField(
                    controller: _phone,
                    labelText: 'رقم الجوال',
                    validatorText: 'الرجاء إدخال رقم الجوال',
                    lengthValidatorText: 'رقم الجوال يجب أن يكون 9 أرقام',
                    maxLength: 9),
                SizedBox(height: 10),
                _buildPhoneFormField(
                    controller: _telephone,
                    labelText: 'رقم البيت',
                    validatorText: 'الرجاء إدخال رقم البيت',
                    maxLength: 6),
                SizedBox(height: 10),
                _buildEmailFormField(),
                SizedBox(height: 10),
                _buildPasswordFormField(),
                SizedBox(height: 10),
                _buildDateFormField(),
                SizedBox(height: 10),
                _buildDropdownFormField<int>(
                  value: _selectedSchoolId,
                  labelText: 'اختر المدرسة',
                  items: _schoolItems,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSchoolId = newValue;
                    });
                  },
                ),
                SizedBox(height: 10),
                _buildDropdownFormField<String>(
                  value: _selectedRole,
                  labelText: 'اختر الدور',
                  items: <String>['مدير', 'معلم'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  },
                  validatorText: 'الرجاء اختيار الدور',
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text('إنشاء حساب'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String validatorText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.name,
      maxLength: 20,
      inputFormatters: [
        FilteringTextInputFormatter.deny(
            RegExp(r'[0-9@._\-!#\$%^&*(),?":{}|<>]'))
      ],
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorText;
        }
        return null;
      },
    );
  }

  Widget _buildPhoneFormField({
    required TextEditingController controller,
    required String labelText,
    required String validatorText,
    String? lengthValidatorText,
    required int maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      maxLength: 9,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorText;
        }
        if (lengthValidatorText != null && value.length < 9) {
          return lengthValidatorText;
        }
        return null;
      },
    );
  }

  Widget _buildEmailFormField() {
    return TextFormField(
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      maxLength: 50,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(r'[a-zA-Z0-9@._\-]'),
        )
      ],
      decoration: InputDecoration(
        labelText: 'البريد الإلكتروني',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final emailRegex = RegExp(r'^[a-zA-Z0-9@._\-]+@[gmail]+\.[com]');
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال بريد إلكتروني';
        } else if (!emailRegex.hasMatch(value)) {
          return 'البريد الإلكتروني غير صالح';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordFormField() {
    return TextFormField(
      controller: _password,
      obscureText: !_isPasswordVisible,
      maxLength: 8,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        border: OutlineInputBorder(),
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
          return 'كلمة المرور يجب أن تكون 8 أرقام أو أكثر';
        }
        return null;
      },
    );
  }

  Widget _buildDateFormField() {
    return TextFormField(
      controller: _date,
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

  Widget _buildDropdownFormField<T>({
    required T? value,
    required String labelText,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? validatorText,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      items: items,
      onChanged: onChanged,
      validator: (value) {
        if (validatorText != null && value == null) {
          return validatorText;
        }
        return null;
      },
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      int phone = int.parse(_phone.text);
      int telephone = int.parse(_telephone.text);
      String password = (_password.text);
      int? roleID;

      _userModel.first_name = _firstname.text;
      _userModel.middle_name = _fathername.text;
      _userModel.grandfather_name = _grandfathername.text;
      _userModel.last_name = _lastname.text;
      _userModel.phone_number = phone;
      _userModel.telephone_number = telephone;
      _userModel.email = _email.text;
      _userModel.password = password.toString();
      _userModel.date = _date.text;
      _userModel.schoolID = _selectedSchoolId;
      _userModel.isActivate = 0;
      switch (_selectedRole) {
        case "مشرف":
          roleID = 0;
          break;
        case "مدير":
          roleID = 1;
          break;
        case "معلم":
          roleID = 2;
          break;
      }
      _userModel.roleID = roleID;
      debugPrint("_selectedSchoolId = $_selectedSchoolId");
      userController.addRequest(_userModel);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("تم إرسال طلب التسجيل بنجاح"),
        ),
      );
      setState(() {});
      Navigator.of(context).pop();
    }
  }
}
