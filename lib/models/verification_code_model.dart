import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationCode {
  String? id;
  final String phoneNumber;
  final DateTime createdAt;
  String? code;
  final int used;

  VerificationCode({
    this.id,
    required this.phoneNumber,
    required this.createdAt,
    this.code,
    this.used = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'code': code,
      'used': used,
    };
  }

  factory VerificationCode.fromMap(Map<String, dynamic> map) {
    return VerificationCode(
      id: map['id']?.toString(),
      phoneNumber: map['phoneNumber'] as String,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      code: map['code']?.toString() ?? '',
      used: map['used'] as int? ?? 0,
    );
  }
}
