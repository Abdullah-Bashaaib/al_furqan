import 'dart:developer';

import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlDb {
  static Database? _db;

  Future<Database> get database async {
    _db ??= await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'alforqanDB.db');
    Database myDb = await openDatabase(
      path,
      version: 8, // زوّدنا الإصدار عشان التعديلات
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return myDb;
  }

  _onCreate(Database db, int version) async {
    String sqlScript = await loadSqlScript();
    List<String> queries = sqlScript.split(';');
    for (String query in queries) {
      if (query.trim().isNotEmpty) {
        await db.execute(query);
      }
    }
    log("Database Created Successfully");
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<String> loadSqlScript() async {
    return await rootBundle.loadString('assets/database/al_furqan.db');
  }

  Future<UserModel?> getUser(String phone, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'phone_number = ? AND password = ?',
      whereArgs: [phone, password],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    debugPrint("User not found for phone: $phone");
    return null;
  }

  Future<List<Map<String, dynamic>>> readData(String sql) async {
    Database myDb = await database;
    return await myDb.rawQuery(sql);
  }

  readDataID(String table, String column, int sync) async {
    Database myDb = await database;
    return await myDb.query(table, where: "$column = ?", whereArgs: [sync]);
  }

  Future<int> insertData(String sql) async {
    Database myDb = await database;
    return await myDb.rawInsert(sql);
  }

  Future<int> insertData2(String table, Map<String, dynamic> values) async {
    Database myDb = await database;
    try {
      return await myDb.insert(table, values);
    } catch (e) {
      debugPrint("Error inserting into $table: $e");
      return -1;
    }
  }

  updateData(String sql) async {
    Database myDb = await database;
    return await myDb.rawUpdate(sql);
  }

  Future<int> updateData3(String table, Map<String, dynamic> values,
      String where, List<dynamic> whereArgs) async {
    try {
      Database myDb = await database;
      int result = await myDb.update(
        table,
        values,
        where: where,
        whereArgs: whereArgs,
      );
      debugPrint(
          "------------------> Updated $table where $where: $result row(s) affected");
      return result;
    } catch (e) {
      debugPrint("------------------> Error updating $table: $e");
      return -1;
    }
  }

  Future<int> deleteData(String sql) async {
    Database myDb = await database;
    return await myDb.rawDelete(sql);
  }

  Future<int> deleteData2(String table, String column, String id) async {
    Database myDb = await database;
    return await myDb.delete(table, where: "$column = ?", whereArgs: [id]);
  }

  Future<bool> checkIfItemExists(String table, int id, String column) async {
    final db = await database;
    final result = await db.query(
      table,
      where: '$column = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  Future<bool> checkIfItemExists2(
      String table, String id, String column) async {
    final db = await database;
    final result = await db.query(
      table,
      where: '$column = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  Future<bool> checkIfItemExistsForExcel(
      String table, Map<String, dynamic> values) async {
    try {
      final db = await database;
      // بناء شرط الـ WHERE ديناميكيًا
      String whereClause = values.keys.map((key) => '$key = ?').join(' AND ');
      List<dynamic> whereArgs = values.values.toList();

      final result = await db.query(
        table,
        where: whereClause,
        whereArgs: whereArgs,
      );

      debugPrint(
          "-----> Checking if item exists in $table with $values: ${result.isNotEmpty}");
      return result.isNotEmpty;
    } catch (e) {
      debugPrint("Error checking item in $table: $e");
      return false;
    }
  }

  Future<T> transaction<T>(Future<T> Function(Transaction) action) async {
    Database myDb = await database;
    return await myDb.transaction(action);
  }
}

SqlDb sqlDb = SqlDb();
