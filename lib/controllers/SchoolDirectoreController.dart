import 'dart:developer';

import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/login/login.dart';
import 'package:flutter/material.dart';

class SchoolDirectorController {
  final SqlDb _sqlDb = SqlDb();
  final List<UserModel> userData = [];

  get_data_users(String phoneNumber) async {
    List<Map> Data = await _sqlDb
        .readData("SELECT * FROM 'USERS' WHERE phone_number = '$id'");
    userData.clear();

    for (var i = 0; i < Data.length; i++) {
      userData.add(UserModel(
        user_id: Data[i]['user_id'] as String?, // تأكد من أن user_id هو int
        first_name: Data[i]['first_name'],
        middle_name: Data[i]['middle_name'],
        grandfather_name: Data[i]['grandfather_name'],
        last_name: Data[i]['last_name'],
        phone_number:
            int.tryParse(Data[i]['phone_number'].toString()), // تحويل إلى int
        telephone_number: int.tryParse(
            Data[i]['telephone_number'].toString()), // تحويل إلى int
        email: Data[i]['email'],
        password: Data[i]['password'],
        roleID: Data[i]['roleID'] as int?, // تأكد من أن roleID هو int
        schoolID: Data[i]['schoolID'] as int?,
        date: Data[i]['date'],
        // isActivate: response[i]['isActivate'] as int?, // تأكد من أن isActivate هو int
      ));
    }
    // users.forEach((element) {
    //   debugPrint(
    //       "USER ID : ${element.user_id}\nUSER NAME : ${element.first_name}\nSCHOOL ID : ${element.schoolID}\n____________________________________________________________________________");
    // });
    log("${userData.isEmpty}");
  }

  Future<String> getSchoolName(int schoolId) async {
    List<Map> Data = await _sqlDb
        .readData("SELECT * FROM 'SCHOOLS' WHERE SchoolID = '$schoolId'");
    String schoolName = "";
    for (var i = 0; i < Data.length; i++) {
      schoolName = Data[i]['school_name'];
    }
    debugPrint("school name: $schoolName");
    return schoolName;
  }
}

SchoolDirectorController schoolDirectorController = SchoolDirectorController();
