// This file contains Firebase service code, remove it entirely if not needed.
import 'dart:developer';
import 'package:al_furqan/models/conservation_plan_model.dart';
import 'package:al_furqan/models/eltlawah_plan_model.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/islamic_studies_model.dart';
import 'package:al_furqan/models/schools_model.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //  UserColl = _firestore.collection('Users');

  // ======================= Start Student ==============
  Future<void> addStudent(StudentModel StudentData) async {
    final StudentRef = _firestore.collection('Students');

    // StudentData.schoolId = schoolID;
    try {
      StudentData.isSync = 1;
      await StudentRef.doc(StudentData.studentID.toString())
          .set(StudentData.toMap());
      debugPrint(
          'تمت إضافة/تحديث الطالب بالرقم ${StudentData.studentID} بنجاح ');
    } catch (e) {
      debugPrint('خطأ أثناء إضافة الطالب إلى Firebase: $e');
    }
  }

  Future<List<StudentModel>> getTotalStudents() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Students').get();

      if (snapshot.docs.isNotEmpty) {
        debugPrint('تم العثور على مستند');
        return snapshot.docs
            .map((doc) =>
                StudentModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('لا توجد مستندات تطابق الشرط');
        return [];
      }
    } catch (e) {
      debugPrint('خطأ أثناء جلب البيانات: $e');
      return [];
    }
  }

  Future<List<StudentModel>> getStudentData(int id) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Students')
          .where('SchoolID', isEqualTo: id)
          .get();

      if (snapshot.docs.isNotEmpty) {
        debugPrint('تم العثور على مستند');
        return snapshot.docs
            .map((doc) =>
                StudentModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('لا توجد مستندات تطابق الشرط');
        return [];
      }
    } catch (e) {
      debugPrint('خطأ أثناء جلب البيانات: $e');
      return [];
    }
  }

  Future<List<StudentModel>> getStudentHalaqa(String id) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Students')
          .where('ElhalagatID', isEqualTo: id)
          .get();

      if (snapshot.docs.isNotEmpty) {
        debugPrint('تم العثور على مستند');
        return snapshot.docs
            .map((doc) =>
                StudentModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('لا توجد مستندات تطابق الشرط');
        return [];
      }
    } catch (e) {
      debugPrint('خطأ أثناء جلب البيانات: $e');
      return [];
    }
  }

  Future<void> updateStudentData(StudentModel student) async {
    student.isSync = 1;
    final docRef =
        _firestore.collection('Students').doc(student.studentID.toString());
    await docRef.update(student.toMap()).then((_) {
      debugPrint('تم التعديل بنجاح');
    }).catchError((error) {
      debugPrint('حدث خطأ: $error');
    });
  }

  // Future<void> updateStudentByHalaga(
  //     String halagaID, StudentModel student) async {
  //   try {
  //     await _firestore
  //         .collection("Students")
  //         .doc(halagaID)
  //         .update(student.toMap());
  //   } on Exception catch (e) {
  //     log("Error in Update Student By Halaga ID : $e");
  //   }
  // }

  // Future<void> updateTeacherByHalagaID(
  //     String halagaID, UserModel teacher) async {
  //   try {
  //     await _firestore
  //         .collection("Users")
  //         .doc(halagaID)
  //         .update(teacher.toMap());
  //   } on Exception catch (e) {
  //     log("Error in Update Teacher By Halaga ID : $e");
  //   }
  // }

  assignStudentToHalqa(String studentId, String halqaID) async {
    try {
      final docRef = _firestore.collection('Students').doc(studentId);
      await docRef.update({'ElhalagatID': halqaID});
    } catch (e) {
      debugPrint('error=== $e');
    }
  }
// ===================== End Student ===========================

