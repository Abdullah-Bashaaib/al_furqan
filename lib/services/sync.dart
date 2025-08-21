import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/message_controller.dart';
import 'package:al_furqan/controllers/school_controller.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/conservation_plan_model.dart';
import 'package:al_furqan/models/eltlawah_plan_model.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/islamic_studies_model.dart';
import 'package:al_furqan/models/messages_model.dart';
import 'package:al_furqan/models/schools_model.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Sync {
  Future<void> syncUsers() async {
    debugPrint('===== sync Users =====');
    List<Map<String, dynamic>> map =
        await sqlDb.readDataID("Users", 'isSync', 0);
    if (map.isNotEmpty) {
      debugPrint('===== map.isNotEmpty =====');
      List<UserModel> users = map.map((map) => UserModel.fromMap(map)).toList();
      for (var user in users) {
        bool exists =
            await firebasehelper.checkDocumentExists2('Users', user.user_id!);
        if (exists) {
          user.isSync = 1;
          await firebasehelper.updateUser(user);
          await userController.updateUser(user, 0);
          // await sqlDb.updateData(
          //     'update Users set isSync = 1 where user_id = ${user.user_id}');
          debugPrint('===== sync user (update) =====');
        } else {
          user.isSync = 1;
          await firebasehelper.addUser(user);
          await userController.updateUser(user, 0);
          // await sqlDb.updateData(
          //     'update Users set isSync = 1 where user_id = ${user.user_id}');
          debugPrint('===== sync user (add) =====');
        }
      }
    } else {
      debugPrint('===== map.isEmpty =====');
    }
  }

  Future<void> syncSchool() async {
    debugPrint('===== sync School =====');
    List<Map<String, dynamic>> map =
        await sqlDb.readDataID("Schools", 'isSync', 0);
    if (map.isNotEmpty) {
      debugPrint('===== map.isNotEmpty =====');
      List<SchoolModel> schools =
          map.map((map) => SchoolModel.fromJson(map)).toList();
      for (var school in schools) {
        bool exists = await firebasehelper.checkDocumentExists(
            'School', school.schoolID!);
        if (exists) {
          school.isSync = 1;
          await firebasehelper.updateSchool(school);
          await schoolController.updateSchool(school, 0);
          debugPrint('===== sync school (update) =====');
        } else {
          school.isSync = 1;
          await firebasehelper.addSchool(school);
          await schoolController.updateSchool(school, 0);

          debugPrint('===== sync school (add) =====');
        }
      }
    } else {
      debugPrint('===== map.isEmpty =====');
    }
  }

  Future<void> syncMessage() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> map =
        await sqlDb.readDataID("messages", 'sync', 0);
    if (map.isNotEmpty) {
      debugPrint('===== map.isNotEmpty =====');
      debugPrint('===== sync Message =====');
      List<Message> messages = map.map((map) => Message.fromMap(map)).toList();
      for (var message in messages) {
        bool exists =
            await firebasehelper.checkDocumentExists('messages', message.id!);
        if (exists) {
          message.sync = 1;
          await _firestore
              .collection('messages')
              .doc(message.id.toString())
              .update(message.toJson());
          await messageController.updateMessage(message);
          debugPrint('===== sync message (update) =====');
        } else {
          message.sync = 1;
          await _firestore.collection('messages').add(message.toJson());
          await messageController.updateMessage(message);
          debugPrint('===== sync message (add) =====');
        }
      }
    } else {
      debugPrint('===== map.isEmpty =====');
    }
  }

