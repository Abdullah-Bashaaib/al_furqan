import 'package:al_furqan/controllers/some_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/schools_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class SchoolController {
  final List<SchoolModel> _schools = [];
  final SqlDb _sqlDb = SqlDb();

  List<SchoolModel> get schools => _schools;

  /// جلب جميع المدارس من قاعدة البيانات
  Future<void> getData() async {
    try {
      final data = await _sqlDb.readData('SELECT * FROM Schools');
      _schools.clear();
      for (var item in data) {
        _schools.add(SchoolModel(
          schoolID: item['SchoolID'] as int?,
          school_name: item['school_name'] as String?,
          school_location: item['school_location'] as String?,
        ));
      }
      debugPrint("Fetched ${_schools.length} schools");
    } catch (e) {
      debugPrint("Error fetching schools: $e");
      rethrow;
    }
  }

  /// جلب مدرسة بناءً على SchoolID
  Future<SchoolModel?> getSchoolBySchoolID(int schoolID) async {
    try {
      final response = await _sqlDb
          .readData("SELECT * FROM Schools WHERE SchoolID = $schoolID");
      if (response.isEmpty) {
        debugPrint("No school found for SchoolID: $schoolID , $response");
        return null;
      }
      final school = SchoolModel(
        schoolID: response[0]['SchoolID'] as int?,
        school_name: response[0]['school_name'] as String?,
        school_location: response[0]['school_location'] as String?,
      );
      debugPrint("Fetched school: ${school.school_name}, $response");
      return school;
    } catch (e) {
      debugPrint("Error fetching school by SchoolID $schoolID: $e");
      return null;
    }
  }

  /// إضافة مدرسة جديدة
  Future<void> addSchool(SchoolModel schoolModel, int type) async {
    try {
      if (type == 1) {
        schoolModel.schoolID =
            await someController.newId("Schools", "SchoolID");
        // إضافة المدرسة مع وضع isSync = 0 للمزامنة لاحقًا
        int response = await _sqlDb.insertData('''
        INSERT INTO Schools (SchoolID, school_name, school_location, isSync)
        VALUES (${schoolModel.schoolID}, '${schoolModel.school_name}', '${schoolModel.school_location}', 0)
      ''');

        // محاولة المزامنة مباشرة إذا كان هناك اتصال بالإنترنت
        if (await InternetConnectionChecker.createInstance().hasConnection) {
          await firebasehelper.addSchool(schoolModel);
          // تحديث حالة المزامنة بعد نجاح الإضافة إلى Firebase
          await _sqlDb.updateData(
              'UPDATE Schools SET isSync = 1 WHERE SchoolID = ${schoolModel.schoolID}');
          debugPrint("تمت مزامنة المدرسة بنجاح");
        } else {
          debugPrint("لا يوجد اتصال بالانترنت - ستتم المزامنة لاحقًا");
        }

        debugPrint("Added school, response: $response");
        if (response == 0) {
          throw Exception("Failed to add school");
        }
      } else {
        // إضافة محلية فقط بدون مزامنة
        await _sqlDb.insertData('''
        INSERT INTO Schools (SchoolID, school_name, school_location, isSync)
        VALUES (${schoolModel.schoolID}, '${schoolModel.school_name}', '${schoolModel.school_location}', ${schoolModel.isSync})
      ''');
        debugPrint('تم اضافة مدرسه جديده بنجاح ${schoolModel.school_name}');
      }
    } catch (e) {
      debugPrint("Error adding school: $e");
      rethrow;
    }
  }

  /// تعديل مدرسة موجودة
  Future<void> updateSchool(SchoolModel schoolModel, int type) async {
    try {
      if (type == 1) {
        // تحديث المدرسة ووضع isSync = 0 للمزامنة لاحقًا
        await _sqlDb.updateData('''
        UPDATE Schools SET 
          school_name = '${schoolModel.school_name}', 
          school_location = '${schoolModel.school_location}', 
          isSync = 0 
        WHERE SchoolID = ${schoolModel.schoolID}
      ''');

        // محاولة المزامنة مباشرة إذا كان هناك اتصال بالإنترنت
        if (await InternetConnectionChecker.createInstance().hasConnection) {
          await firebasehelper.updateSchool(schoolModel);
          // تحديث حالة المزامنة بعد نجاح التحديث في Firebase
          await _sqlDb.updateData(
              'UPDATE Schools SET isSync = 1 WHERE SchoolID = ${schoolModel.schoolID}');
          debugPrint("تمت مزامنة تعديل المدرسة بنجاح");
        } else {
          debugPrint("لا يوجد اتصال بالانترنت - ستتم مزامنة التعديل لاحقًا");
        }

        debugPrint('تم تعديل المدرسه ${schoolModel.school_name} بنجاح');
      } else {
        // تحديث محلي فقط بدون مزامنة
        await _sqlDb.updateData('''
        UPDATE Schools SET 
          school_name = '${schoolModel.school_name}', 
          school_location = '${schoolModel.school_location}', 
          isSync = ${schoolModel.isSync}
        WHERE SchoolID = ${schoolModel.schoolID}
      ''');
        debugPrint('تم تحديث المدرسة محليًا فقط');
      }
    } catch (e) {
      debugPrint("Error updating school: $e");
      rethrow;
    }
  }

  /// حذف مدرسة بناءً على SchoolID
  Future<void> deleteSchool(int schoolId) async {
    try {
      // محاولة حذف المدرسة من Firebase إذا كان هناك اتصال بالإنترنت
      if (await InternetConnectionChecker.createInstance().hasConnection) {
        // الحصول على بيانات المدرسة قبل حذفها
        SchoolModel? school = await getSchoolBySchoolID(schoolId);
        if (school != null) {
          // حذف المدرسة من Firebase
          await firebasehelper.deleteSchool(schoolId);
          debugPrint("تم حذف المدرسة من Firebase");
        }
      } else {
        debugPrint("لا يوجد اتصال بالإنترنت - سيتم حذف المدرسة محليًا فقط");
      }

      // حذف المدرسة من قاعدة البيانات المحلية
      int response = await _sqlDb
          .deleteData("DELETE FROM Schools WHERE SchoolID = $schoolId");
      debugPrint("Deleted school $schoolId, response: $response");

      if (response == 0) {
        throw Exception("Failed to delete school $schoolId");
      }
    } catch (e) {
      debugPrint("Error deleting school: $e");
      rethrow;
    }
  }
}

SchoolController schoolController = SchoolController();
