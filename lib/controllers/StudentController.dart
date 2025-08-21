// ignore_for_file: file_names

import 'dart:developer' as developer;
import 'dart:math';

import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:uuid/uuid.dart';

class StudentController {
  List<StudentModel> students = [];
  final SqlDb _sqldb = SqlDb();
  var uuid = Uuid();
  Future<bool> isConnected() async {
    var conn = InternetConnectionChecker.createInstance().hasConnection;
    return conn;
  }

  Future<List<StudentModel>> getStudents(String halagaID) async {
    List<Map> studentData = await _sqldb
        .readData("SELECT * FROM Students WHERE ElhalagatID = '$halagaID'");

    students = studentData.map((student) {
      return StudentModel(
        studentID: student['StudentID'],
        firstName: student['FirstName'],
        middleName: student['MiddleName'],
        grandfatherName: student['grandfatherName'],
        lastName: student['LastName'],
        attendanceDays: student['AttendanceDays'],
        absenceDays: student['AbsenceDays'],
        elhalaqaID: student['ElhalagatID'],
        isSync: student['isSync'] ?? 0,
      );
    }).toList();
    debugPrint("Fetched students for halaga $halagaID: ${students.length}");
    return students;
  }

  Future<List<StudentModel>> getSchoolStudents(int schoolID) async {
    // try {
    // جلب الطلاب المرتبطين بالمدارس
    List<Map<String, dynamic>> studentData = await _sqldb
        .readData("SELECT * FROM Students WHERE SchoolID = $schoolID");

    // debugPrint("الطلاب الذين تم جلبهم من القاعدة المحلية: $studentData");

    if (studentData.isEmpty) {
      debugPrint("لا توجد بيانات للطلاب مع SchoolID: $schoolID");
      return []; // إذا كانت البيانات فارغة، نرجع قائمة فارغة.
    }

    // تحويل البيانات المسترجعة إلى قائمة من StudentModel
    students = studentData.map((student) {
      return StudentModel(
        userID: student['userID'] is String
            ? student['userID']
            : student['userID'].toString(),
        studentID: student['StudentID'] is String
            ? (student['StudentID'])
            : student['StudentID'].toString(),
        schoolId: student['SchoolID'] is String
            ? int.tryParse(student['SchoolID'])
            : student['SchoolID'] as int?,
        firstName: student['FirstName'] as String?,
        middleName: student['MiddleName'] as String?,
        grandfatherName: student['grandfatherName'] as String?,
        lastName: student['LastName'] as String?,
        elhalaqaID: student['ElhalagatID'] != null
            ? (student['ElhalagatID'] is String
                ? student['ElhalagatID']
                : student['ElhalagatID'] as String?)
            : null,
        attendanceDays: student['AttendanceDays'] is String
            ? int.tryParse(student['AttendanceDays'])
            : student['AttendanceDays'] as int?,
        absenceDays: student['AbsenceDays'] is String
            ? int.tryParse(student['AbsenceDays'])
            : student['AbsenceDays'] as int?,
        excuse: student['Excuse'] as String?,
        reasonAbsence: student['ReasonAbsence'] as String?,
        isSync: student['isSync'] ?? 0,
      );
    }).toList();

    debugPrint("عدد الطلاب الذين تم جلبهم: ${students.length}");

    // طباعة معلومات الحلقات للطلاب للتصحيح
    // for (var student in students) {
    //   debugPrint(
    //       "الطالب: ${student.firstName} ${student.lastName}, معرف الحلقة: ${student.elhalaqaID}, نوع معرف الحلقة: ${student.elhalaqaID?.runtimeType}");
    // }

    return students;
    // } catch (e) {
    // debugPrint("حدث خطأ أثناء جلب الطلاب: $e");
    // return [];
    // }
  }