// Future<void> syncActivities() async {
//     debugPrint('===== sync Activities =====');
//     List<Map<String, dynamic>> map =
//         await sqlDb.readDataID("Activities", 'isSync', 0);
//     if (map.isNotEmpty) {
//       debugPrint('===== map.isNotEmpty =====');
  // List<ActivitiesModel> Activities = map.map((map) => ActivitiesModel.fromJson(map)).toList();
  // for (var Activitie in Activities) {
  // bool exists =
  // await firebasehelper.checkDocumentExists('Activities', Activitie.ActivityID!);
  // if (exists) {
  // await firebasehelper.updateActivitie(Activitie, Activitie.ActivityID!);

  //   await sqlDb.updateData(
  //       'update Activities set isSync = 1 where ActivityID = ${Activitie.ActivityID}');
  //   debugPrint('===== sync Activitie (update) =====');

  // } else {
  // await firebasehelper.addActivitie(Activities, Activitie.ActivityID!);
  // await sqlDb.updateData(
  // 'update Activities set isSync = 1 where ActivityID = ${Activitie.ActivityID}');

  // debugPrint('===== sync school (add) =====');
  // }
  //     }
  //   } else {
  //     debugPrint('===== map.isEmpty =====');
  //   }
  // }

  Future<void> syncElhalagat() async {
    debugPrint('===== sync Elhalagat =====');
    List<Map<String, dynamic>> map =
        await sqlDb.readDataID("Elhalagat", 'isSync', 0);
    if (map.isNotEmpty) {
      debugPrint('===== map.isNotEmpty =====');
      List<HalagaModel> halagas =
          map.map((map) => HalagaModel.fromJson(map)).toList();
      for (var halaga in halagas) {
        bool exists = await firebasehelper.checkDocumentExists2(
            'Elhalagat', halaga.halagaID!);
        if (exists) {
          halaga.isSync = 1;
          await firebasehelper.updateHalaga(halaga);
          await halagaController.updateHalaga(halaga, 0);
          await sqlDb.updateData(
              'update Elhalagat set isSync = 1 where halagaID = ${halaga.halagaID}');
          debugPrint('===== sync Elhalagat (update) =====');
        } else {
          halaga.isSync = 1;
          await firebasehelper.updateHalaga(halaga);
          await halagaController.updateHalaga(halaga, 0);
          debugPrint('===== sync Elhalagat (add) =====');
        }
      }
    } else {
      debugPrint('===== map.isEmpty =====');
    }
  }

  Future<void> syncIslamicStudies() async {
    final db = await sqlDb.database;
    debugPrint('===== sync IslamicStudies =====');
    List<Map<String, dynamic>> map =
        await sqlDb.readDataID("IslamicStudies", 'isSync', 0);
    if (map.isNotEmpty) {
      debugPrint('===== map.isNotEmpty =====');
      List<IslamicStudiesModel> IslamicStudies =
          map.map((map) => IslamicStudiesModel.fromMap(map)).toList();
      for (var IslamicStudy in IslamicStudies) {
        bool exists = await firebasehelper.checkDocumentExists(
            'IslamicStudies', int.parse(IslamicStudy.islamicStudiesID!));
        if (exists) {
          IslamicStudy.isSync = 1;
          await firebasehelper.updateIslamicStudyplan(
              IslamicStudy, IslamicStudy.islamicStudiesID!);

          await db.update("IslamicStudies",
              IslamicStudy.toMap()..remove(IslamicStudy.islamicStudiesID),
              where: 'IslamicStudiesID = ?',
              whereArgs: [IslamicStudy.islamicStudiesID]);
          debugPrint('===== sync IslamicStudies (update) =====');
        } else {
          IslamicStudy.isSync = 1;
          await firebasehelper.addIslamicStudyplan(
              IslamicStudy, IslamicStudy.islamicStudiesID!);
          await db.update("IslamicStudies",
              IslamicStudy.toMap()..remove(IslamicStudy.islamicStudiesID),
              where: 'IslamicStudiesID = ?',
              whereArgs: [IslamicStudy.islamicStudiesID]);
          debugPrint('===== sync IslamicStudies (add) =====');
        }
      }
    } else {
      debugPrint('===== map.isEmpty =====');
    }
  }

  Future<void> syncConservationPlan() async {
    final db = await sqlDb.database;
    debugPrint('===== sync ConservationPlans =====');
    List<Map<String, dynamic>> map =
        await sqlDb.readDataID("ConservationPlans", 'isSync', 0);
    if (map.isNotEmpty) {
      debugPrint('===== map.isNotEmpty =====');
      List<ConservationPlanModel> conservationPlans =
          map.map((map) => ConservationPlanModel.fromMap(map)).toList();
      for (var conservationPlan in conservationPlans) {
        bool exists = await firebasehelper.checkDocumentExists2(
            'ConservationPlans', conservationPlan.conservationPlanId!);
        if (exists) {
          conservationPlan.isSync = 1;
          await firebasehelper.updateConservationPlan(
              conservationPlan, conservationPlan.conservationPlanId!);

          await db.update(
              "ConservationPlans",
              conservationPlan.toMap()
                ..remove(conservationPlan.conservationPlanId),
              where: 'ConservationPlanID = ?',
              whereArgs: [conservationPlan.conservationPlanId]);
          debugPrint('===== sync ConservationPlan (update) =====');
        } else {
          conservationPlan.isSync = 1;
          await firebasehelper.addConservationPlan(
              conservationPlan, conservationPlan.conservationPlanId!);
          await db.update(
              "ConservationPlans",
              conservationPlan.toMap()
                ..remove(conservationPlan.conservationPlanId),
              where: 'ConservationPlanID = ?',
              whereArgs: [conservationPlan.conservationPlanId]);
          debugPrint('===== sync ConservationPlan (add) =====');
        }
      }
    } else {
      debugPrint('===== map.isEmpty =====');
    }
  }

  Future<void> synsEltlawahPlan() async {
    final db = await sqlDb.database;
    debugPrint('===== sync EltlawahPlan =====');
    List<Map<String, dynamic>> map =
        await sqlDb.readDataID("EltlawahPlans", 'isSync', 0);
    if (map.isNotEmpty) {
      debugPrint('===== map.isNotEmpty =====');
      List<EltlawahPlanModel> eltlawahPlans =
          map.map((map) => EltlawahPlanModel.fromMap(map)).toList();
      for (var eltlawahPlan in eltlawahPlans) {
        bool exists = await firebasehelper.checkDocumentExists(
            'EltlawahPlans', int.parse(eltlawahPlan.eltlawahPlanId!));
        if (exists) {
          eltlawahPlan.isSync = 1;
          await firebasehelper.updateEltlawahPlan(
              eltlawahPlan, eltlawahPlan.eltlawahPlanId!);

          await db.update("EltlawahPlans",
              eltlawahPlan.toMap()..remove(eltlawahPlan.eltlawahPlanId),
              where: 'EltlawahPlanID = ?',
              whereArgs: [eltlawahPlan.eltlawahPlanId]);
          await db.update("EltlawahPlans",
              eltlawahPlan.toMap()..remove(eltlawahPlan.eltlawahPlanId),
              where: 'EltlawahPlanID = ?',
              whereArgs: [eltlawahPlan.eltlawahPlanId]);
          debugPrint('===== sync EltlawahPlan (update) =====');
        } else {
          eltlawahPlan.isSync = 1;
          await firebasehelper.addEltlawahPlan(
              eltlawahPlan, eltlawahPlan.eltlawahPlanId!);
          await db.update("EltlawahPlans",
              eltlawahPlan.toMap()..remove(eltlawahPlan.eltlawahPlanId),
              where: 'EltlawahPlanID = ?',
              whereArgs: [eltlawahPlan.eltlawahPlanId]);
          debugPrint('===== sync EltlawahPlan (add) =====');
        }
      }
    } else {
      debugPrint('===== map.isEmpty =====');
    }
  }

  Future<void> syncStudents() async {
    final db = await sqlDb.database;
    debugPrint('===== sync Students =====');
    List<Map<String, dynamic>> map =
        await sqlDb.readDataID("Students", 'isSync', 0);
    if (map.isNotEmpty) {
      debugPrint('===== map.isNotEmpty =====');
      List<StudentModel> students =
          map.map((map) => StudentModel.fromJson(map)).toList();
      for (var student in students) {
        bool exists = await firebasehelper.checkDocumentExists2(
            'Students', student.studentID!);
        if (exists) {
          student.isSync = 1;
          await firebasehelper.updateStudentData(student);
          await studentController.updateStudent(student, 0);
          // await sqlDb.updateData(
          //     'update Students set isSync = 1 where StudentID = ${student.studentID}');
          debugPrint('===== sync Student (update) =====');
        } else {
          student.isSync = 1;
          await firebasehelper.addStudent(student);
          await studentController.updateStudent(student, 0);
          // await sqlDb.updateData(
          //     'update Students set isSync = 1 where StudentID = ${student.studentID}');

          debugPrint('===== sync Student (add) =====');
        }
      }
    } else {
      debugPrint('===== map.isEmpty =====');
    }
  }

  // Future<void> syncMonthlyReports() async {
  //   debugPrint('===== sync MonthlyReports =====');
  //   List<Map<String, dynamic>> map =
  //       await sqlDb.readDataID("MonthlyReports", 'isSync', 0);
  //   if (map.isNotEmpty) {
  //     debugPrint('===== map.isNotEmpty =====');
  //     List<MonthlyReportModel> monthlyReports = map.map((map) => MonthlyReportModel.fromJson(map)).toList();
  //     for (var monthlyReport in monthlyReports) {
  //       bool exists =
  //           await firebasehelper.checkDocumentExists('MonthlyReports', monthlyReport.monthlyReportID!);
  //       if (exists) {
  //         await firebasehelper.updateMonthlyReport(monthlyReport, monthlyReport.monthlyReportID!);

  //         await sqlDb.updateData(
  //             'update MonthlyReports set isSync = 1 where MonthlyReportID = ${monthlyReport.monthlyReportID}');
  //         debugPrint('===== sync MonthlyReport (update) =====');

  //       } else {
  //         await firebasehelper.addMonthlyReport(monthlyReport, monthlyReport.monthlyReportID!);
  //         await sqlDb.updateData(
  //             'update MonthlyReports set isSync = 1 where MonthlyReportID = ${monthlyReport.monthlyReportID}');

  //         debugPrint('===== sync MonthlyReport (add) =====');
  //       }
  //     }
  //   } else {
  //     debugPrint('===== map.isEmpty =====');
  //   }
  // }

  // Future<void> syncRecommendations() async {
  //   debugPrint('===== sync Recommendations =====');
  //   List<Map<String, dynamic>> map =
  //       await sqlDb.readDataID("Recommendations", 'isSync', 0);
  //   if (map.isNotEmpty) {
  //     debugPrint('===== map.isNotEmpty =====');
  //     List<RecommendationModel> recommendations = map.map((map) => RecommendationModel.fromJson(map)).toList();
  //     for (var recommendation in recommendations) {
  //       bool exists =
  //           await firebasehelper.checkDocumentExists('Recommendations', recommendation.recommendationsID!);
  //       if (exists) {
  //         await firebasehelper.updateRecommendation(recommendation, recommendation.recommendationsID!);

  //         await sqlDb.updateData(
  //             'update Recommendations set isSync = 1 where RecommendationsID = ${recommendation.recommendationsID}');
  //         debugPrint('===== sync Recommendation (update) =====');

  //       } else {
  //         await firebasehelper.addRecommendation(recommendation, recommendation.recommendationsID!);
  //         await sqlDb.updateData(
  //             'update Recommendations set isSync = 1 where RecommendationsID = ${recommendation.recommendationsID}');

  //         debugPrint('===== sync Recommendation (add) =====');
  //       }
  //     }
  //   } else {
  //     debugPrint('===== map.isEmpty =====');
  //   }
  // }

  // Future<void> syncActivityTypes() async {
  //   debugPrint('===== sync ActivityTypes =====');
  //   List<Map<String, dynamic>> map =
  //       await sqlDb.readDataID("ActivityTypes", 'isSync', 0);
  //   if (map.isNotEmpty) {
  //     debugPrint('===== map.isNotEmpty =====');
  //     // List<StudentModel> students = map.map((map) => StudentModel.fromJson(map)).toList();
  //     // for (var student in students) {
  //       // bool exists =
  //           // await firebasehelper.checkDocumentExists('Students', student.studentID!);
  //       // if (exists) {
  //         //  await firebasehelper.updateStudentData(student);

  //         // await sqlDb.updateData(
  //         //     'update Students set isSync = 1 where StudentID = ${student.studentID}');
  //         // debugPrint('===== sync Student (update) =====');

  //       } else {
  //          await firebasehelper.addStudent(student, student.schoolId!);
  //         await sqlDb.updateData(
  //             'update Students set isSync = 1 where StudentID = ${student.studentID}');

  //         debugPrint('===== sync Student (add) =====');
  //       }
  //     }
  //   } else {
  //     debugPrint('===== map.isEmpty =====');
  //   }
  // }
}

Sync sync = Sync();
