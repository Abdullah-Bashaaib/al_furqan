// ignore_for_file: file_names

import 'dart:developer';

import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/TeacherController.dart';
import 'package:al_furqan/helper/current_user.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:uuid/uuid.dart';

import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/firebase_service.dart';

class HalagaController {
  final SqlDb _sqlDb = SqlDb();
  final List<HalagaModel> halagaData = [];
  final List<String> halagatId = [];
  final uuid = Uuid();

  Future<bool> isConnected() async {
    var conn = InternetConnectionChecker.createInstance().hasConnection;
    return conn;
  }

  Future<List<HalagaModel>> getData(int id) async {
    List<Map> data = await _sqlDb.readData(
        "SELECT E.halagaID, E.Name, E.NumberStudent, E.SchoolID, U.first_name, U.last_name, U.user_id "
        "FROM Elhalagat E "
        "LEFT JOIN Users U ON U.ElhalagatID = E.halagaID AND U.roleID = 2 "
        "WHERE E.SchoolID = $id");

    debugPrint("--------------------------------------------");
    debugPrint("بيانات الحلقات التي تم جلبها من قاعدة البيانات:");
    for (var row in data) {
      debugPrint("halagaID: ${row['halagaID']}, Name: ${row['Name']}");
    }
    debugPrint("--------------------------------------------");

    List<HalagaModel> halagaData = [];

    if (data.isNotEmpty) {
      for (var i = 0; i < data.length; i++) {
        String? halagaID = data[i]['halagaID'] as String?;
        String name = data[i]['Name'] ?? 'اسم غير متوفر';
        int numberStudent =
            int.tryParse(data[i]['NumberStudent'].toString()) ?? 0;
        int? schoolID = data[i]['SchoolID'] as int?;

        halagaData.add(HalagaModel(
          halagaID: halagaID,
          Name: name,
          NumberStudent: numberStudent,
          SchoolID: schoolID,
        ));
      }
    }
    debugPrint("تم جلب بيانات الحلقات: ${data.length}");
    return halagaData;
  }

  Future<List<UserModel>> getTeachers(int schoolID) async {
    List<Map> data = await _sqlDb.readData(
        "SELECT * FROM Users WHERE schoolID = $schoolID AND roleID = 2");

    List<UserModel> teachers = [];

    if (data.isNotEmpty) {
      for (var i = 0; i < data.length; i++) {
        // String? userID = data[i]['user_id'] as String?;
        // String firstName = data[i]['first_name'] ?? 'اسم غير متوفر';
        // String lastName = data[i]['last_name'] ?? 'اسم غير متوفر';
        // int? roleID = data[i]['roleID'] as int?;
        // int? schoolID = data[i]['schoolID'] as int?;

        teachers.add(UserModel(
          user_id: data[i]['user_id'],
          first_name: data[i]['first_name'],
          middle_name: data[i]['middle_name'],
          grandfather_name: data[i]['grandfather_name'],
          last_name: data[i]['last_name'],
          roleID: data[i]['roleID'],
          schoolID: data[i]['schoolID'],
        ));
      }
    }
    debugPrint("تم جلب بيانات المعلمين: ${teachers.length}");
    return teachers;
  }

  Future<void> addHalaga(HalagaModel halagaData, int type) async {
    try {
      final db = await sqlDb.database;
      if (type == 1) {
        halagaData.halagaID = uuid.v4();
        // await someController.newId("Elhalagat", "halagaID");
        // إضافة الحلقة
        if (await isConnected()) {
          halagaData.isSync = 1;
          await firebasehelper.addHalga(halagaData);
          await db.insert('Elhalagat', halagaData.toMap());
        } else {
          halagaData.isSync = 0;
          await db.insert('Elhalagat', halagaData.toMap());
        }
      } else {
        await db.insert('Elhalagat', halagaData.toMap());
      }
    } catch (e) {
      debugPrint("خطأ في إضافة الحلقة: $e");
      rethrow;
    }
  }

  Future<void> updateHalaga(HalagaModel halaga, int type) async {
    final db = await sqlDb.database;
    try {
      // التحقق من صحة معرف الحلقة
      if (halaga.halagaID == null) {
        throw Exception("معرف الحلقة غير متوفر");
      }

      // التحقق من NumberStudent
      halaga.NumberStudent ??= 0;

      if (type == 1) {
        /// سوف تذهبىالبيانات الى الفايربيس
        if (await isConnected()) {
          halaga.isSync = 1;
          await firebasehelper.updateHalaga(halaga);
          // 1. تحديث بيانات الحلقة في SQLite
          await db.update(
            'Elhalagat',
            halaga.toMap(),
            where: 'halagaID = ?',
            whereArgs: [halaga.halagaID],
          );
        } else {
          halaga.isSync = 0;
          // عند عدم وجود اتصال، نخزن البيانات محلياً فقط
          await db.update(
            'Elhalagat',
            halaga.toMap(),
            where: 'halagaID = ?',
            whereArgs: [halaga.halagaID],
          );
        }
      } else {
        await db.update(
          'Elhalagat',
          halaga.toMap(),
          where: 'halagaID = ?',
          whereArgs: [halaga.halagaID],
        );
      }
    } catch (e) {
      debugPrint("خطأ في تحديث الحلقة: $e");
      rethrow;
    }
  }

