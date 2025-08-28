import 'package:al_furqan/helper/new_id2.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/conservation_plan_model.dart';
import 'package:al_furqan/models/eltlawah_plan_model.dart';
import 'package:al_furqan/models/islamic_studies_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';

class PlanController {
  final SqlDb sqlDb = SqlDb();
  final FirebaseHelper firebasehelper = FirebaseHelper();

  // قوائم لتخزين الخطط
  List<ConservationPlanModel> conservationPlans = [];
  List<EltlawahPlanModel> eltlawahPlans = [];
  List<IslamicStudiesModel> islamicStudyPlans = [];

  Future<int> addConservationPlan2(ConservationPlanModel plan) async {
    try {
      plan.planMonth = DateFormat('yyyy-MM').format(DateTime.now());
      String newConservationPlanID = await getMaxValue();
      plan.conservationPlanId = newConservationPlanID;

      debugPrint(
          "----------> studentId for ConservationPlans is :${plan.studentId}, newConservationPlanID: $newConservationPlanID");

      bool hasConnection =
          await InternetConnectionChecker.createInstance().hasConnection;
      final Map<String, dynamic> planMap = plan.toMap();
      debugPrint("-------------------> Plan Map: $planMap");
      debugPrint(
          "-------------------> Inserting into table: ConservationPlans");
      int result = await sqlDb.insertData2('ConservationPlans', planMap);
      debugPrint(
          "------------------> Add ConservationPlan is : ${result > 0 ? 'Done' : 'Failed'}");

      if (result > 0 && hasConnection) {
        plan.isSync = 1;
        await firebasehelper.addConservationPlan(plan, newConservationPlanID);
        await sqlDb.updateData3(
          'ConservationPlans',
          {'isSync': 1},
          'ConservationPlanID = ?',
          [newConservationPlanID],
        );
        debugPrint("------------------> isSync: Sync Done!");
      } else {
        plan.isSync = 0;
        debugPrint("------------------> isSync: not Sync");
      }

      return result;
    } catch (e) {
      debugPrint(
          "------------------> Error in addConservationPlan in ((planController)) : $e");
      return -1;
    }
  }

  Future<int> addEltlawahPlan2(EltlawahPlanModel plan,
      {bool isForWholeHalaga = true}) async {
    try {
      plan.planMonth = DateFormat('yyyy-MM').format(DateTime.now());
      String newEltlawahPlanID = await getMaxValue();
      plan.eltlawahPlanId = newEltlawahPlanID;

      // // إذا كانت الخطة للحلقة بأكملها، نضع قيمة خاصة لـ studentId
      // if (isForWholeHalaga) {
      //   plan.studentId =
      //       (-1) as String?; // قيمة خاصة تشير إلى أن الخطة للحلقة بأكملها
      //   debugPrint("----------> Adding Eltlawah Plan for the whole Halaga");
      // } else {
      //   debugPrint(
      //       "----------> studentId for EltlawahPlans is :${plan.studentId}");
      // }

      bool hasConnection =
          await InternetConnectionChecker.createInstance().hasConnection;
      final Map<String, dynamic> planMap = plan.toMap();
      int result = await sqlDb.insertData2('EltlawahPlans', planMap);
      debugPrint(
          "------------------> Add EltlawahPlan is : ${result > 0 ? 'Done' : 'Failed'}");

      if (result > 0 && hasConnection) {
        plan.isSync = 1;
        await firebasehelper.addEltlawahPlan(plan, newEltlawahPlanID);
        await sqlDb.updateData3(
          'EltlawahPlans',
          {'isSync': 1},
          'EltlawahPlanID = ?',
          [newEltlawahPlanID],
        );
        debugPrint("------------------> isSync: Sync Done!");
      } else {
        plan.isSync = 0;
        debugPrint("------------------> isSync: not Sync");
      }

      return result;
    } catch (e) {
      debugPrint(
          "------------------> Error in addEltlawahPlan in ((planController)) : $e");
      return -1;
    }
  }

