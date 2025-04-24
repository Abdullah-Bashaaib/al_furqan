import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/StudentController.dart';
import '../controllers/TeacherController.dart';

class UserHelper {
  static Future<UserModel?> getDataByPref() async {
    final pref = await SharedPreferences.getInstance();
    String? phoneUser = pref.getString('phoneUser');
    if (phoneUser == null) {
      print("No phone number stored in SharedPreferences");
      return null;
    }

    await userController.getDataUsers();
    print("userList empty: ${userController.users.isEmpty}");

    for (var element in userController.users) {
      // تحويل phone_number إلى سلسلة نصية لتجنب مشاكل المقارنة
      if (phoneUser == element.phone_number?.toString()) {
        print(
            "User found: ${element.first_name} ${element.last_name}, schoolID: ${element.schoolID}");
        return element;
      }
    }
    print("No user found for phone number: $phoneUser");
    return null;
  }
}

mixin UserDataMixin<T extends StatefulWidget> on State<T> {
  UserModel? user;
  bool _isLoading = true;
  int? schoolID; // متغير لتخزين schoolID

  bool get isLoading => _isLoading;

  Future<void> fetchUserData() async {
  setState(() => _isLoading = true);
  user = await UserHelper.getDataByPref();
  if (user != null && user!.schoolID != null) {
    schoolID = user!.schoolID!;
    print("schoolID set to: $schoolID");
    await _refreshData(); // ← await هنا مهمة
  } else {
    print("User or schoolID is null");
  }
  setState(() => _isLoading = false);
}

  Future<void> _refreshData() async {
  if (user == null || user!.schoolID == null) {
    print("User or schoolID is null, cannot refresh data");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('خطأ: بيانات المستخدم أو المدرسة غير متوفرة')),
    );
    return;
  }

  try {
    await teacherController.getTeachersBySchoolID(user!.schoolID!);
    await studentController.getSchoolStudents(user!.schoolID!);
    setState(() {});
  } catch (e) {
    print("Error refreshing data: $e");
  }
}

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }
}
