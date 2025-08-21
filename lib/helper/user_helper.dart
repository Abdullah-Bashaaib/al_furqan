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
      debugPrint("No phone number stored in SharedPreferences");
      return null;
    }

    await userController.getDataUsers();
    debugPrint("userList empty: ${userController.users.isEmpty}");

    for (var element in userController.users) {
      // تحويل phone_number إلى سلسلة نصية لتجنب مشاكل المقارنة
      if (phoneUser == element.phone_number?.toString()) {
        debugPrint(
            "User found: ${element.first_name} ${element.last_name}, schoolID: ${element.schoolID}");
        return element;
      }
    }
    debugPrint("No user found for phone number: $phoneUser");
    return null;
  }
}

mixin UserDataMixin<T extends StatefulWidget> on State<T> {
  UserModel? user;
  bool _isLoading = true;
  int? schoolID; // متغير لتخزين schoolID

  bool get isLoading => _isLoading;

  Future<void> fetchUserData() async {
    debugPrint("UserDataMixin: fetchUserData started");
    setState(() => _isLoading = true);
    user = await UserHelper.getDataByPref();

    if (user != null && user!.schoolID != null) {
      schoolID = user!.schoolID!;
      debugPrint("UserDataMixin: schoolID set to: $schoolID");
      debugPrint("UserDataMixin: elhalagat set to: ${user!.elhalagatID}");

      await _refreshData(); // ← await هنا مهمة
    } else {
      debugPrint(
          "UserDataMixin: User or schoolID is null - user: $user, schoolID: ${user?.schoolID}");
    }

    setState(() => _isLoading = false);
    debugPrint(
        "UserDataMixin: fetchUserData completed, isLoading set to false");
  }

  Future<void> _refreshData() async {
    debugPrint("UserDataMixin: _refreshData started");
    if (user == null || user!.schoolID == null) {
      debugPrint(
          "UserDataMixin: User or schoolID is null, cannot refresh data");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: بيانات المستخدم أو المدرسة غير متوفرة')),
      );
      return;
    }

    try {
      debugPrint(
          "UserDataMixin: Fetching teachers for schoolID: ${user!.schoolID}");
      await teacherController.getTeachersBySchoolID(user!.schoolID!);
      debugPrint(
          "UserDataMixin: Teacher count after refresh: ${teacherController.teachers.length}");

      // تحديث بيانات المستخدم الحالي من قائمة المعلمين المحدثة
      if (user!.roleID == 2) {
        // إذا كان المستخدم معلم
        for (var teacher in teacherController.teachers) {
          if (teacher.user_id == user!.user_id) {
            // تحديث بيانات المستخدم بالبيانات المحدثة من قاعدة البيانات
            user = teacher;
            debugPrint(
                "UserDataMixin: Updated user data from teachers list. ElhalagatID: ${user!.elhalagatID}");
            break;
          }
        }
      }

      debugPrint(
          "UserDataMixin: Fetching students for schoolID: ${user!.schoolID}");
      await studentController.getSchoolStudents(user!.schoolID!);
      debugPrint(
          "UserDataMixin: Student count after refresh: ${studentController.students.length}");

      setState(() {});
      debugPrint("UserDataMixin: State updated after data refresh");
    } catch (e) {
      debugPrint("UserDataMixin: Error refreshing data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }
}