  Future<int> addIslamicStudies2(IslamicStudiesModel plan,
      {bool isForWholeHalaga = true}) async {
    try {
      plan.planMonth = DateFormat('yyyy-MM').format(DateTime.now());
      String newIslamicStudiesID = await getMaxValue();
      plan.islamicStudiesID = newIslamicStudiesID;

      // if (isForWholeHalaga) {
      //   plan.studentID = -1; // قيمة خاصة تشير إلى أن الخطة للحلقة بأكملها
      //   debugPrint("----------> Adding IslamicStudy Plan for the whole Halaga");
      // } else {
      //   debugPrint(
      //       "----------> studentId for IslamicStudy Plans is :${plan.studentID}");
      // }
      // debugPrint(
      //     "----------> studentId for IslamicStudy is :${plan.studentID}");

      bool hasConnection =
          await InternetConnectionChecker.createInstance().hasConnection;
      final Map<String, dynamic> planMap = plan.toMap();
      int result = await sqlDb.insertData2('IslamicStudies', planMap);
      debugPrint(
          "------------------> Add IslamicStudy plan is : ${result > 0 ? 'Done' : 'Failed'}");

      if (result > 0 && hasConnection) {
        plan.isSync = 1;
        await firebasehelper.addIslamicStudyplan(plan, newIslamicStudiesID);
        await sqlDb.updateData3(
          'IslamicStudies',
          {'isSync': 1},
          'IslamicStudiesID = ?',
          [newIslamicStudiesID],
        );
        debugPrint("------------------> isSync: Sync Done!");
      } else {
        plan.isSync = 0;
        debugPrint("------------------> isSync: not Sync");
      }

      return result;
    } catch (e) {
      debugPrint(
          "------------------> Error in addIslamicStudies in ((planController)) : $e");
      return -1;
    }
  }

  Future<List<String>> getAllStudentsHalaga(String halagaId) async {
    final db = await sqlDb.database;
    final result = await db.query(
      'Students',
      columns: ['StudentID'],
      where: 'ElhalagatID = ?',
      whereArgs: [halagaId],
      orderBy: 'StudentID ASC',
    );
    debugPrint("-----> studentsID from DB: $result");
    return result.map((e) => e['StudentID'] as String).toList();
  }

  Future<void> clearAllPlans() async {
    try {
      await sqlDb.deleteData("DELETE FROM ConservationPlans");
      await sqlDb.deleteData("DELETE FROM EltlawahPlans");
      await sqlDb.deleteData("DELETE FROM IslamicStudies");
      debugPrint("All plans deleted successfully");
    } catch (e) {
      debugPrint("Error clearing plans: $e");
    }
  }

  Future<void> getPlans(String halagaId) async {
    try {
      final db = await sqlDb.database;

      // جلب خطط الحفظ
      final conservationResult = await db.query(
        'ConservationPlans',
        where: 'ElhalagatID = ?',
        whereArgs: [halagaId],
      );
      conservationPlans = conservationResult
          .map((e) => ConservationPlanModel.fromMap(e))
          .toList();

      // جلب خطط التلاوة
      final eltlawahResult = await db.query(
        'EltlawahPlans',
        where: 'ElhalagatID = ?',
        whereArgs: [halagaId],
      );
      eltlawahPlans =
          eltlawahResult.map((e) => EltlawahPlanModel.fromMap(e)).toList();

      // جلب خطط العلوم الشرعية
      final islamicResult = await db.query(
        'IslamicStudies',
        where: 'ElhalagatID = ?',
        whereArgs: [halagaId],
      );
      islamicStudyPlans =
          islamicResult.map((e) => IslamicStudiesModel.fromMap(e)).toList();

      debugPrint(
          "-----> Loaded ${conservationPlans.length} Conservation Plans");
      debugPrint("-----> Loaded ${eltlawahPlans.length} Eltlawah Plans");
      debugPrint(
          "-----> Loaded ${islamicStudyPlans.length} Islamic Studies Plans");
    } catch (e) {
      debugPrint("Error loading plans: $e");
      throw Exception("Failed to load plans: $e");
    }
  }