  // addStudentToFirebase(StudentModel student, int schoolID) async {
  //   debugPrint("جاري إضافة الطالب إلى Firebase - معرف المدرسة: ${schoolID}");
  //   // التحقق أولاً من وجود اتصال بالإنترنت
  //   bool hasConnection =
  //       await InternetConnectionChecker.createInstance().hasConnection;
  //   if (!hasConnection) {
  //     print("لا يوجد اتصال بالإنترنت، لا يمكن إضافة الطالب إلى Firebase");
  //     return;
  //   }
  //
  //   if (student.studentID == null) {
  //     print("تحذير: معرف الطالب غير موجود (studentID = null)");
  //     return; // لا يمكن الإضافة إلى Firebase بدون معرف
  //   }
  //
  //   // إرسال البيانات إلى Firebase فقط بدون إضافة محلية مرة أخرى
  //   await firebasehelper.addStudent(student, schoolID);
  //   print("تم إرسال بيانات الطالب إلى Firebase");
  // }

  Future<int> getTotalStudents() async {
    try {
      final count =
          await _sqldb.readData("SELECT COUNT(*) as count FROM Students");
      debugPrint("Total students: ${count[0]['count']}");
      return count[0]['count'] as int;
    } catch (e) {
      debugPrint("Error fetching total students: $e");
      return 0;
    }
  }

  Future<String?> addStudent(StudentModel studentData, int type) async {
    try {
      // إذا كان schoolId غير موجود، استخدم قيمة افتراضية
      // int schoolId = studentData.schoolId ?? 0;
      // إذا كان userID غير موجود، استخدم NULL
      // String userIdStr =
      //     studentData.userID != null ? "${studentData.userID}" : "NULL";

      // bool hasConnection = await isConnected();
      // int syncValue = hasConnection ? 1 : 0;
      final db = await sqlDb.database;
      if (type == 1) {
        /// adding to local and firebase
        String id = uuid.v4();
        studentData.studentID = id;
        if (await isConnected()) {
          studentData.isSync = 1;
          await db.insert("Students", studentData.toMap());
          await firebasehelper.addStudent(studentData);
          return id;
        } else {
          studentData.isSync = 0;
          await db.insert("Students", studentData.toMap());
          return id;
        }
      } else {
        await db.insert("Students", studentData.toMap());
      }
      // int response = await _sqldb.insertData(
      //     "INSERT INTO Students (userID, SchoolID, FirstName, MiddleName, grandfatherName, LastName, isSync) "
      //     "VALUES ($userIdStr, $schoolId, '${studentData.firstName}', '${studentData.middleName}', "
      //     "'${studentData.grandfatherName}', '${studentData.lastName}', $syncValue)");
      //
      // print(
      //     "Added student, response: $response, Father ID: ${studentData.userID}, Student ID : ${studentData.studentID}");
      // if (response == 0) {
      //   throw Exception("Failed to add student");
      // }

      // تحديث قيمة StudentID في النموذج
      // studentData.studentID = response;

      return null;
    } catch (e) {
      debugPrint("Error adding student: $e");
      rethrow;
    }
  }

  Future<void> updateStudent(StudentModel student, int type) async {
    final db = await sqlDb.database;
    try {
      if (type == 1) {
        if (await isConnected()) {
          student.isSync = 1;
          int update = await db.update("Students", student.toMap(),
              where: 'StudentID = ?', whereArgs: [student.studentID]);
          debugPrint("Update response: $update");
          debugPrint("User ID : ${student.userID}");
          await firebasehelper.updateStudentData(student);
        } else {
          student.isSync = 0;
          await db.update("Students", student.toMap(),
              where: 'StudentID = ?', whereArgs: [student.studentID]);
        }
        debugPrint("Student in update : ${student.grandfatherName}");
      } else {
        int update = await db.update("Students", student.toMap(),
            where: 'StudentID = ?', whereArgs: [student.studentID]);
        debugPrint("Update response: $update");
        debugPrint("User ID : ${student.userID}");
      }
    } catch (e) {
      debugPrint("Error updating student: $e");
      rethrow;
    }
  }