  updateTeacherAssignment(String halagaId, String teacherId) async {
    try {
      if (await isConnected()) {
        ///الغاء ارتباط المعلم

        await firebasehelper.teacherCancel(halagaId);
        await _sqlDb.updateData(
            "UPDATE Users SET ElhalagatID = NULL, isSync = 1 WHERE ElhalagatID = '$halagaId' AND roleID = 2");

        /// تعيين معلم جديد
        await firebasehelper.newTeacher(halagaId, teacherId);
        await _sqlDb.updateData(
          "UPDATE Users SET ElhalagatID = '$halagaId', isSync = 1 WHERE user_id = '$teacherId' AND roleID = 2",
        );
        debugPrint("---------------->> here");
      } else {
        ///الغاء ارتباط المعلم
        await _sqlDb.updateData(
            "UPDATE Users SET ElhalagatID = NULL, isSync = 0 WHERE ElhalagatID = '$halagaId' AND roleID = 2");

        /// تعيين معلم جديد
        await _sqlDb.updateData(
          "UPDATE Users SET ElhalagatID = '$halagaId', isSync = 0 WHERE user_id = '$teacherId' AND roleID = 2",
        );
      }
    } catch (e) {
      debugPrint('error===$e');
    }
  }

  Future<void> deleteHalaga(String halagaID) async {
    try {
      // إلغاء ارتباط الطلاب والمعلمين
      List<StudentModel> dataStudents = await studentController
          .getStudents(halagaID); // to edit halagaID field
      List<UserModel> dataTeacher =
          await teacherController.getTeacherByHalagaID(halagaID);

      int response1 = await _sqlDb.updateData(
          "UPDATE Students SET ElhalagatID = NULL WHERE ElhalagatID = '$halagaID'");
      int response2 = await _sqlDb.updateData(
          "UPDATE Users SET ElhalagatID = NULL WHERE ElhalagatID = '$halagaID'");
      log("message: Updated Students and Users, response1: $response1, response2: $response2");

      // حذف الحلقة
      int response = await _sqlDb
          .deleteData("DELETE FROM Elhalagat WHERE halagaID = '$halagaID'");

      try {
        log("Connection is : ${await isConnected()}");
        // إذا كان هناك اتصال بالإنترنت
        if (await isConnected()) {
          log("Here isConnected Function <---------------------------");
          // إلغاء ارتباط الطلاب في Firebase
          for (var student in dataStudents) {
            student.isSync = 1;
            student.elhalaqaID = null;
            await firebasehelper.studentCancel(halagaID);
            log("Updated ElhalagatID for teacher with ID ${student.studentID}: ${student.elhalaqaID}");
          }
          // إلغاء ارتباط المعلمين في Firebase
          for (var teacher in dataTeacher) {
            teacher.isSync = 1;
            teacher.elhalagatID = null;
            await firebasehelper.teacherCancel(halagaID);
            log("Updated ElhalagatID for teacher with ID ${teacher.user_id}: ${teacher.elhalagatID}");
          }
          log("message: إلغاء ارتباط الطلاب والمعلمين في Firebase");
        }
      } on Exception {
        log("Error in the Connection");
      }

      debugPrint("تم حذف الحلقة $halagaID، الاستجابة: $response");
      dataTeacher.clear();
      dataStudents.clear();
      if (response == 0) {
        throw Exception("فشل في حذف الحلقة $halagaID");
      }
    } catch (e) {
      log("خطأ في حذف الحلقة: $e");
      rethrow;
    }
  }

  Future<int> getStudentCount(String halagaID) async {
    try {
      final count = await _sqlDb.readData(
          "SELECT COUNT(*) as count FROM Students WHERE ElhalagatID = '$halagaID'");
      return count[0]['count'] as int;
    } catch (e) {
      debugPrint("خطأ في جلب عدد الطلاب: $e");
      return 0;
    }
  }

  Future<String> getTeacherNameByID(String? teacherID) async {
    if (teacherID == null) {
      return 'لا يوجد معلم للحلقة';
    }

    try {
      var teacherData = await _sqlDb.readData(
          'SELECT first_name, last_name FROM Users WHERE user_id = "$teacherID" AND roleID = 2');

      if (teacherData.isEmpty) {
        return 'معلم غير موجود';
      }

      return "${teacherData[0]['first_name']} ${teacherData[0]['last_name']}";
    } catch (e) {
      debugPrint('خطأ في جلب بيانات المعلم: $e');
      return 'خطأ في جلب بيانات المعلم';
    }
  }

