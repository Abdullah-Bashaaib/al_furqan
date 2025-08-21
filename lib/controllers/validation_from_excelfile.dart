import 'package:flutter/material.dart';

class ExcelDataValidator {
  // تحويل الأرقام العربية إلى إنجليزية
  static String _convertArabicNumbers(String input) {
    debugPrint("-----------------input is : $input, lengeth : ${input.length}");
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < arabic.length; i++) {
      input = input.replaceAll(arabic[i], english[i]);
    }
    debugPrint("-----------------input is : $input, lengeth : ${input.length}");
    debugPrint("num Ar : $arabic");
    return input;
  }

  // التحقق من صحة الصف
  static Map<String, dynamic> validateRow(Map<String, dynamic> row) {
    final errors = <String, String>{};
    final validated = <String, dynamic>{};

    // الحقول المطلوبة
    const requiredFields = [
      'الاسم الاول',
      'اسم الأب',
      'اسم الجد',
      'اسم جد الأب',
      'اسم العائلة',
    ];

    // التحقق من الحقول المطلوبة
    for (final field in requiredFields) {
      debugPrint(
          "-------------------------------------------------------------this's row $field : ${row[field]}");
      final value = row[field]?.toString().trim() ?? '';
      if (value.isEmpty) {
        errors[field] = 'هذا الحقل مطلوب';
      }
    }

    // التحقق من الإيميل
    final email = row['البريد الالكتروني']?.toString().trim() ?? '';
    if (!email.endsWith('@gmail.com')) {
      errors['البريد الالكتروني'] = 'يجب أن ينتهي بـ @gmail.com';
    } else {
      validated['email'] = email;
    }
    debugPrint("-------------number phone filed: ${row['رقم الجوال']}");
    // التحقق من رقم الجوال
    final phone =
        _convertArabicNumbers(row['رقم الجوال']?.toString().trim() ?? '');
    if (!RegExp(r'^\d{9}$').hasMatch(phone)) {
      errors['رقم الجوال'] = 'يجب أن يكون 9 أرقام';
    } else {
      validated['phone'] = int.parse(phone);
    }
    debugPrint(
        "------بلابلا-------number Telephone filed: ${row['رقم الهاتف'].toString()}");

    // التحقق من رقم الهاتف
    final telephone =
        _convertArabicNumbers(row['رقم الهاتف']?.toString().trim() ?? '');
    if (!RegExp(r'^\d{6}$').hasMatch(telephone)) {
      errors['رقم الهاتف'] = 'يجب أن يكون 6 أرقام';
    } else {
      validated['telephone'] = int.parse(telephone);
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
      'validated': validated,
    };
  }
}