// =========================== Start School =============================

  Future<List<SchoolModel>> getSchool() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('School').get();

      if (querySnapshot.docs.isNotEmpty) {
        debugPrint('تم العثور على المدارس');
        return querySnapshot.docs
            .map((doc) =>
                SchoolModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('لا توجد مدارس');
        return [];
      }
    } catch (e) {
      debugPrint('خطأ أثناء جلب بيانات المدارس: $e');
      return [];
    }
  }

  addSchool(SchoolModel school) async {
    final docRef = _firestore.collection('School');
    await docRef.doc(school.schoolID.toString()).set({
      'SchoolID': school.schoolID,
      'school_name': school.school_name,
      'school_location': school.school_location,
      'isSync': 1,
    });
    debugPrint('تم إضافة المدرسة ${school.schoolID} بنجاح');
  }

  updateSchool(SchoolModel school) async {
    final docRef =
        _firestore.collection('School').doc(school.schoolID.toString());
    await docRef.update({
      'school_name': school.school_name,
      'school_location': school.school_location,
      'isSync': 1,
    });
    debugPrint('تم تحديث المدرسة ${school.schoolID} بنجاح');
  }

  /// حذف مدرسة من Firebase
  Future<void> deleteSchool(int schoolId) async {
    try {
      final docRef = _firestore.collection('School').doc(schoolId.toString());
      await docRef.delete();
      debugPrint('تم حذف المدرسة $schoolId من Firebase بنجاح');
    } catch (e) {
      debugPrint('خطأ في حذف المدرسة من Firebase: $e');
      rethrow;
    }
  }

// ========================== End School ================================

// =========================== Start Elhalaga ===========================

  Future<HalagaModel?> getElhalaga(String halagaID) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('Elhalaga')
          .where('halagaID', isEqualTo: halagaID)
          .get();

      if (query.docs.isNotEmpty) {
        debugPrint('تم العثور على حلقة');
        return HalagaModel.fromJson(
            query.docs.first.data() as Map<String, dynamic>);
      } else {
        debugPrint('لا توجد حلقة تطابق الشرط');
        return null;
      }
    } catch (e) {
      debugPrint('خطأ أثناء جلب بيانات الحلقة: $e');
      return null;
    }
  }

//get data from elhalaga collection on schoolID
  Future<List<Map<String, dynamic>>> getElhalagaData(int schoolID) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Elhalaga')
          .where('SchoolID', isEqualTo: schoolID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        debugPrint('تم العثور على حلقات');
        return querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      } else {
        debugPrint('لا توجد حلقات تطابق الشرط');
        return [];
      }
    } catch (e) {
      debugPrint('خطأ أثناء جلب بيانات الحلقات: $e');
      return [];
    }
  }

  addHalga(HalagaModel halaga) async {
    try {
      final docRef = _firestore.collection('Elhalaga');
      docRef.doc(halaga.halagaID.toString()).set(halaga.toMap());
      debugPrint('===== تم رفع حلقة ${halaga.Name} بنجاح');
    } catch (e) {}
  }

  updateHalaga(HalagaModel halaga) async {
    try {
      final docRef = _firestore.collection('Elhalaga');
      docRef.doc(halaga.halagaID.toString()).update(halaga.toMap());
    } catch (e) {
      debugPrint('error ==== $e');
    }
  }

  Future<void> studentCancel(String halagaID) async {
    try {
      final docRef = _firestore.collection("Students");

      final qureySnapshot =
          await docRef.where('ElhalagatID', isEqualTo: halagaID).get();
      if (qureySnapshot.docs.isNotEmpty) {
        for (var doc in qureySnapshot.docs) {
          // تحديث ElhalagatID إلى null لكل طالب مرتبط بهذه الحلقة
          await docRef.doc(doc.id).update({'ElhalagatID': null});
        }
        debugPrint('تم إلغاء ارتباط الطلاب بالحلفة بنجاح من Firebase');
      } else {
        debugPrint('لا يوجد طلاب مرتبطين بهذه الحلقة');
      }
    } catch (e) {
      log("### Error in Cancel Students : $e");
    }
  }

  /// الغاء ارتباط المعلم بالحلقة
  Future<void> teacherCancel(String halagaId) async {
    try {
      final docRef = _firestore.collection('Users');

      // ابحث عن المستخدم الذي لديه نفس ElhalagatID
      final querySnapshot = await docRef
          .where('ElhalagatID', isEqualTo: halagaId)
          .where('roleID', isEqualTo: 2) // للتأكد أنه معلم
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        // تحديث ElhalagatID إلى null
        await docRef.doc(docId).update({'ElhalagatID': null});

        debugPrint('تم إلغاء ارتباط المعلم بالحلفة بنجاح من Firebase');
      } else {
        debugPrint('لم يتم العثور على معلم مرتبط بهذه الحلقة');
      }
    } catch (e) {
      debugPrint('حدث خطأ أثناء إلغاء ارتباط المعلم: $e');
    }
  }

  newTeacher(String halagaId, String teacherId) async {
    try {
      final docRef = _firestore.collection('Users');
      await docRef.doc(teacherId.toString()).update({'ElhalagatID': halagaId});
    } catch (e) {
      debugPrint('error====$e');
    }
  }

