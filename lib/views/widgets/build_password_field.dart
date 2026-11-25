import 'package:flutter/material.dart';

Widget buildPasswordField({
  required TextEditingController controller,
  required bool isPasswordVisible,
  required bool isEditable,
  required Function() togglePasswordVisibility,
}) {
  return TextFormField(
    controller: controller,
    obscureText: !isPasswordVisible,
    maxLength: 8,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: 'كلمة المرور',
      border: OutlineInputBorder(),
      suffixIcon: IconButton(
        icon: Icon(
          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: togglePasswordVisibility,
      ),
    ),
    readOnly: !isEditable,
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
