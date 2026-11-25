import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

Future<String> getMaxValue() async {
  try {
    // إنشاء UUID جديد
    var uuid = Uuid();
    String newId = uuid.v4(); // إنشاء UUID نسخة 4 (عشوائي)
    debugPrint("-------------------> UUID الجديد: $newId");
    return newId;
  } catch (e) {
    debugPrint('Error generating UUID: $e');
    // إنشاء UUID في حالة الخطأ أيضاً
    return Uuid().v4();
  }
}
