import 'package:flutter/material.dart';

Widget buildEditButton({
  required bool isEditable,
  required Function() onPressed,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    child: Text(isEditable ? 'إلغاء' : 'تعديل البيانات'),
  );
}