  Future<void> updateAttendance(
      String studentID, bool isPresent, String absenceReasons) async {
    // التحقق من حالة الاتصال بالإنترنت
    bool hasConnection = await isConnected();
    int syncValue = hasConnection ? 1 : 0;

    if (isPresent) {
      debugPrint("تحديث الحضور للطالب: $studentID");
      try {
        // التحقق من القيمة الحالية لأيام الحضور
        List<Map> currentData = await _sqldb.readData(
            "SELECT AttendanceDays FROM Students WHERE StudentID = '$studentID'");

        if (currentData.isNotEmpty) {
          var currentAttendance = currentData[0]['AttendanceDays'];
          int newAttendance =
              (currentAttendance == null) ? 1 : currentAttendance + 1;

          int response = await _sqldb.updateData(
              "UPDATE Students SET AttendanceDays = $newAttendance, isSync = $syncValue WHERE StudentID = '$studentID'");
          if (syncValue == 1) {
            await firebasehelper.updateAttendance(
                studentID, isPresent, absenceReasons);
          }
          debugPrint("استجابة تحديث الحضور: $response");
          debugPrint(
              "حالة المزامنة: ${hasConnection ? 'متصل' : 'غير متصل'}, isSync = $syncValue");
        } else {
          debugPrint("لم يتم العثور على الطالب برقم: $studentID");
        }
      } catch (e) {
        debugPrint("خطأ في تحديث الحضور: $e");
        rethrow;
      }
    } else {
      try {
        debugPrint("تحديث الغياب للطالب: $studentID مع سبب: $absenceReasons");

        // التحقق من القيمة الحالية لأيام الغياب
        List<Map> currentData = await _sqldb.readData(
            "SELECT AbsenceDays FROM Students WHERE StudentID = '$studentID'");

        if (currentData.isNotEmpty) {
          var currentAbsence = currentData[0]['AbsenceDays'];
          int newAbsence = (currentAbsence == null) ? 1 : currentAbsence + 1;

          int response = await _sqldb.updateData(
              "UPDATE Students SET AbsenceDays = $newAbsence, ReasonAbsence = '$absenceReasons', isSync = $syncValue WHERE StudentID = '$studentID'");
          if (syncValue == 1) {
            await firebasehelper.updateAttendance(
                studentID, isPresent, absenceReasons);
          }
          debugPrint("استجابة تحديث الغياب: $response");
          debugPrint(
              "حالة المزامنة: ${hasConnection ? 'متصل' : 'غير متصل'}, isSync = $syncValue");
        } else {
          debugPrint("لم يتم العثور على الطالب برقم: $studentID");
        }
      } catch (e) {
        debugPrint("خطأ في تحديث الغياب: $e");
        rethrow;
      }
    }
  }

  Future<void> addStudentToLocal(StudentModel student) async {
    // التحقق من وجود الطالب بنفس الرقم
    bool exists = false;
    if (student.studentID != null) {
      exists = await _sqldb.checkIfitemExists(
          "Students", student.studentID! as int, "StudentID");
    }

    if (exists) {
      // إذا كان الطالب موجود بالفعل، قم بتحديث بياناته
      debugPrint(
          "الطالب موجود بالفعل بالرقم ${student.studentID}، سيتم تحديث بياناته.");
      int update = await _sqldb.updateData("UPDATE Students SET "
          "ElhalagatID = '${student.elhalaqaID}', "
          "SchoolID = ${student.schoolId}, "
          "FirstName = '${student.firstName}', "
          "MiddleName = '${student.middleName}', "
          "grandfatherName = '${student.grandfatherName}', "
          "LastName = '${student.lastName}', "
          "AttendanceDays = ${student.attendanceDays ?? 'NULL'}, "
          "AbsenceDays = ${student.absenceDays ?? 'NULL'}, "
          "Excuse = '${student.excuse ?? ''}', "
          "ReasonAbsence = '${student.reasonAbsence ?? ''}' "
          "WHERE StudentID = ${student.studentID}");
      debugPrint("تم تحديث بيانات الطالب بنجاح: $update");
    } else {
      // إذا لم يكن الطالب موجوداً، قم بإضافته
      int add = await _sqldb.insertData(
          "INSERT INTO Students (StudentID, ElhalagatID, SchoolID, FirstName, MiddleName, grandfatherName, LastName, AttendanceDays, AbsenceDays, Excuse, ReasonAbsence) "
          "VALUES ('${student.studentID}', '${student.elhalaqaID}', ${student.schoolId}, '${student.firstName}', '${student.middleName}', "
          "'${student.grandfatherName}', '${student.lastName}', ${student.attendanceDays ?? 'NULL'}, "
          "${student.absenceDays ?? 'NULL'}, '${student.excuse ?? ''}', '${student.reasonAbsence ?? ''}')");
      debugPrint("تمت إضافة الطالب بنجاح: $add");
    }
  }

