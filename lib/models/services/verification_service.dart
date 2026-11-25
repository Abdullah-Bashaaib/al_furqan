import 'dart:math';

import 'package:al_furqan/models/verification_code_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<VerificationCode>> getPendingRequests() async {
    try {
      final snapshot = await _firestore
          .collection('verification_codes')
          .where('used', isEqualTo: 0)
          .get();

      return snapshot.docs
          .map((doc) => VerificationCode.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<void> verificationRequest(int number) async {
    try {
      debugPrint('=================================================');
      final query = await _firestore
          .collection('Users')
          .where('phone_number', isEqualTo: number)
          .limit(1)
          .get();

      debugPrint('===========================${query.docs.first.data()}');

      if (query.docs.isEmpty) {
        throw 'رقم الهاتف غير مسجل';
      }
      // UserModel user = query.docs.map((doc) => UserModel.fromMap(doc.data())) as UserModel;
      VerificationCode request = VerificationCode(
          phoneNumber: number.toString(), createdAt: DateTime.now());

      final docRef = await _firestore
          .collection('verification_codes')
          .add(request.toMap());
      debugPrint('تم عمل Request');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  String generateVerificationCode() {
    // Use the same logic as FirebaseHelper
    return (100000 + Random().nextInt(900000)).toString();
  }

  Future<String> generateAndSaveCode(VerificationCode request) async {
    try {
      final snapshot = await _firestore
          .collection('verification_codes')
          .where('phoneNumber', isEqualTo: request.phoneNumber)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final verificationCode = generateVerificationCode();

        // إذا كنت تريد التحديث على الوثيقة الموجودة:
        final docId = snapshot.docs.first.id;
        debugPrint(docId);
        debugPrint('=========================================');
        await _firestore.collection('verification_codes').doc(docId).update({
          'code': verificationCode,
          'createdAt': DateTime.now().toIso8601String(),
        });

        debugPrint(
            "Generated and saved code: $verificationCode for phone: ${request.phoneNumber}");
        return verificationCode;
      } else {
        debugPrint(
            "Verification request not found for phone: ${request.phoneNumber}");
        return '';
      }
    } catch (e) {
      debugPrint("Error generating code: $e");
      return '';
    }
  }

  Future<void> updatePassword(int idNumber, String newPassword) async {
    try {
      final query = await _firestore
          .collection('Users')
          .where('phone_number', isEqualTo: idNumber)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw 'رقم الهاتف غير مسجل';
      }

      await query.docs.first.reference.update({
        'password': newPassword, // يجب تشفير كلمة المرور في التطبيق الحقيقي
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'فشل تحديث كلمة المرور: ${e.toString()}';
    }
  }

  Future<void> deleteAllUsedVerificationCodes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('verification_codes')
          .where('used', isEqualTo: 1)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
        debugPrint('تم حذف الكود المستخدم: ${doc.id}');
      }

      if (snapshot.docs.isEmpty) {
        debugPrint('لا يوجد أكواد مستخدمة للحذف.');
      }
    } catch (e) {
      debugPrint('خطأ أثناء حذف الأكواد المستخدمة: $e');
    }
  }
}

VerificationService verificationService = VerificationService();
