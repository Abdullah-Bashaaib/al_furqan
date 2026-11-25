import 'package:flutter/material.dart';

Widget buildDropdownField({
  required String? selectedRole,
  required bool isEditable,
  required Function(String?) onChanged,
}) {
  return DropdownButtonFormField<String>(
    value: selectedRole,
    decoration: InputDecoration(
      labelText: 'اختر الدور',
      border: OutlineInputBorder(),
    ),
    items: <String>['مشرف', 'مدير', 'معلم'].map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(),
    onChanged: isEditable ? onChanged : null,
    validator: (value) {
      if (value == null) {
        return 'الرجاء اختيار الدور';
      }
      return null;
    },
  );
}
