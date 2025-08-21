import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/main.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  List<UserModel?> users = [];
  List<UserModel?> teachers = [];
  List<UserModel?> activeTeacher = [];
  List<UserModel?> inactiveTeacher = [];

  int get teacherCount => activeTeacher.length;
  List<UserModel?> get teachersList => activeTeacher;

  String? phoneN = perf.getString('phone_number');
  int? schoolID = perf.getInt('schoolId');

  UserProvider() {
    init();
  }

  init() async {
    int? role = perf.getInt('roleID') ?? 4;
    if (role == 1) {
      await loadUserFromLocal();
    } else {}
  }

  Future<void> loadUsersFromFirebase() async {
    await userController.addToLocalOfFirebase();
    await loadUserFromLocal();
    // await loadTeachers();
  }

  loadActiveTeacher() {
    List<UserModel> activeUsersList = teachers
        .where((user) => user != null && user.isActivate == 1)
        .cast<UserModel>()
        .toList();
    activeTeacher.clear();
    activeTeacher.addAll(activeUsersList);
    notifyListeners();
  }

  loadInActiveTeacher() {
    List<UserModel> inactiveUsersList = teachers
        .where((user) => user != null && user.isActivate == 0)
        .cast<UserModel>()
        .toList();
    inactiveTeacher.clear();
    inactiveTeacher.addAll(inactiveUsersList);
    notifyListeners();
  }

  Future<void> loadUserFromLocal() async {
    // final sw3 = Stopwatch()..start();

    List<UserModel?> usersList = await userController.loadUserBySchoolId();
    users.clear();
    users.addAll(usersList);
    notifyListeners();
    print(users);
    await loadTeachers();
    // sw3.stop();
    // int timeSyncStudents = sw3.elapsedMilliseconds;
    // debugPrint("Time load users is : $timeSyncStudents ms");
  }

  loadTeachers() {
    List<UserModel> teachersList = users
        .where((user) => user != null && user.roleID == 2)
        .cast<UserModel>()
        .toList();
    teachers.clear();
    teachers.addAll(teachersList);
    notifyListeners();
    loadActiveTeacher();
    loadInActiveTeacher();
  }
}

UserProvider userProvider = UserProvider();
