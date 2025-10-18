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
        "SELECT E.halagaID, E.Name, E.NumberStudent, E.SchoolID, U.first_name, U.last_name, U.user_id \
        FROM Elhalagat E \
        LEFT JOIN Users U ON U.ElhalagatID = E.halagaID AND U.roleID = 2 \
        WHERE E.SchoolID = $id");

    debugPrint("--------------------------------------------");
    debugPrint("بيانات الحلقات التي تم جلبها من قاعدة البيانات:");
    for (var row in data) {
      debugPrint("halagaID: \\${row['halagaID']}, Name: \\${row['Name']}");
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
    debugPrint("تم جلب بيانات الحلقات: \\${data.length}");
    return halagaData;
  }

  Future<List<UserModel>> getTeachers(int schoolID) async {
    List<Map> data = await _sqlDb.readData(
        "SELECT * FROM Users WHERE schoolID = $schoolID AND roleID = 2");

    List<UserModel> teachers = [];

    if (data.isNotEmpty) {
      for (var i = 0; i < data.length; i++) {
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
    debugPrint("تم جلب بيانات المعلمين: \\${teachers.length}");
    return teachers;
  }

  Future<void> addHalaga(HalagaModel halagaData, int type) async {
    try {
      final db = await sqlDb.database;
      if (type == 1) {
        halagaData.halagaID = uuid.v4();
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
      if (halaga.halagaID == null) {
        throw Exception("معرف الحلقة غير متوفر");
      }

      halaga.NumberStudent ??= 0;

      if (type == 1) {
        if (await isConnected()) {
          halaga.isSync = 1;
          await firebasehelper.updateHalaga(halaga);
          await db.update(
            'Elhalagat',
            halaga.toMap(),
            where: 'halagaID = ?',
            whereArgs: [halaga.halagaID],
          );
        } else {
          halaga.isSync = 0;
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
        await firebasehelper.teacherCancel(halagaId);
        await _sqlDb.updateData(
            "UPDATE Users SET ElhalagatID = NULL, isSync = 1 WHERE ElhalagatID = '\\$halagaId' AND roleID = 2");

        await firebasehelper.newTeacher(halagaId, teacherId);
        await _sqlDb.updateData(
          "UPDATE Users SET ElhalagatID = '\\$halagaId', isSync = 1 WHERE user_id = '\\$teacherId' AND roleID = 2",
        );
        debugPrint("---------------->> here");
      } else {
        await _sqlDb.updateData(
            "UPDATE Users SET ElhalagatID = NULL, isSync = 0 WHERE ElhalagatID = '\\$halagaId' AND roleID = 2");

        await _sqlDb.updateData(
          "UPDATE Users SET ElhalagatID = '\\$halagaId', isSync = 0 WHERE user_id = '\\$teacherId' AND roleID = 2",
        );
      }
    } catch (e) {
      debugPrint('error===$e');
    }
  }

  Future<void> deleteHalaga(String halagaID) async {
    try {
      List<StudentModel> dataStudents = await studentController
          .getStudents(halagaID);
      List<UserModel> dataTeacher =
          await teacherController.getTeacherByHalagaID(halagaID);

      int response1 = await _sqlDb.updateData(
          "UPDATE Students SET ElhalagatID = NULL WHERE ElhalagatID = '\\$halagaID'");
      int response2 = await _sqlDb.updateData(
          "UPDATE Users SET ElhalagatID = NULL WHERE ElhalagatID = '\\$halagaID'");
      log("message: Updated Students and Users, response1: \\$response1, response2: \\$response2");

      int response = await _sqlDb
          .deleteData("DELETE FROM Elhalagat WHERE halagaID = '\\$halagaID'");

      if (await isConnected()) {
        for (var student in dataStudents) {
          student.isSync = 1;
          student.elhalaqaID = null;
          await firebasehelper.studentCancel(halagaID);
        }
        for (var teacher in dataTeacher) {
          teacher.isSync = 1;
          teacher.elhalagatID = null;
          await firebasehelper.teacherCancel(halagaID);
        }
      }

      debugPrint("تم حذف الحلقة \\$halagaID، الاستجابة: \\$response");
      dataTeacher.clear();
      dataStudents.clear();
      if (response == 0) {
        throw Exception("فشل في حذف الحلقة \\$halagaID");
      }
    } catch (e) {
      log("خطأ في حذف الحلقة: $e");
      rethrow;
    }
  }

  Future<int> getStudentCount(String halagaID) async {
    try {
      final count = await _sqlDb.readData(
          "SELECT COUNT(*) as count FROM Students WHERE ElhalagatID = '\\$halagaID'"
      );
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
          'SELECT first_name, last_name FROM Users WHERE user_id = "\$teacherID" AND roleID = 2');

      if (teacherData.isEmpty) {
        return 'معلم غير موجود';
      }

      return "\\$teacherData[0]['first_name'] \$teacherData[0]['last_name']";
    } catch (e) {
      debugPrint('خطأ في جلب بيانات المعلم: $e');
      return 'خطأ في جلب بيانات المعلم';
    }
  }

  Future<HalagaModel?> getHalqaDetails(String halagaID) async {
    try {
      var response = await _sqlDb.readData(
          'SELECT E.*, U.first_name, U.last_name, U.user_id as TeacherID \
          FROM Elhalagat E \
          LEFT JOIN Users U ON U.ElhalagatID = E.halagaID AND U.roleID = 2 \
          WHERE E.halagaID = "\$halagaID"');

      if (response.isEmpty) {
        debugPrint('لا توجد بيانات للحلقة بالمعرف: \\$halagaID');
        return null;
      }

      var halagaData = response[0];

      HalagaModel halaga = HalagaModel(
        halagaID: halagaData['halagaID'],
        Name: halagaData['Name'],
        SchoolID: halagaData['SchoolID'],
        NumberStudent: halagaData['NumberStudent'] != null
            ? int.parse(halagaData['NumberStudent'].toString())
            : 0,
      );

      debugPrint('تم جلب بيانات الحلقة بنجاح: \\$halaga.Name');
      return halaga;
    } catch (e) {
      debugPrint('خطأ في جلب بيانات الحلقة: $e');
      return null;
    }
  }

  Future<HalagaModel?> getHalagaByHalagaID(String halagaID) async {
    List<Map<String, dynamic>> halagaData = await _sqlDb
        .readData("SELECT * FROM Elhalagat WHERE halagaID = '\\$halagaID'");
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
      if (result.isNotEmpty) {
        final firstName = result.first['first_name'] ?? '';
        final middleName = result.first['middle_name'] ?? '';
        final lastName = result.first['last_name'] ?? '';

        final fullName = '\\$firstName \$middleName \$lastName'.trim();
        return fullName.isEmpty ? 'لا يوجد معلم للحلقة' : fullName;
      } else {
        return 'لا يوجد معلم للحلقة';
      }
    } catch (e) {
      debugPrint('خطأ في جلب اسم المعلم: $e');
      return 'لا يوجد معلم للحلقة';
    }
  }

  Future<void> _processHalagaDocsInBatch(List<QueryDocumentSnapshot> docs) async {
    if (docs.isEmpty) return;
    try {
      List<HalagaModel> models = docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        return HalagaModel.fromJson(data);
      }).toList();

      final localRows = await _sqlDb.readData("SELECT halagaID FROM Elhalagat");
      final localSet = localRows.map((r) => r['halagaID']?.toString()).whereType<String>().toSet();

      final inserts = <HalagaModel>[];
      final updates = <HalagaModel>[];

      for (var m in models) {
        if (m.halagaID == null) continue;
        if (localSet.contains(m.halagaID)) {
          updates.add(m);
        } else {
          inserts.add(m);
        }
      }

      final db = await _sqlDb.database;
      await db.transaction((txn) async {
        for (var ins in inserts) {
          try {
            ins.isSync = 1;
            await txn.insert('Elhalagat', ins.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
          } catch (e) {
            debugPrint('خطأ أثناء إدخال حلقة \\$ins.halagaID: $e');
          }
        }

        for (var upd in updates) {
          try {
            upd.NumberStudent ??= 0;
            upd.isSync = 1;
            await txn.update(
              'Elhalagat',
              upd.toMap(),
              where: 'halagaID = ?',
              whereArgs: [upd.halagaID],
            );
          } catch (e) {
            debugPrint('خطأ أثناء تحديث حلقة \\$upd.halagaID: $e');
          }
        }
      });
      debugPrint('تمت مزامنة \\$inserts.length inserts و \\$updates.length updates من Firebase');
    } catch (e) {
      debugPrint('خطأ في المعالجة الدفعية للحلقات: $e');
    }
  }

  Future<void> getHalagatFromFirebase() async {
    try {
      if (await isConnected()) {
        debugPrint('===== getHalagatFromFirebase =====');
        final snapshot = await FirebaseFirestore.instance.collection('Elhalaga').get();
        await _processHalagaDocsInBatch(snapshot.docs);
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
        if (snapshot.docs.isNotEmpty) {
          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final halaga = HalagaModel.fromJson(data);
            if (halaga.halagaID != null) {
              CurrentUser.halaga = halaga;
              if (!halagatId.contains(halaga.halagaID!)) halagatId.add(halaga.halagaID!);
            }
          }
          await _processHalagaDocsInBatch(snapshot.docs);
        }
      }
    } catch (e) {
      debugPrint('خطأ في جلب الحلقات من Firebase: $e');
      return;
    }
  }
}

HalagaController halagaController = HalagaController();