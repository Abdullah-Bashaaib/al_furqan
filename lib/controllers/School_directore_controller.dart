import 'dart:developer';

import 'package:al_furqan/models/helper/sql_db.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/login/login.dart';
import 'package:flutter/material.dart';

class SchoolDirectorController {
  final SqlDb _sqlDb = SqlDb();
  final List<UserModel> userData = [];

  getDataUsers(String phoneNumber) async {
    List<Map> data = await _sqlDb
        .readData("SELECT * FROM 'USERS' WHERE phone_number = '$id'");
    userData.clear();

    for (var i = 0; i < data.length; i++) {
      userData.add(UserModel(
        user_id: data[i]['user_id'] as String?, // تأكد من أن user_id هو int
        first_name: data[i]['first_name'],
        middle_name: data[i]['middle_name'],
        grandfather_name: data[i]['grandfather_name'],
        last_name: data[i]['last_name'],
        phone_number:
            int.tryParse(data[i]['phone_number'].toString()), // تحويل إلى int
        telephone_number: int.tryParse(
            data[i]['telephone_number'].toString()), // تحويل إلى int
        email: data[i]['email'],
        password: data[i]['password'],
        roleID: data[i]['roleID'] as int?, // تأكد من أن roleID هو int
        schoolID: data[i]['schoolID'] as int?,
        date: data[i]['date'],
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
    List<Map> data = await _sqlDb
        .readData("SELECT * FROM 'SCHOOLS' WHERE SchoolID = '$schoolId'");
    String schoolName = "";
    for (var i = 0; i < data.length; i++) {
      schoolName = data[i]['school_name'];
    }
    debugPrint("school name: $schoolName");
    return schoolName;
  }
}

SchoolDirectorController schoolDirectorController = SchoolDirectorController();