  Future<void> delete(String id) async {
    try {
      int response = await _sqldb
          .deleteData("DELETE FROM Students WHERE StudentID = '$id'");
      debugPrint("Delete response: $response");
      if (response == 0) {
        throw Exception("Failed to delete student $id");
      }
    } catch (e) {
      debugPrint("Error deleting student: $e");
      rethrow;
    }
  }

  Future<void> assignStudentToHalqa(String studentId, String halqaID) async {
    try {
      if (await isConnected()) {
        await firebasehelper.assignStudentToHalqa(studentId, halqaID);
        await _sqldb.updateData(
            "UPDATE Students SET ElhalagatID = '$halqaID' ,isSync = 1 WHERE StudentID = '$studentId'");

        final count = await _sqldb.readData(
            "SELECT COUNT(*) as count FROM Students WHERE ElhalagatID = '$halqaID'");
        final studentCount = count[0]['count'] as int;
        await _sqldb.updateData(
            "UPDATE Elhalagat SET NumberStudent = $studentCount, isSync = 1 WHERE halagaID = '$halqaID'");
      }

      await _sqldb.updateData(
          "UPDATE Students SET ElhalagatID = '$halqaID', isSync = 0 WHERE StudentID = '$studentId'");

      final count = await _sqldb.readData(
          "SELECT COUNT(*) as count FROM Students WHERE ElhalagatID = '$halqaID'");
      final studentCount = count[0]['count'] as int;
      int halagaResponse = await _sqldb.updateData(
          "UPDATE Elhalagat SET NumberStudent = $studentCount, isSync = 0 WHERE halagaID = '$halqaID'");
      // log("Updated NumberStudent to $studentCount for halqa $halqaID, response: $halagaResponse");
    } catch (e) {
      debugPrint("Error assigning student to halqa: $e");
      rethrow;
    }
  }

  Future<void> removeStudentFromHalqa(String studentId) async {
    try {
      int response = await _sqldb.updateData(
          "UPDATE Students SET ElhalagatID = NULL WHERE StudentID = '$studentId'");
      debugPrint("Removed student $studentId from halqa, response: $response");
      if (response == 0) {
        throw Exception("Failed to remove student $studentId from halqa");
      }
    } catch (e) {
      debugPrint("Error removing student from halqa: $e");
      rethrow;
    }
  }

  Future<void> addToLocalOfFirebase(int schoolId) async {
    if (await isConnected()) {
      List<StudentModel> responseFirebase =
          await firebasehelper.getStudentData(schoolId);

      // debugPrint("responseFirebase = $responseFirebase");

      for (var student in responseFirebase) {
        bool exists = await sqlDb.checkIfitemExists2(
            "Students", student.studentID!, "StudentID");
        if (exists) {
          await updateStudent(student, 0);
          debugPrint('===== Find student (update) =====');
        } else {
          await addStudent(student, 0);
          debugPrint('===== Find student (add) =====');
        }
      }
    } else {
      debugPrint("لا يوجد اتصال بالانترنت");
    }
  }

  Future<void> addToLocalOfFire() async {
    if (await isConnected()) {
      List<StudentModel> responseFirebase =
          await firebasehelper.getTotalStudents();

      // debugPrint("responseFirebase = $responseFirebase");

      for (var student in responseFirebase) {
        bool exists = await sqlDb.checkIfitemExists2(
            "Students", student.studentID!, "StudentID");
        if (exists) {
          await updateStudent(student, 0);
          debugPrint('===== Find student (update) =====');
        } else {
          await addStudent(student, 0);
          debugPrint('===== Find student (add) =====');
        }
      }
    } else {
      debugPrint("لا يوجد اتصال بالانترنت");
    }
  }

