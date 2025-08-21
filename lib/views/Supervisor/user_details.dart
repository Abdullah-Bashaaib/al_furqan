import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/school_controller.dart';
import 'add_school.dart';
import '../../widgets/build_text_field.dart';
import '../../widgets/build_password_field.dart';
import '../../widgets/build_date_field.dart';
import '../../widgets/build_dropdown_field.dart';

class UserDetails extends StatefulWidget {
  final UserModel user;

  const UserDetails({super.key, required this.user});

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditable = false;

  late TextEditingController _firstname;
  late TextEditingController _fathername;
  late TextEditingController _grandfathername;
  late TextEditingController _lastname;
  late TextEditingController _phone;
  late TextEditingController _telephone;
  late TextEditingController _email;
  late TextEditingController _password;
  late TextEditingController _date;
  bool _isPasswordVisible = false;
  String? _selectedRole;
  int? _selectedSchoolId;
  List<DropdownMenuItem<int>> _schoolItems = [];

  bool _isActivate = false;

  Future<void> _loadSchools() async {
    await schoolController.getData();
    setState(() {
      _schoolItems = schoolController.schools
          .map((school) => DropdownMenuItem<int>(
                value: school.schoolID,
                child:
                    Text("${school.school_name!} - ${school.school_location}"),
              ))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _selectedRole = _getRole(widget.user.roleID!);
    _isActivate = widget.user.isActivate == 1;
    _selectedSchoolId = widget.user.schoolID;
    _refreshData();
  }

  void _initializeControllers() {
    _firstname = TextEditingController(text: widget.user.first_name);
    _fathername = TextEditingController(text: widget.user.middle_name);
    _grandfathername =
        TextEditingController(text: widget.user.grandfather_name);
    _lastname = TextEditingController(text: widget.user.last_name);
    _phone = TextEditingController(text: widget.user.phone_number.toString());
    _telephone =
        TextEditingController(text: widget.user.telephone_number.toString());
    _email = TextEditingController(text: widget.user.email);
    _password = TextEditingController(text: widget.user.password.toString());
    _date = TextEditingController(text: widget.user.date);
  }

  String _getRole(int roleId) {
    switch (roleId) {
      case 0:
        return "مشرف";
      case 1:
        return "مدير";
      case 2:
        return "معلم";
      case 3:
        return "ولي أمر";
      default:
        return "غير معروف";
    }
  }

  void _refreshData() async {
    await userController.getDataUsers();
    await _loadSchools();
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "معلومات المستخدم",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(_isEditable ? Icons.close : Icons.edit),
            tooltip: _isEditable ? 'إلغاء التعديل' : 'تعديل البيانات',
            onPressed: () {
              setState(() {
                _isEditable = !_isEditable;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Header
                // _buildUserProfileHeader(),
                // SizedBox(height: 24),

                // Section Title
                _buildSectionTitle('المعلومات الشخصية', Icons.person),
                SizedBox(height: 16),

                // Personal Information
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildTextField(
                            _firstname, 'الاسم الأول', TextInputType.text, 50),
                        SizedBox(height: 16),
                        _buildTextField(
                            _fathername, 'اسم الأب', TextInputType.text, 50),
                        SizedBox(height: 16),
                        _buildTextField(_grandfathername, 'اسم الجد',
                            TextInputType.text, 50),
                        SizedBox(height: 16),
                        _buildTextField(
                            _lastname, 'القبيلة', TextInputType.text, 50),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Section Title
                _buildSectionTitle('معلومات الاتصال', Icons.contact_phone),
                SizedBox(height: 16),

                // Contact Information
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildTextField(
                            _phone, 'رقم الجوال', TextInputType.phone, 9),
                        SizedBox(height: 16),
                        _buildTextField(
                            _telephone, 'رقم البيت', TextInputType.phone, 6),
                        SizedBox(height: 16),
                        _buildTextField(_email, 'البريد الإلكتروني',
                            TextInputType.emailAddress, 50),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Section Title
                _buildSectionTitle('معلومات الحساب', Icons.security),
                SizedBox(height: 16),

                // Account Information
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        buildPasswordField(
                          controller: _password,
                          isPasswordVisible: _isPasswordVisible,
                          isEditable: _isEditable,
                          togglePasswordVisibility: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        buildDateField(
                          controller: _date,
                          isEditable: _isEditable,
                          context: context,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Section Title
                _buildSectionTitle('معلومات المدرسة والدور', Icons.school),
                SizedBox(height: 16),

                // School and Role Information
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildSchoolDropdown(),
                        SizedBox(height: 16),
                        buildDropdownField(
                          selectedRole: _selectedRole,
                          isEditable: _isEditable,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedRole = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Activation Switch
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildCustomSwitchListTile(),
                  ),
                ),
                SizedBox(height: 24),

                // Save Button (only shown in edit mode)
                if (_isEditable)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _handleFormSubmission();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save),
                          SizedBox(width: 8),
                          Text(
                            'حفظ التعديلات',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      TextInputType keyboardType, int maxLength) {
    return buildTextField(
      controller: controller,
      label: label,
      readOnly: !_isEditable,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال $label';
        }
        if (keyboardType == TextInputType.phone && value.length < maxLength) {
          return '$label يجب أن يكون $maxLength أرقام';
        }
        if (keyboardType == TextInputType.emailAddress) {
          final emailRegex = RegExp(r'^[a-zA-Z0-9@._\-]+@[gmail]+\.[com]');
          if (!emailRegex.hasMatch(value)) {
            return 'البريد الإلكتروني غير صالح';
          }
        }
        return null;
      },
    );
  }

  Widget _buildSchoolDropdown() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _selectedSchoolId,
            decoration: InputDecoration(
              labelText: 'اختر المدرسة',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: _schoolItems,
            onChanged: _isEditable
                ? (newValue) {
                    setState(() {
                      _selectedSchoolId = newValue;
                    });
                  }
                : null,
          ),
        ),
        IconButton(
          icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
          tooltip: 'إضافة مدرسة جديدة',
          onPressed: () async {
            await Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AddSchool()));
            await _loadSchools(); // Reload schools after adding a new one
          },
        ),
      ],
    );
  }

  // Build user profile header with avatar and name
  Widget _buildUserProfileHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text(
              widget.user.first_name?[0] ?? '',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            '${widget.user.first_name ?? ''} ${widget.user.middle_name ?? ''} ${widget.user.last_name ?? ''}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _selectedRole ?? '',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build section title with icon
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  // Build custom switch list tile for user activation
  Widget _buildCustomSwitchListTile() {
    return SwitchListTile(
      title: Row(
        children: [
          Icon(
            _isActivate ? Icons.check_circle : Icons.cancel,
            color: _isActivate ? Colors.green : Colors.red,
          ),
          SizedBox(width: 8),
          Text(
            'تفعيل المستخدم',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
      subtitle: Text(
        _isActivate
            ? 'المستخدم نشط ويمكنه تسجيل الدخول'
            : 'المستخدم غير نشط ولا يمكنه تسجيل الدخول',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      value: _isActivate,
      onChanged: _isEditable
          ? (bool value) {
              setState(() {
                _isActivate = value;
              });
            }
          : null,
      activeColor: Theme.of(context).primaryColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Handle form submission
  Future<void> _handleFormSubmission() async {
    try {
      int phoneNumber = int.parse(_phone.text);
      int telephoneNumber = int.parse(_telephone.text);
      String passwordNumber = (_password.text);
      int? roleId = _getRoleId(_selectedRole);
      int activate = _isActivate ? 1 : 0;

      widget.user.first_name = _firstname.text;
      widget.user.middle_name = _fathername.text;
      widget.user.grandfather_name = _grandfathername.text;
      widget.user.last_name = _lastname.text;
      widget.user.phone_number = phoneNumber;
      widget.user.telephone_number = telephoneNumber;
      widget.user.email = _email.text;
      widget.user.password = passwordNumber.toString();
      widget.user.date = _date.text;
      widget.user.isActivate = activate;
      widget.user.roleID = roleId;
      widget.user.schoolID = _selectedSchoolId;

      await userController.updateUser(widget.user, 1);
      setState(() {
        _isEditable = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('تم حفظ التعديلات بنجاح'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      debugPrint("Error in _handleFormSubmission: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('حدث خطأ أثناء حفظ التعديلات: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // Get role ID from role name
  int? _getRoleId(String? selectedRole) {
    switch (selectedRole) {
      case "مشرف":
        return 0;
      case "مدير":
        return 1;
      case "معلم":
        return 2;
      default:
        return null;
    }
  }
}