// =========================== End Elhalaga ==============================

// =========================== Start User ===============================

  Future<UserModel?> getUserByPhone(String phone) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('phone_number',
              isEqualTo: int.parse(phone)) // البحث حسب رقم الهاتف
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return UserModel.fromMap(data); // تحويله إلى UserModel
      } else {
        print('❌ لا يوجد مستخدم بهذا الرقم');
        return null;
      }
    } catch (e) {
      print('⚠️ خطأ في جلب المستخدم: $e');
      return null;
    }
  }

  addUser(UserModel user) async {
    debugPrint("addUser(UserModel user)");
    final docRef = _firestore.collection('Users');
    // user.user_id = id;
    await docRef.doc(user.user_id.toString()).set(user.toMap());
    debugPrint("تمت اضافة المستخدم ${user.user_id} بنجاح");
  }

  updateUser(UserModel user) async {
    final docRef = _firestore.collection('Users').doc(user.user_id.toString());
    // user.user_id = id;
    await docRef.update(user.toMap()).then((_) {
      debugPrint('تم التعديل بنجاح');
    }).catchError((error) {
      debugPrint('حدث خطأ: $error');
    });
  }

  deleteUser(String id) async {
    try {
      final docRef = _firestore.collection('Users').doc(id.toString());
      await docRef.delete();
      debugPrint('تم حذف المستخدم $id بنجاح');
    } catch (e) {
      debugPrint('حدث خطأ: $e');
    }
  }

  activateUser(String id) async {
    try {
      final docRef = _firestore.collection('Users').doc(id);
      await docRef.update({'isSync': 1});
      await docRef.update({'isActivate': 1});
      debugPrint('تم تفعيل المستخدم $id بنجاح');
    } catch (e) {
      debugPrint('حدث خطأ: $e');
    }
  }

  deactivateUser(int id) async {
    try {
      final docRef = _firestore.collection('Users').doc(id.toString());
      await docRef.update({'isActivate': 0});
      debugPrint('تم تعطيل المستخدم $id بنجاح');
    } catch (e) {
      debugPrint('حدث خطأ: $e');
    }
  }

  addRequest(UserModel user) async {
    try {
      final docRef = _firestore.collection('Users').doc(user.user_id);
      docRef.set(user.toMap());
      debugPrint("تمت اضافة الطلب ${user.user_id} بنجاح");
    } catch (e) {
      debugPrint('حدث خطأ: $e');
    }
  }

  Future<UserModel?> getUserByPhoneNumber(int phoneNumber) async {
    try {
      final docRef = _firestore.collection('Users');
      final snapshot = await docRef
          .where('phone_number', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromMap(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      debugPrint('حدث خطأ: $e');
      return null;
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      final docRef = _firestore.collection('Users');
      final snapshot = await docRef.get();
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } catch (e) {
      log('حدث خطأ: $e');
      return [];
    }
  }

  // Generate verification code for a request

  // تحديث كلمة المرور في Firestore

  Future<void> getAllTeacher() async {}

  // =========================== End User =================================

  Future<bool> checkDocumentExists(String collection, int id) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(id.toString())
          .get();
      debugPrint("Find document");
      return documentSnapshot.exists;
    } catch (e) {
      debugPrint('Not found document');
      return false;
    }
  }

  Future<bool> checkDocumentExists2(String collection, String id) async {
    try {
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection(collection).doc(id).get();
      debugPrint("Find document");
      return documentSnapshot.exists;
    } catch (e) {
      debugPrint('Not found document');
      return false;
    }
  }

