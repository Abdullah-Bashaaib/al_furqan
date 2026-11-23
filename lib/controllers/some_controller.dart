// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../helper/sqldb.dart';

class SomeController {
  final SqlDb _sqlDb = SqlDb();

  // Replace Firestore usage with local database logic
  Future<void> getData() async {
    // Query Firestore
    // QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('collection').get();

    // Use local database instead
    // List<Map> response = await _sqlDb.readData("SELECT * FROM 'collection'");
    // ...process response...
  }

  Future<int> newId(String table, String column) async {
    List<Map> response =
        await _sqlDb.readData("SELECT MAX($column) AS max_id FROM $table");

    var maxId = response[0]['max_id'];
    // var maxID=response.last['max_id'];
    if (maxId == null || maxId == 0) {
      return 1; // يعني أول رقم جديد
    }
    return maxId + 1;
  }

  Future<int> newId2(String table, String column,
      {bool checkFirebase = true}) async {
    final SqlDb sqlDb = SqlDb();

    try {
      return await sqlDb.transaction((txn) async {
        // 1. جلب أكبر معرف من SQLite
        List<Map> response =
            await txn.rawQuery("SELECT MAX($column) AS max_id FROM $table");
        int maxId = response[0]['max_id'] ?? 0;
        int newId = maxId + 1;

        // 2. تحقق من وجود المعرف في SQLite وFirebase
        bool hasInternet = checkFirebase
            ? await InternetConnectionChecker.createInstance().hasConnection
            : false;

        while (true) {
          // تحقق في SQLite باستخدام Transaction
          List<Map> existsInSqlite = await txn.rawQuery(
            "SELECT 1 FROM $table WHERE $column = ?",
            [newId],
          );

          if (existsInSqlite.isEmpty) {
            if (hasInternet) {
              // تحقق في Firebase إذا كان فيه اتصال وcheckFirebase مفعّل
              bool existsInFirebase =
                  await _checkIfIdExistsInFirebase(table, newId);
              if (!existsInFirebase) {
                return newId; // المعرف فريد في SQLite وFirebase
              }
            } else {
              return newId; // المعرف فريد في SQLite فقط (أوفلاين أو checkFirebase = false)
            }
          }

          newId++; // جرب المعرف التالي
        }
      });
    } catch (e) {
      debugPrint("Error generating new ID for $table.$column: $e");
      throw Exception("Failed to generate unique ID");
    }
  }

// دالة مساعدة للتحقق من وجود المعرف في Firestore
  Future<bool> _checkIfIdExistsInFirebase(String table, int id) async {
    try {
      String collection;
      switch (table) {
        case 'ConservationPlans':
          collection = 'ConservationPlans';
          break;
        case 'EltlawahPlans':
          collection = 'EltlawahPlans';
          break;
        case 'IslamicStudies':
          collection = 'IslamicStudies';
          break;
        default:
          throw Exception('Unknown table: $table');
      }

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(id.toString())
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint("Error checking Firebase for $table ID $id: $e");
      return false; // افترض عدم الوجود في حالة الخطأ
    }
  }
}

SomeController someController = SomeController();
