import 'package:flutter/material.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/models/users_model.dart';

Widget buildSaveButton({
  required GlobalKey<FormState> formKey,
  required UserModel user,
  required TextEditingController firstname,
  required TextEditingController fathername,
  required TextEditingController grandfathername,
  required TextEditingController lastname,
  required TextEditingController phone,
  required TextEditingController telephone,
  required TextEditingController email,
  required TextEditingController password,
  required TextEditingController date,
  required String? selectedRole,
  required int? selectedSchoolID,
  required bool isActivate,
  required Function() refreshData,
  required BuildContext context,
  required Function(bool) setEditable,
}) {
  return ElevatedButton(
    onPressed: () async {
      if (formKey.currentState!.validate()) {
        await _handleFormSubmission(
          user: user,
          firstname: firstname,
          fathername: fathername,
          grandfathername: grandfathername,
          lastname: lastname,
          phone: phone,
          telephone: telephone,
          email: email,
          password: password,
          date: date,
          selectedRole: selectedRole,
          selectedSchoolID: selectedSchoolID,
          isActivate: isActivate,
          refreshData: refreshData,
          context: context,
          setEditable: setEditable,
        );
      }
    },
    child: Text('حفظ التعديلات'),
  );
}

Future<bool> _handleFormSubmission({
  required UserModel user,
  required TextEditingController firstname,
  required TextEditingController fathername,
  required TextEditingController grandfathername,
  required TextEditingController lastname,
  required TextEditingController phone,
  required TextEditingController telephone,
  required TextEditingController email,
  required TextEditingController password,
  required TextEditingController date,
  required String? selectedRole,
  required int? selectedSchoolID,
  required bool isActivate,
  required Function() refreshData,
  required BuildContext context,
  required Function(bool) setEditable,
}) async {
  try {
    int phoneNumber = int.parse(phone.text);
    int telephoneNumber = int.parse(telephone.text);
    String passwordNumber = (password.text);
    int? roleId = _getRoleId(selectedRole);
    int activate = isActivate ? 1 : 0;

    user.first_name = firstname.text;
    user.middle_name = fathername.text;
    user.grandfather_name = grandfathername.text;
    user.last_name = lastname.text;
    user.phone_number = phoneNumber;
    user.telephone_number = telephoneNumber;
    user.email = email.text;
    user.password = passwordNumber.toString();
    user.date = date.text;
    user.isActivate = activate;
    user.roleID = roleId;
    user.schoolID = selectedSchoolID;

    await userController.updateUser(user, 0);
    setEditable(false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("تم حفظ التعديلات بنجاح"),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop(true); // Return true to indicate success
    return true;
  } catch (e) {
    debugPrint("Error in _handleFormSubmission: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("حدث خطأ أثناء حفظ التعديلات"),
        backgroundColor: Colors.redAccent,
      ),
    );
    return false;
  }
}

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