  /// جلب جميع الخطط من فايربيس وإضافتها إلى قاعدة البيانات المحلية
  Future<void> getPlansFirebaseToLocal(String halagaId) async {
    try {
      debugPrint("-------------------> التحقق من اتصال الإنترنت");
      bool hasConnection =
          await InternetConnectionChecker.createInstance().hasConnection;
      if (!hasConnection) {
        debugPrint("-------------------> لا يوجد اتصال بالإنترنت");
        return;
      }

      debugPrint(
          "-------------------> بدء جلب الخطط من فايربيس للحلقة: $halagaId");

      // مسح البيانات القديمة
      await sqlDb.deleteData2(
          'ConservationPlans', 'ElhalagatID', halagaId.toString());
      await sqlDb.deleteData2(
          'EltlawahPlans', 'ElhalagatID', halagaId.toString());
      await sqlDb.deleteData2(
          'IslamicStudies', 'ElhalagatID', halagaId.toString());

      // جلب البيانات الجديدة من فايربيس
      debugPrint("-------------------> جلب خطط الحفظ");
      var responseConservationPlan =
          await firebasehelper.getConservationPlans(halagaId);
      debugPrint("-------------------> جلب خطط التلاوة");
      var responseEltlawahPlan =
          await firebasehelper.getEltlawahPlans(halagaId);
      debugPrint("-------------------> جلب خطط العلوم الشرعية");
      var responseIslamicStudyPlan =
          await firebasehelper.getIslamicStudyPlans(halagaId);

      // إضافة البيانات إلى قاعدة البيانات المحلية
      if (responseConservationPlan.isNotEmpty) {
        debugPrint(
            "-------------------> إضافة ${responseConservationPlan.length} خطة حفظ");
        for (var plan in responseConservationPlan) {
          await sqlDb.insertData2('ConservationPlans', plan.toMap());
        }
        conservationPlans = responseConservationPlan; // تحديث القائمة المحلية
      }

      if (responseEltlawahPlan.isNotEmpty) {
        debugPrint(
            "-------------------> إضافة ${responseEltlawahPlan.length} خطة تلاوة");
        for (var plan in responseEltlawahPlan) {
          await sqlDb.insertData2('EltlawahPlans', plan.toMap());
        }
        eltlawahPlans = responseEltlawahPlan; // تحديث القائمة المحلية
      }

      if (responseIslamicStudyPlan.isNotEmpty) {
        debugPrint(
            "-------------------> إضافة ${responseIslamicStudyPlan.length} خطة علوم شرعية");
        for (var plan in responseIslamicStudyPlan) {
          await sqlDb.insertData2('IslamicStudies', plan.toMap());
        }
        islamicStudyPlans = responseIslamicStudyPlan; // تحديث القائمة المحلية
      }

      debugPrint("-------------------> تم الانتهاء من مزامنة جميع الخطط بنجاح");
    } catch (e) {
      debugPrint("-------------------> خطأ في جلب وتخزين الخطط: $e");
      throw Exception('فشل في مزامنة الخطط: $e');
    }
  }

  Future<void> deletePlan(String planId, String table, String column) async {
    try {
      int result = await sqlDb.deleteData2(table, column, planId);
      if (result > 0) {
        debugPrint("-----> Deleted plan $planId from $table");
        // إزالة الخطة من القائمة المحلية
        if (table == 'ConservationPlans') {
          conservationPlans
              .removeWhere((plan) => plan.conservationPlanId == planId);
        } else if (table == 'EltlawahPlans') {
          eltlawahPlans.removeWhere((plan) => plan.eltlawahPlanId == planId);
        } else if (table == 'IslamicStudies') {
          islamicStudyPlans
              .removeWhere((plan) => plan.islamicStudiesID == planId);
        }
        // حذف من Firebase إذا كان متزامن
        bool hasConnection =
            await InternetConnectionChecker.createInstance().hasConnection;
        if (hasConnection) {
          // await firebasehelper.deletePlan(planId.toString(), table);
        }
      } else {
        debugPrint("-----> No plan found with $column = $planId in $table");
      }
    } catch (e) {
      debugPrint("Error deleting plan from $table: $e");
      throw Exception("Failed to delete plan: $e");
    }
  }