  Future<void> addToLocalStudentH(String halagaID) async {
    try {
      if (await isConnected()) {
        List<StudentModel> responseFirebase =
            await firebasehelper.getStudentHalaqa(halagaID);
        // debugPrint("responseFirebase = $responseFirebase");
        for (var student in responseFirebase) {
          bool exists = await sqlDb.checkIfitemExists2(
              "Students", student.studentID!, "StudentID");
          if (exists) {
            await updateStudent(student, 0);
            debugPrint('===== Find student (update) =====');
          } else {
            await addStudent(student, 0);
            debugPrint('===== Find student (add) =====');
          }
        }
      } else {
        debugPrint("لا يوجد اتصال بالانترنت");
      }
    } catch (e) {
      print(e);
    }
  }

  // addStudentToFirebase2(StudentModel student, int schoolID) async {
  //   print("جاري إضافة الطالب إلى Firebase - معرف المدرسة: ${schoolID}");

  //   // التحقق أولاً من وجود اتصال بالإنترنت
  //   bool hasConnection = await InternetConnectionChecker().hasConnection;
  //   if (!hasConnection) {
  //     print("لا يوجد اتصال بالإنترنت، لا يمكن إضافة الطالب إلى Firebase");
  //     return;
  //   }

  //   int idStudent = await _sqldb.insertData(
  //       "INSERT INTO Students (ElhalagatID, SchoolID, FirstName, MiddleName, grandfatherName, LastName, AttendanceDays, AbsenceDays, Excuse, ReasonAbsence) "
  //       "VALUES ('${student.elhalaqaID}', ${schoolID}, '${student.firstName}', '${student.middleName}', "
  //       "'${student.grandfatherName}', '${student.lastName}', ${student.attendanceDays ?? 'NULL'}, "
  //       "${student.absenceDays ?? 'NULL'}, '${student.excuse ?? ''}', '${student.reasonAbsence ?? ''}')");

  // //   await firebasehelper.addStudent(idStudent, student, schoolID);
  // //   print("تم إرسال بيانات الطالب إلى Firebase");
  // // }

  Future<List<StudentModel>> getStudentsWithoutHalaga(int schoolID) async {
    try {
      List<Map<String, dynamic>> studentData = await _sqldb.readData(
          "SELECT * FROM Students WHERE SchoolID = $schoolID AND (ElhalagatID IS NULL OR ElhalagatID = '' OR ElhalagatID = 'null' OR ElhalagatID = 'NULL')");

      debugPrint(
          "Students without halaga for schoolID $schoolID: ${studentData.length}");

      if (studentData.isEmpty) {
        debugPrint("No students without halaga for school: $schoolID");
        return [];
      }

      List<StudentModel> studentsWithoutHalaga = studentData.map((student) {
        return StudentModel(
          studentID: student['StudentID'],
          schoolId: student['SchoolID'],
          firstName: student['FirstName'],
          middleName: student['MiddleName'],
          grandfatherName: student['grandfatherName'],
          lastName: student['LastName'],
          elhalaqaID: null, // نحدد بشكل صريح أن هؤلاء الطلاب ليس لديهم حلقة
        );
      }).toList();

      return studentsWithoutHalaga;
    } catch (e) {
      debugPrint("Error fetching students without halaga: $e");
      return [];
    }
  }

  Future<void> assignStudentsToHalaga(
      List<String> studentIds, String halagaID) async {
    try {
      for (String studentId in studentIds) {
        await assignStudentToHalqa(studentId, halagaID);
      }

      // Update the student count for the halaga
      final count = await _sqldb.readData(
          "SELECT COUNT(*) as count FROM Students WHERE ElhalagatID = '$halagaID'");
      final studentCount = count[0]['count'] as int;
      int halagaResponse = await _sqldb.updateData(
          "UPDATE Elhalagat SET NumberStudent = $studentCount WHERE halagaID = '$halagaID'");
      developer.log(
          "Updated NumberStudent to $studentCount for halqa $halagaID, response: $halagaResponse");
    } catch (e) {
      developer.log("Error assigning students to halaga: $e");
      rethrow;
    }
  }

  Future<Set<StudentModel>> getGlobalStudents() async {
    final db = await sqlDb.database;
    List<Map<String, dynamic>> request = await db.query('Students');
    return request.map((m) => StudentModel.fromJson(m)).toSet();
  }
}

StudentController studentController = StudentController();