//   ================== Plans FireBase Method Start ====================
  Future<void> addConservationPlan(
      ConservationPlanModel plan, String idDoc) async {
    try {
      await _firestore
          .collection("ConservationPlans")
          .doc(idDoc)
          .set(plan.toMap());
      debugPrint(
          "---------------> The addConservationPlan in ((FirebaseService)) : Done");
    } catch (e) {
      debugPrint(
          "---------------> The Error in addConservationPlan in ((FirebaseService)) : $e");
    }
  }

  Future<void> addEltlawahPlan(EltlawahPlanModel plan, String idDoc) async {
    try {
      await _firestore.collection("EltlawahPlans").doc(idDoc).set(plan.toMap());
      debugPrint(
          "---------------> The addEltlawahPlan in ((FirebaseService)) : Done");
    } catch (e) {
      debugPrint(
          "---------------> The Error in addEltlawahPlan in ((FirebaseService)) : $e");
    }
  }

  Future<void> addIslamicStudyplan(
      IslamicStudiesModel plan, String idDoc) async {
    try {
      await _firestore
          .collection("IslamicStudies")
          .doc(idDoc)
          .set(plan.toMap());
      debugPrint(
          "---------------> The addIslamicStudyplan in ((FirebaseService)) : Done");
    } catch (e) {
      debugPrint(
          "---------------> The Error in addIslamicStudyplan in ((FirebaseService)) : $e");
    }
  }

  //===================== Update ConservationPlan =================
  Future<void> updateConservationPlan(
      ConservationPlanModel plan, String idDoc) async {
    try {
      await _firestore
          .collection("ConservationPlans")
          .doc(idDoc)
          .update(plan.toMap());
      debugPrint(
          "---------------> The updateConservationPlan in ((FirebaseService)) : Done");
    } catch (e) {
      debugPrint(
          "---------------> The Error in updateConservationPlan in ((FirebaseService)) : $e");
    }
  }

  //===================== Update EltlawahPlan =================
  Future<void> updateEltlawahPlan(EltlawahPlanModel plan, String idDoc) async {
    try {
      await _firestore
          .collection("EltlawahPlans")
          .doc(idDoc)
          .update(plan.toMap());
      debugPrint(
          "---------------> The updateEltlawahPlan in ((FirebaseService)) : Done");
    } catch (e) {
      debugPrint(
          "---------------> The Error in updateEltlawahPlan in ((FirebaseService)) : $e");
    }
  }

  //===================== Update IslamicStudyplan =================
  Future<void> updateIslamicStudyplan(
      IslamicStudiesModel plan, String idDoc) async {
    try {
      await _firestore
          .collection("IslamicStudies")
          .doc(idDoc)
          .update(plan.toMap());
      debugPrint(
          "---------------> The updateIslamicStudyplan in ((FirebaseService)) : Done");
    } catch (e) {
      debugPrint(
          "---------------> The Error in updateIslamicStudyplan in ((FirebaseService)) : $e");
    }
  }

  //===================== Delete ConservationPlan =================
  Future<void> deleteConservationPlan(String idDoc) async {
    try {
      await _firestore.collection("ConservationPlans").doc(idDoc).delete();
      debugPrint(
          "---------------> The deleteConservationPlan in ((FirebaseService)) : Done");
    } catch (e) {
      debugPrint(
          "---------------> The Error in deleteConservationPlan in ((FirebaseService)) : $e");
    }
  }

  //===================== Delete EltlawahPlan =================
  Future<void> deleteEltlawahPlan(String idDoc) async {
    try {
      await _firestore.collection("EltlawahPlans").doc(idDoc).delete();
      debugPrint(
          "---------------> The deleteEltlawahPlan in ((FirebaseService)) : Done");
    } catch (e) {
      debugPrint(
          "---------------> The Error in deleteEltlawahPlan in ((FirebaseService)) : $e");
    }
  }

  //===================== Delete IslamicStudyplan =================
  Future<void> deleteIslamicStudyplan(String idDoc) async {
    try {
      await _firestore.collection("IslamicStudies").doc(idDoc).delete();
      debugPrint(
          "---------------> The deleteIslamicStudyplan in ((FirebaseService)) : Done");
    } catch (e) {
      debugPrint(
          "---------------> The Error in deleteIslamicStudyplan in ((FirebaseService)) : $e");
    }
  }

  //===================== Update Attendance =================
  Future<void> updateAttendance(
      String studentID, bool isPresent, String absenceReasons) async {
    try {
      // الحصول على بيانات الطالب الحالية من Firestore
      var studentDoc = await _firestore
          .collection("Students")
          .doc(studentID.toString())
          .get();

      if (studentDoc.exists) {
        var studentData = studentDoc.data();

        // استخراج قيم الحضور والغياب الحالية
        int currentAttendance = studentData?['AttendanceDays'] ?? 0;
        int currentAbsence = studentData?['AbsenceDays'] ?? 0;

        // تحديث القيم بناءً على حالة الحضور
        if (isPresent) {
          await _firestore
              .collection("Students")
              .doc(studentID.toString())
              .update({
            "AttendanceDays": currentAttendance + 1,
            "isSync": 1, // إضافة هذا السطر لتحديث حالة المزامنة
          });
        } else {
          await _firestore
              .collection("Students")
              .doc(studentID.toString())
              .update({
            "AbsenceDays": currentAbsence + 1,
            "ReasonAbsence": absenceReasons,
            "isSync": 1, // إضافة هذا السطر لتحديث حالة المزامنة
          });
        }

        log("---------------> تم تحديث بيانات الحضور في Firestore بنجاح");
      } else {
        log("---------------> لم يتم العثور على الطالب في Firestore برقم: $studentID");
      }
    } catch (e) {
      log("---------------> خطأ في تحديث بيانات الحضور في Firestore: $e");
    }
  }

  Future<List<ConservationPlanModel>> getConservationPlans(
      String halagaId) async {
    try {
      print('0000000000000000000000000000000000');
      // جلب الخطط من مجموعة ConservationPlans حيث elhalagatId يساوي halagaId
      final QuerySnapshot querySnapshot = await _firestore
          .collection('ConservationPlans')
          .where('ElhalagatID', isEqualTo: halagaId)
          .get();

      debugPrint(
          "-------------------> Found ${querySnapshot.docs.length} conservation plans");

      // تحويل البيانات إلى نماذج ConservationPlanModel
      List<ConservationPlanModel> plans = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ConservationPlanModel(
          conservationPlanId: data['ConservationPlanID'],
          elhalagatId: data['ElhalagatID'],
          studentId: data['StudentID'],
          plannedStartSurah: data['PlannedStartSurah'],
          plannedStartAya: data['PlannedStartAya'],
          plannedEndSurah: data['PlannedEndSurah'],
          plannedEndAya: data['PlannedEndAya'],
          executedStartSurah: data['ExecutedStartSurah'],
          executedStartAya: data['ExecutedStartAya'],
          executedEndSurah: data['ExecutedEndSurah'],
          executedEndAya: data['ExecutedEndAya'],
          executedRate: data['executedRate']?.toDouble(),
          planMonth: data['PlanMonth'],
          isSync: data['isSync'] ?? 1,
        );
      }).toList();

      // for (var element in plans) {
      //   print('${element.planMonth} ============================');
      // }

      return plans;
    } catch (e) {
      log("-------------------> Error fetching conservation plans: $e");
      throw Exception('فشل في جلب خطط الحفظ: $e');
    }
  }

  /// جلب خطط التلاوة من Firestore
  Future<List<EltlawahPlanModel>> getEltlawahPlans(String halagaId) async {
    try {
      // جلب الخطط من مجموعة EltlawahPlans حيث elhalagatId يساوي halagaId
      final QuerySnapshot querySnapshot = await _firestore
          .collection('EltlawahPlans')
          .where('ElhalagatID', isEqualTo: halagaId)
          .get();

      debugPrint(
          "-------------------> تم العثور على ${querySnapshot.docs.length} خطة تلاوة");

      // تحويل البيانات إلى نماذج EltlawahPlanModel
      List<EltlawahPlanModel> plans = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return EltlawahPlanModel(
          eltlawahPlanId: data['EltlawahPlanID'],
          elhalagatId: data['ElhalagatID'],
          plannedStartSurah: data['PlannedStartSurah'],
          plannedStartAya: data['PlannedStartAya'],
          plannedEndSurah: data['PlannedEndSurah'],
          plannedEndAya: data['PlannedEndAya'],
          executedStartSurah: data['ExecutedStartSurah'],
          executedStartAya: data['ExecutedStartAya'],
          executedEndSurah: data['ExecutedEndSurah'],
          executedEndAya: data['ExecutedEndAya'],
          executedRate: data['ExecutedRate']?.toDouble(),
          planMonth: data['PlanMonth'],
          isSync: data['isSync'] ?? 1,
        );
      }).toList();

      return plans;
    } catch (e) {
      debugPrint("-------------------> خطأ في جلب خطط التلاوة: $e");
      throw Exception('فشل في جلب خطط التلاوة: $e');
    }
  }

  /// جلب خطط العلوم الشرعية من Firestore
  Future<List<IslamicStudiesModel>> getIslamicStudyPlans(
      String halagaId) async {
    try {
      // جلب الخطط من مجموعة IslamicStudies حيث elhalagatId يساوي halagaId
      final QuerySnapshot querySnapshot = await _firestore
          .collection('IslamicStudies')
          .where('ElhalagatID', isEqualTo: halagaId)
          .get();

      debugPrint(
          "-------------------> تم العثور على ${querySnapshot.docs.length} خطة علوم شرعية");

      // تحويل البيانات إلى نماذج IslamicStudiesModel
      List<IslamicStudiesModel> plans = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return IslamicStudiesModel(
          islamicStudiesID: data['IslamicStudiesID'],
          elhalagatID: data['ElhalagatID'],
          subject: data['Subject'],
          plannedContent: data['PlannedContent'],
          executedContent: data['ExecutedContent'],
          planMonth: data['PlanMonth'],
          isSync: data['isSync'] ?? 1,
        );
      }).toList();

      return plans;
    } catch (e) {
      debugPrint("-------------------> خطأ في جلب خطط العلوم الشرعية: $e");
      throw Exception('فشل في جلب خطط العلوم الشرعية: $e');
    }
  }

  delete(String id, String nameTable) {
    try {
      final docRef = _firestore.collection(nameTable);
      docRef.doc(id).delete();
      log("Firebase Delete : $nameTable with id $id");
    } on Exception catch (e) {
      log("Error in Firebase Delete : $e");
    }
  }
} // End of FirebaseHelper class

FirebaseHelper firebasehelper = FirebaseHelper();
