// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/fathers_controller.dart';
import 'package:al_furqan/controllers/validation_from_excelfile.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class ExcelTesting {
  int? schoolID;
  ExcelTesting({required this.schoolID});
  var excel = Excel.createExcel();
  List<Map<String, dynamic>> dataList = []; // قائمة لتخزين البيانات

  Future<void> readExcelFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
    );

    if (result == null || result.files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم اختيار ملف')),
      );
      return;
    }

    final errors = <Map<String, dynamic>>[];
    final validStudents = <StudentModel>[];
    final validFathers = <UserModel>[];

    try {
      final file = File(result.files.single.path!);
      final bytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      for (final table in excel.tables.keys) {
        final sheet = excel.tables[table]!;
        // التأكد من أسماء الأعمدة
        final headers =
            sheet.rows[0].map((cell) => cell!.value.toString().trim()).toList();

        // طباعة الأعمدة للتحقق
        debugPrint("Headers: $headers");

        for (int rowIndex = 1; rowIndex < sheet.rows.length; rowIndex++) {
          final row = sheet.rows[rowIndex];
          final rowData = <String, dynamic>{};

          // التحقق من عدد الأعمدة
          if (row.length != headers.length) {
            errors.add({
              'row': rowData,
              'errors': {'general': 'عدد الأعمدة غير متطابق'},
              'rowNumber': rowIndex + 1,
            });
            continue;
          }

          // تعبئة rowData
          for (int colIndex = 0; colIndex < headers.length; colIndex++) {
            rowData[headers[colIndex]] =
                row[colIndex]?.value?.toString().trim();
            debugPrint(
                "Column ${headers[colIndex]}: ${rowData[headers[colIndex]]}");
          }

          // التحقق من صحة الصف
          final validation = ExcelDataValidator.validateRow(rowData);
          debugPrint("Finished--------------------------------");
          if (!validation['isValid']) {
            errors.add({
              'row': rowData,
              'errors': validation['errors'],
              'rowNumber': rowIndex + 1,
            });
            continue;
          }

          // إنشاء موديلات البيانات الصالحة
          final student = StudentModel(
            firstName: rowData['الاسم الاول']?.toString() ?? '',
            middleName: rowData['اسم الأب']?.toString() ?? '',
            grandfatherName: rowData['اسم الجد']?.toString() ?? '',
            lastName: rowData['اسم العائلة']?.toString() ?? '',
            schoolId: schoolID,
          );

          final father = UserModel(
            first_name: rowData['اسم الأب']?.toString() ?? '',
            middle_name: rowData['اسم الجد']?.toString() ?? '',
            grandfather_name: rowData['اسم جد الأب']?.toString() ?? '',
            last_name: rowData['اسم العائلة']?.toString() ?? '',
            email: validation['validated']['email'],
            phone_number: validation['validated']['phone'] ?? 0,
            telephone_number: validation['validated']['telephone'] ?? 0,
            password: '12345678',
            roleID: 3,
            isActivate: 0,
          );

          validStudents.add(student);
          validFathers.add(father);
        }
      }

      // إدخال البيانات الصالحة إلى قاعدة البيانات
      await _insertValidData(context, validStudents, validFathers);

      // عرض الأخطاء إذا وجدت
      if (errors.isNotEmpty) {
        _showValidationErrors(context, errors);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
      debugPrint("-------------the error is $e");
    }
  }

// دالة لعرض الأخطاء
  void _showValidationErrors(
      BuildContext context, List<Map<String, dynamic>> errors) {
    final message = errors.map((error) {
      return '➊ الصف ${error['rowNumber']}\n'
          '➋ الأخطاء: ${(error['errors'] as Map).entries.join(', ')}';
    }).join('\n\n');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('أخطاء في البيانات'),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تم'),
          ),
        ],
      ),
    );
  }

  Future<void> _insertValidData(BuildContext context,
      List<StudentModel> students, List<UserModel> fathers) async {
    int successfulInserts = 0;

    for (int i = 0; i < students.length; i++) {
      // تنظيف الأسماء
      String firstName = students[i].firstName?.trim() ?? '';
      String lastName = students[i].lastName?.trim() ?? '';

      // التحقق من وجود الطالب
      bool studentExists = await SqlDb().checkIfitemExistsForExcel("Students", {
        "firstName": firstName,
        "lastName": lastName,
      });
      debugPrint("Student $firstName $lastName exists: $studentExists");

      if (!studentExists) {
        // إضافة الطالب إذا لم يكن موجودًا
        students[i].userID = await fathersController.addFather(
            fathers[i], 1); // ربط الطالب بالأب
        await studentController.addStudent(students[i], 1);
        fathers[i].schoolID = students[i].schoolId;
        debugPrint(
            "-----------> Student [Father ID is : ${students[i].userID}]\nFahter [Father ID is : ${fathers[i].user_id}]");
        successfulInserts++;
      } else {
        // إذا كان الطالب موجودًا، تخطي الإضافة
        debugPrint("Student $firstName $lastName already exists, skipping...");
      }
    }

    // عرض رسالة النجاح
    if (successfulInserts > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إدخال $successfulInserts طالب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// ExcelTesting excelTesting = ExcelTesting();
