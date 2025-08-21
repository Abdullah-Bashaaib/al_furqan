import 'dart:developer';

import 'package:al_furqan/controllers/TeacherController.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:uuid/uuid.dart';

class FathersController {
  final List<UserModel> fathers = [];
  var fatherByID = UserModel();
  final _sqlDb = SqlDb();
  var uuid = Uuid();

  Future<bool> connected() async {
    bool conn = await InternetConnectionChecker.createInstance().hasConnection;
    return conn;
  }

  /// get all fathers by school id
  Future<void> getFathersStudents(int schoolID) async {
    List<Map<String, dynamic>> response = await _sqlDb.readData(
        "SELECT * FROM USERS WHERE ROLEID = 3 AND schoolID = $schoolID");
    log("Reponse into getFathersStudents method : ${response.isEmpty}");
    fathers.clear();
    fathers.addAll(teacherController.mapResponseToUserModel(response));
    log("FathersList into getFathersStudents method : ${fathers.isEmpty}");
  }

  Future<UserModel> getFatherByID(String userID) async {
    // var fa = UserModel();
    List<Map<String, dynamic>> response =
        await _sqlDb.readData("SELECT * FROM USERS WHERE user_id = '$userID'");
    for (var element in response) {
      fatherByID.user_id = element['user_id'];
      fatherByID.first_name = element['first_name'];
      fatherByID.middle_name = element['middle_name'];
      fatherByID.grandfather_name = element['grandfather_name'];
      fatherByID.last_name = element['last_name'];
      fatherByID.phone_number = element['phone_number'];
      fatherByID.telephone_number = element['telephone_number'];
      fatherByID.email = element['email'];
      fatherByID.password = element['password'];
      fatherByID.roleID = element['roleID'];
      fatherByID.schoolID = element['schoolID'];
      fatherByID.date = element['date'];
      fatherByID.isActivate = element['isActivate'];
    }
    return fatherByID;
  }

  /// get fathers by student id
  Future<void> getFathersStudentsByStudentID(
      int schoolID, String studentID) async {
    /// this's all for get user id into student
    List<Map<String, dynamic>> response = await _sqlDb
        .readData("SELECT * FROM Students WHERE StudentID = '$studentID'");
    log("Response in getFathersStudentsByStudentID method : ${response.isEmpty}");
    for (var e in response) {
      fatherByID.user_id = e['userID'].toString();
      fatherByID.first_name = e['first_name'];
      fatherByID.middle_name = e['middle_name'];
      fatherByID.grandfather_name = e['grandfather_name'];
      fatherByID.last_name = e['last_name'];
      fatherByID.phone_number = e['phone_number'];
      fatherByID.telephone_number = e['telephone_number'];
      fatherByID.email = e['email'];
      fatherByID.password = e['password'];
      fatherByID.roleID = e['roleID'];
      fatherByID.schoolID = e['schoolID'];
      fatherByID.date = e['date'];
      fatherByID.isActivate = e['isActivate'];

      log("User Id in FatherController : ${fatherByID.user_id}");
    }
    try {
      fatherByID = await getFatherByID(fatherByID.user_id!);
    } catch (e) {
      log("Error In Father Controller : $e ");
    }
  }

  Future<String?> addFather(UserModel father, int type) async {
    final db = await sqlDb.database;
    if (type == 1) {
      /// adding to local and firebase
      String id = uuid.v4();
      father.user_id = id;
      if (await connected()) {
        father.isSync = 1;
        debugPrint("--------> Father Map in Add Father : ${father.toMap()}");
        int response = await db.insert('USERS', father.toMap());
        debugPrint("Insert To Local : $response");
        await userController.addFatherToFirebase(father);
        return id;
      } else {
        father.isSync = 0;
        debugPrint("Father Map : ${father.toMap()}");
        int response = await db.insert('USERS', father.toMap());
        debugPrint("Insert To Local : $response");
        return id;
      }
    } else {
      // await db.insert('USERS', father.toMap());
    }
    // int response = await _sqlDb.insertData('''
    // INSERT INTO USERS (first_name, middle_name, grandfather_name, last_name, phone_number, telephone_number, email, password, roleID, schoolID, date, isActivate)
    // VALUES ('${father.first_name}', '${father.middle_name}', '${father.grandfather_name}', '${father.last_name}', '${father.phone_number}', '${father.telephone_number}', '${father.email}', '${father.password}', ${father.roleID}, ${father.schoolID}, '${father.date}', 0);
    // ''');
    // father.user_id = response;
    // debugPrint("Response into addFather method : $response");
    return null;
  }

  Future<List<UserModel>> getFathersByElhalagaId(String elhalagatID) async {
    debugPrint('getFathersByElhalagaId called with elhalagatID: $elhalagatID');
    try {
      // المشكلة قد تكون في العلاقة بين الجداول - نستخدم استعلام مختلف
      // نحاول الحصول على آباء الطلاب في الحلقة المحددة
      List<Map<String, dynamic>> response =
          await _sqlDb.readData("""SELECT DISTINCT Users.* FROM Users 
           JOIN Students ON Users.user_id = Students.userID 
           WHERE Students.ElhalagatID = '$elhalagatID' AND Users.roleID = 3""");

      log("Query result count: ${response.length}");

      if (response.isEmpty) {
        // محاولة استعلام بديل إذا كان الاستعلام الأول لا يعيد نتائج
        response = await _sqlDb.readData("""SELECT DISTINCT Users.* FROM Users 
             JOIN Students ON Users.user_id = Students.userID 
             WHERE Students.ElhalagatID = '$elhalagatID' AND Users.roleID = 3""");
        debugPrint("Alternative query result count: ${response.length}");
      }

      List<UserModel> fathers = [];

      for (var e in response) {
        debugPrint("Processing user: ${e['first_name']} (ID: ${e['user_id']})");
        UserModel father = UserModel(
          user_id: e['user_id'],
          first_name: e['first_name'],
          middle_name: e['middle_name'],
          grandfather_name: e['grandfather_name'],
          last_name: e['last_name'],
          phone_number: e['phone_number'],
          telephone_number: e['telephone_number'],
          email: e['email'],
          roleID: e['roleID'],
        );
        fathers.add(father);
      }

      debugPrint("Total fathers found: ${fathers.length}");
      return fathers;
    } catch (e) {
      debugPrint('Error in getFathersByElhalagaId: $e');
      return [];
    }
  }

  Future<List<UserModel>> getFathersBySchoolId(int schoolID) async {
    try {
      List<Map<String, dynamic>> response =
          await _sqlDb.readData("SELECT * FROM Users "
              "INNER JOIN Students ON Users.user_id = Students.userID "
              "WHERE Students.SchoolID = $schoolID");

      List<UserModel> fathers = [];

      for (var e in response) {
        UserModel father = UserModel(
          user_id: e['user_id'],
          first_name: e['first_name'],
          middle_name: e['middle_name'],
          grandfather_name: e['grandfather_name'],
          last_name: e['last_name'],
          roleID: e['roleID'],
          schoolID: e['schoolID'],
        );

        fathers.add(father);
      }
      debugPrint('=================================== father');
      return fathers;
    } catch (e) {
      debugPrint('====$e');
      return [];
    }
  }
}

FathersController fathersController = FathersController();