  // دوال تحديث الخطط
  Future<int> updateConservationPlan2(ConservationPlanModel plan) async {
    try {
      final Map<String, dynamic> updateData = plan.toMap();
      // إزالة المعرف من البيانات لأنه لا يمكن تعديله
      updateData.remove('ConservationPlanID');

      // تحديث في قاعدة البيانات المحلية
      int result = await sqlDb.updateData3(
        'ConservationPlans',
        updateData,
        'ConservationPlanID = ?',
        [plan.conservationPlanId],
      );

      debugPrint(
          "------------------> Update ConservationPlan ${plan.conservationPlanId} is: ${result > 0 ? 'Done' : 'Failed'}");

      // مزامنة مع Firebase إذا كان متصلاً
      bool hasConnection =
          await InternetConnectionChecker.createInstance().hasConnection;
      if (result > 0 && hasConnection) {
        plan.isSync = 1;
        // ملاحظة: تم تعطيل المزامنة المباشرة مع Firebase حاليًا لأن الدالة غير معرفة
        await firebasehelper.updateConservationPlan(
            plan, plan.conservationPlanId!);
        await sqlDb.updateData3(
          'ConservationPlans',
          {'isSync': 1},
          'ConservationPlanID = ?',
          [plan.conservationPlanId],
        );
        debugPrint("------------------> isSync: Sync Done for update!");
      } else {
        // تحديث علامة المزامنة إلى 0 إذا لم يتم المزامنة
        await sqlDb.updateData3(
          'ConservationPlans',
          {'isSync': 0},
          'ConservationPlanID = ?',
          [plan.conservationPlanId],
        );
        debugPrint("------------------> isSync: update not Sync");
      }

      // تحديث الخطة في القائمة المحلية
      if (result > 0) {
        int index = conservationPlans
            .indexWhere((p) => p.conservationPlanId == plan.conservationPlanId);
        if (index != -1) {
          conservationPlans[index] = plan;
        }
      }

      return result;
    } catch (e) {
      debugPrint(
          "------------------> Error in updateConservationPlan in ((planController)) : $e");
      return -1;
    }
  }

  Future<int> updateEltlawahPlan2(EltlawahPlanModel plan,
      {bool isForWholeHalaga = true}) async {
    try {
      final Map<String, dynamic> updateData = plan.toMap();

      // إذا كانت الخطة للحلقة بأكملها، نضع قيمة خاصة لـ studentId
      // if (isForWholeHalaga) {
      //   plan.studentId =
      //       (-1) as String?; // قيمة خاصة تشير إلى أن الخطة للحلقة بأكملها
      //   updateData['StudentID'] = -1;
      //   debugPrint("----------> Updating Eltlawah Plan for the whole Halaga");
      // }

      // إزالة المعرف من البيانات لأنه لا يمكن تعديله
      updateData.remove('EltlawahPlanID');

      // تحديث في قاعدة البيانات المحلية
      int result = await sqlDb.updateData3(
        'EltlawahPlans',
        updateData,
        'EltlawahPlanID = ?',
        [plan.eltlawahPlanId],
      );

      debugPrint(
          "------------------> Update EltlawahPlan ${plan.eltlawahPlanId} is: ${result > 0 ? 'Done' : 'Failed'}");

      // مزامنة مع Firebase إذا كان متصلاً
      bool hasConnection =
          await InternetConnectionChecker.createInstance().hasConnection;
      if (result > 0 && hasConnection) {
        plan.isSync = 1;
        // ملاحظة: تم تعطيل المزامنة المباشرة مع Firebase حاليًا لأن الدالة غير معرفة
        await firebasehelper.updateEltlawahPlan(plan, plan.eltlawahPlanId!);
        await sqlDb.updateData3(
          'EltlawahPlans',
          {'isSync': 1},
          'EltlawahPlanID = ?',
          [plan.eltlawahPlanId],
        );
        debugPrint("------------------> isSync: Sync Done for update!");
      } else {
        // تحديث علامة المزامنة إلى 0 إذا لم يتم المزامنة
        await sqlDb.updateData3(
          'EltlawahPlans',
          {'isSync': 0},
          'EltlawahPlanID = ?',
          [plan.eltlawahPlanId],
        );
        debugPrint("------------------> isSync: update not Sync");
      }

      // تحديث الخطة في القائمة المحلية
      if (result > 0) {
        int index = eltlawahPlans
            .indexWhere((p) => p.eltlawahPlanId == plan.eltlawahPlanId);
        if (index != -1) {
          eltlawahPlans[index] = plan;
        }
      }

      return result;
    } catch (e) {
      debugPrint(
          "------------------> Error in updateEltlawahPlan in ((planController)) : $e");
      return -1;
    }
  }

