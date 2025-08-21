import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildDateField({
  required TextEditingController controller,
  required bool isEditable,
  required BuildContext context,
}) {
  return TextFormField(
    controller: controller,
    readOnly: true,
    decoration: InputDecoration(
      labelText: 'تاريخ الميلاد',
      border: OutlineInputBorder(),
    ),
    onTap: () async {
      if (isEditable) {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1700),
          lastDate: DateTime(2300),
        );
        if (pickedDate != null) {
          String formattedDate = DateFormat.yMMMd().format(pickedDate);
          controller.text = formattedDate;
        }
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
