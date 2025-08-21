import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/helper/current_user.dart';
import 'package:al_furqan/main.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../helper/sqldb.dart';

class HalaqaProvider with ChangeNotifier {
  List<HalagaModel> halaqat = [];
  HalagaModel? halaga;

  int get halaqatCount => halaqat.length;
  List<HalagaModel> get halaqatList => halaqat;

  HalaqaProvider() {
    init();
  }

  init() async {
    // print('======================');
    int? role = perf.getInt('roleID') ?? 4;
    if (role == 1) {
      await loadedHalaqatFromLocal();
    } else if (role == 2) {
      await loadHalaga();
    } else {}
  }

  Future<bool> connected() async {
    bool conn = await InternetConnectionChecker.createInstance().hasConnection;
    return conn;
  }

  loadHalaqatFromFirebase() async {
    int? schoolID = perf.getInt('schoolId');
    if (await connected()) {
      await halagaController.getHalagatFromFirebaseByID(schoolID!, 'SchoolID');
      await loadedHalaqatFromLocal();
    } else {
      // print('لا يوجد اتصال بالانتلرنت');
      await loadedHalaqatFromLocal();
    }
  }

  Future<void> loadedHalaqatFromLocal() async {
    // final sw3 = Stopwatch()..start();

    final db = await sqlDb.database;
    final List<Map<String, dynamic>> request = await db.query('Elhalagat');
    List<HalagaModel> halaqatList =
        request.map((j) => HalagaModel.fromJson(j)).toList();
    halaqat.clear();
    halaqat.addAll(halaqatList);
    // print('$halaqatList 000000000000000000000000000000');
    // print('${CurrentUser.user!.first_name}00000000000000000000000');
    notifyListeners();
    // print(halaqat);
    // sw3.stop();
    // int? timeSyncStudents = sw3.elapsedMilliseconds;
    // debugPrint("Time load halagat is : $timeSyncStudents ms");
  }

  /// Teacher Scope
  Future<void> loadHalaga() async {
    String? id = perf.getString('halagaID');
    halaga = await halagaController.getHalagaByHalagaID(id!);
    CurrentUser.halaga = halaga;
    print('===== ${CurrentUser.halaga} ====55555555555555555555');
    notifyListeners();
  }

  Future<void> loadHalagaFromFirebase() async {
    halaga = await firebasehelper.getElhalaga(CurrentUser.user!.elhalagatID!);
    bool exists = await sqlDb.checkIfitemExists2(
        'Elhalagat', halaga!.halagaID!, 'halagaID');
    if (exists) {
      await halagaController.updateHalaga(halaga!, 0);
      debugPrint('===== updateHalaga =====');
    } else {
      await halagaController.addHalaga(halaga!, 0);
      debugPrint('===== addHalaga =====');
    }
    CurrentUser.halaga = halaga;
    notifyListeners();
  }
}