  Future<int> updateIslamicStudies2(IslamicStudiesModel plan) async {
    try {
      final Map<String, dynamic> updateData = plan.toMap();
      // إزالة المعرف من البيانات لأنه لا يمكن تعديله
      updateData.remove('IslamicStudiesID');

      // تحديث في قاعدة البيانات المحلية
      int result = await sqlDb.updateData3(
        'IslamicStudies',
        updateData,
        'IslamicStudiesID = ?',
        [plan.islamicStudiesID],
      );

      debugPrint(
          "------------------> Update IslamicStudies ${plan.islamicStudiesID} is: ${result > 0 ? 'Done' : 'Failed'}");

      // مزامنة مع Firebase إذا كان متصلاً
      bool hasConnection =
          await InternetConnectionChecker.createInstance().hasConnection;
      if (result > 0 && hasConnection) {
        plan.isSync = 1;
        // ملاحظة: تم تعطيل المزامنة المباشرة مع Firebase حاليًا لأن الدالة غير معرفة
        await firebasehelper.updateIslamicStudyplan(
            plan, plan.islamicStudiesID!);
        await sqlDb.updateData3(
          'IslamicStudies',
          {'isSync': 1},
          'IslamicStudiesID = ?',
          [plan.islamicStudiesID],
        );
        debugPrint("------------------> isSync: Sync Done for update!");
      } else {
        // تحديث علامة المزامنة إلى 0 إذا لم يتم المزامنة
        await sqlDb.updateData3(
          'IslamicStudies',
          {'isSync': 0},
          'IslamicStudiesID = ?',
          [plan.islamicStudiesID],
        );
        debugPrint("------------------> isSync: update not Sync");
      }

      // تحديث الخطة في القائمة المحلية
      if (result > 0) {
        int index = islamicStudyPlans
            .indexWhere((p) => p.islamicStudiesID == plan.islamicStudiesID);
        if (index != -1) {
          islamicStudyPlans[index] = plan;
        }
      }

      return result;
    } catch (e) {
      debugPrint(
          "------------------> Error in updateIslamicStudies in ((planController)) : $e");
      return -1;
    }
  }

  Future<void> saveInLocal(String halagaId) async {
    final db = await sqlDb.database;
    List<ConservationPlanModel> cp = [];
    List<EltlawahPlanModel> ep = [];
    List<IslamicStudiesModel> ip = [];
    try {
      cp = await firebasehelper.getConservationPlans(halagaId);
      ep = await firebasehelper.getEltlawahPlans(halagaId);
      ip = await firebasehelper.getIslamicStudyPlans(halagaId);

      /// Conservation plan
      for (var c in cp) {
        bool exists = await sqlDb.checkIfitemExists2(
            'ConservationPlans', c.conservationPlanId!, 'ConservationPlanID');
        print(exists);
        exists
            ? await db.update(
                'ConservationPlans', c.toMap()..remove('ConservationPlanID'),
                where: 'ConservationPlanID = ?',
                whereArgs: [c.conservationPlanId])
            : await db.insert('ConservationPlans', c.toMap());
      }

      for (var e in ep) {
        bool exists = await sqlDb.checkIfitemExists2(
            'EltlawahPlans', e.eltlawahPlanId!, 'EltlawahPlanID');
        print(exists);
        exists
            ? await db.update(
                'EltlawahPlans', e.toMap()..remove('EltlawahPlanID'),
                where: 'EltlawahPlanID = ?', whereArgs: [e.eltlawahPlanId])
            : await db.insert('EltlawahPlans', e.toMap());
      }

      for (var i in ip) {
        bool exists = await sqlDb.checkIfitemExists2(
            'IslamicStudies', i.islamicStudiesID!, 'IslamicStudiesID');
        print(exists);
        exists
            ? await db.update(
                'IslamicStudies', i.toMap()..remove('IslamicStudiesID'),
                where: 'IslamicStudiesID = ?', whereArgs: [i.islamicStudiesID])
            : await db.insert('IslamicStudies', i.toMap());
      }
    } catch (e) {
      debugPrint('$e');
    }
  }
}

PlanController planController = PlanController();