  Future<HalagaModel?> getHalqaDetails(String halagaID) async {
    try {
      var response = await _sqlDb.readData(
          'SELECT E.*, U.first_name, U.last_name, U.user_id as TeacherID '
          'FROM Elhalagat E '
          'LEFT JOIN Users U ON U.ElhalagatID = E.halagaID AND U.roleID = 2 '
          'WHERE E.halagaID = "$halagaID"');

      if (response.isEmpty) {
        debugPrint('لا توجد بيانات للحلقة بالمعرف: $halagaID');
        return null;
      }

      var halagaData = response[0];

      // إذا كان هناك معلم مرتبط بالحلقة
      if (halagaData['first_name'] != null &&
          halagaData['last_name'] != null) {}

      HalagaModel halaga = HalagaModel(
        halagaID: halagaData['halagaID'],
        Name: halagaData['Name'],
        SchoolID: halagaData['SchoolID'],
        NumberStudent: halagaData['NumberStudent'] != null
            ? int.parse(halagaData['NumberStudent'].toString())
            : 0,
      );

      debugPrint('تم جلب بيانات الحلقة بنجاح: ${halaga.Name}');
      return halaga;
    } catch (e) {
      debugPrint('خطأ في جلب بيانات الحلقة: $e');
      return null;
    }
  }

  Future<HalagaModel?> getHalagaByHalagaID(String halagaID) async {
    List<Map<String, dynamic>> halagaData = await _sqlDb
        .readData("SELECT * FROM Elhalagat WHERE halagaID = '$halagaID'");
    if (halagaData.isNotEmpty) {
      return HalagaModel.fromJson(halagaData.first);
    }
    return null;
  }

  Future<String> getTeacher(String halagaId) async {
    try {
      final db = await sqlDb.database;
      final result = await db.query(
        'Users',
        where: 'ElhalagatID = ?',
        whereArgs: [halagaId],
        limit: 1,
      );
      debugPrint('================$result');
      if (result.isNotEmpty) {
        final firstName = result.first['first_name'] ?? '';
        debugPrint('===============$firstName');
        final middleName = result.first['middle_name'] ?? '';
        final lastName = result.first['last_name'] ?? '';

        final fullName = '$firstName $middleName $lastName'.trim();
        return fullName.isEmpty ? 'لا يوجد معلم للحلقة' : fullName;
      } else {
        return 'لا يوجد معلم للحلقة';
      }
    } catch (e) {
      debugPrint('خطأ في جلب اسم المعلم: $e');
      return 'لا يوجد معلم للحلقة';
    }
  }

  Future<void> getHalagatFromFirebase() async {
    try {
      if (await isConnected()) {
        debugPrint('===== getHalagatFromFirebase =====');
        final snapshot =
            await FirebaseFirestore.instance.collection('Elhalaga').get();
        for (var doc in snapshot.docs) {
          HalagaModel halaga = HalagaModel.fromJson(doc.data());
          bool exists = await _sqlDb.checkIfitemExists2(
              'Elhalagat', halaga.halagaID!, 'halagaID');
          if (exists) {
            await updateHalaga(halaga, 0);
            debugPrint('===== updateHalaga =====');
          } else {
            await addHalaga(halaga, 0);
            debugPrint('===== addHalaga =====');
          }
        }
      }
    } catch (e) {
      debugPrint('خطأ في جلب الحلقات من Firebase: $e');
      return;
    }
  }

  Future<void> getHalagatFromFirebaseByID(dynamic id, String name) async {
    try {
      if (await isConnected()) {
        final snapshot = await FirebaseFirestore.instance
            .collection('Elhalaga')
            .where(name, isEqualTo: id)
            .get();
        for (var doc in snapshot.docs) {
          HalagaModel halaga = HalagaModel.fromJson(doc.data());
          bool exists = await _sqlDb.checkIfitemExists2(
              'Elhalagat', halaga.halagaID!, 'halagaID');
          if (exists) {
            CurrentUser.halaga = halaga;
            await updateHalaga(halaga, 0);
            halagatId.add(halaga.halagaID!);
            debugPrint('===== updateHalaga =====');
          } else {
            CurrentUser.halaga = halaga;
            await addHalaga(halaga, 0);
            halagatId.add(halaga.halagaID!);
            debugPrint('===== addHalaga =====');
          }
        }
      }
    } catch (e) {
      debugPrint('خطأ في جلب الحلقات من Firebase: $e');
      return;
    }
  }
}

HalagaController halagaController = HalagaController();
