import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/controllers/school_controller.dart';
import 'package:al_furqan/models/schools_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/Supervisor/add_school.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
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
  String? _selectedRole;
  int? _selectedSchoolId = 0;
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
                child: Text("${school.school_name!} ${school.school_location}"),
              ))
          .toList();
      _selectedSchoolId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إضافة مستخدم جديد',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        toolbarHeight: 70,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'معلومات المستخدم',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),

                  // Form card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Personal information section
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              'المعلومات الشخصية',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          Divider(height: 1, color: Colors.grey.shade300),
                          SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _firstname,
                            label: 'الاسم الأول',
                            maxLength: 20,
                            inputType: TextInputType.name,
                            validatorMsg: 'الرجاء إدخال الاسم الأول',
                          ),
                          SizedBox(height: 10),
                          _buildTextFormField(
                            controller: _fathername,
                            label: 'اسم الأب',
                            maxLength: 20,
                            inputType: TextInputType.name,
                            validatorMsg: 'الرجاء إدخال اسم الأب',
                          ),
                          SizedBox(height: 10),
                          _buildTextFormField(
                            controller: _grandfathername,
                            label: 'اسم الجد',
                            maxLength: 20,
                            inputType: TextInputType.name,
                            validatorMsg: 'الرجاء إدخال اسم الجد',
                          ),
                          SizedBox(height: 10),
                          _buildTextFormField(
                            controller: _lastname,
                            label: 'القبيلة',
                            maxLength: 20,
                            inputType: TextInputType.name,
                            validatorMsg: 'الرجاء إدخال القبيلة',
                          ),
                          SizedBox(height: 10),
                          _buildNumberFormField(
                              controller: _phone,
                              label: 'رقم الجوال',
                              maxLength: 9,
                              inputType: TextInputType.phone,
                              validatorMsg: 'الرجاء إدخال رقم الجوال',
                              additionalValidator: (value) {
                                if (value!.length < 9) {
                                  return 'رقم الجوال يجب أن يكون 9 أرقام';
                                } else if (!RegExp(r'^[0-9]+$')
                                    .hasMatch(value)) {
                                  return 'ادخل ارقاماً';
                                }
                                return null;
                              }),
                          SizedBox(height: 10),
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
                          SizedBox(height: 10),
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
                          SizedBox(height: 10),
                          _buildPasswordFormField(),
                          SizedBox(height: 10),
                          _buildDateFormField(),
                          SizedBox(height: 10),
                          _buildSchoolDropdown(),
                          SizedBox(height: 10),
                          _buildRoleDropdown(),
                          SizedBox(height: 10),
                          _buildActivateSwitch(),
                          SizedBox(height: 10),
                          _buildSubmitButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
    final primaryColor = Theme.of(context).primaryColor;

    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLength: maxLength,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'[0-9_\-!#\$%^&*(),?":{}<>]'))
      ],
      textInputAction: TextInputAction.next,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        prefixIcon: Icon(
          inputType == TextInputType.emailAddress
              ? Icons.email_outlined
              : Icons.person_outline,
          color: primaryColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    final primaryColor = Theme.of(context).primaryColor;

    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLength: maxLength,
      textInputAction: TextInputAction.next,
      style: TextStyle(fontSize: 16),
      inputFormatters: [
        FilteringTextInputFormatter.deny(
            RegExp(r'[ا-يa-zA-Z@._\-!#\$%^&*(),?":{}<>]'))
      ],
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        prefixIcon: Icon(Icons.phone_outlined, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    final primaryColor = Theme.of(context).primaryColor;

    return TextFormField(
      controller: _password,
      obscureText: !_isPasswordVisible,
      textInputAction: TextInputAction.next,
      maxLength: 8,
      style: TextStyle(fontSize: 16),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        counterText: '',
        prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey.shade600,
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

  TextFormField _buildDateFormField() {
    final primaryColor = Theme.of(context).primaryColor;

    return TextFormField(
      textInputAction: TextInputAction.next,
      controller: _date,
      readOnly: true,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: 'تاريخ الميلاد',
        prefixIcon: Icon(Icons.calendar_today, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        // Ajuste para evitar el overflow
        errorStyle: TextStyle(
          height: 0.8, // Reducir el espacio vertical del mensaje de error
          fontSize: 12,
        ),
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

  Row _buildSchoolDropdown() {
    final primaryColor = Theme.of(context).primaryColor;

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _selectedSchoolId,
            style: TextStyle(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'اختر المدرسة',
              prefixIcon: Icon(Icons.school, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              // Ajuste para evitar el overflow
              errorStyle: TextStyle(
                height: 0.8, // Reducir el espacio vertical del mensaje de error
                fontSize: 12,
              ),
            ),
            items: _schoolItems,
            onChanged: (newValue) {
              setState(() {
                _selectedSchoolId = newValue;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'الرجاء اختيار المدرسة';
              }
              return null;
            },
            // Ajuste para reducir el espacio interno del dropdown
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, size: 24),
            dropdownColor: Colors.grey.shade50,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          margin: EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            tooltip: 'إضافة مدرسة جديدة',
            onPressed: () async {
              await Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => AddSchool()));
              await _loadSchools();
            },
          ),
        ),
      ],
    );
  }

  DropdownButtonFormField<String> _buildRoleDropdown() {
    final primaryColor = Theme.of(context).primaryColor;

    return DropdownButtonFormField<String>(
      value: _selectedRole,
      style: TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        labelText: 'اختر الدور',
        prefixIcon: Icon(Icons.assignment_ind, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: <String>['مشرف', 'مدير', 'معلم'].map((String value) {
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
      validator: (value) {
        if (value == null) {
          return 'الرجاء اختيار الدور';
        }
        return null;
      },
    );
  }

  SwitchListTile _buildActivateSwitch() {
    final primaryColor = Theme.of(context).primaryColor;

    return SwitchListTile(
      title: Text('تفعيل المستخدم', style: TextStyle(fontSize: 16)),
      subtitle: Text(_isActivate ? 'المستخدم مفعل' : 'المستخدم غير مفعل',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      value: _isActivate,
      activeColor: primaryColor,
      secondary: Icon(
        _isActivate ? Icons.check_circle : Icons.cancel_outlined,
        color: _isActivate ? primaryColor : Colors.grey,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      tileColor: Colors.grey.shade50,
      onChanged: (bool value) {
        setState(() {
          _isActivate = value;
        });
      },
    );
  }

  ElevatedButton _buildSubmitButton() {
    final primaryColor = Theme.of(context).primaryColor;

    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _submitForm();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_add),
          SizedBox(width: 8),
          Text(
            'إضافة المستخدم',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    debugPrint("here save user");
    int phone = int.parse(_phone.text);
    int telephone = int.parse(_telephone.text);
    String password = (_password.text);
    int? roleID;
    int activate = _isActivate ? 1 : 0;

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
    _userModel.schoolID = _selectedSchoolId;

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
    userController.addUser(_userModel, 1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("تمت إضافة مستخدم بنجاح"),
      ),
    );
    setState(() {});
    Navigator.of(context).pop();
  }
}
