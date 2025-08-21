import 'package:cloud_firestore/cloud_firestore.dart';

class ConservationPlanModel {
  String? conservationPlanId;
  String? elhalagatId;
  String? studentId;
  String? plannedStartSurah;
  int? plannedStartAya;
  String? plannedEndSurah;
  int? plannedEndAya;
  String? executedStartSurah;
  int? executedStartAya;
  String? executedEndSurah;
  int? executedEndAya;
  double? executedRate;
  String? planMonth;
  int? isSync;

  /// إنشاء نموذج خطة حفظ جديد
  ConservationPlanModel({
    this.conservationPlanId,
    required this.elhalagatId,
    required this.studentId,
    required this.plannedStartSurah,
    required this.plannedStartAya,
    required this.plannedEndSurah,
    required this.plannedEndAya,
    this.executedStartSurah,
    this.executedStartAya,
    this.executedEndSurah,
    this.executedEndAya,
    this.executedRate,
    this.planMonth,
    this.isSync,
  });

  /// تحويل النموذج إلى Map للحفظ في قاعدة بيانات SQLite
  Map<String, dynamic> toMap() {
    return {
      'ConservationPlanID': conservationPlanId,
      'ElhalagatID': elhalagatId,
      'StudentID': studentId,
      'PlannedStartSurah': plannedStartSurah,
      'PlannedStartAya': plannedStartAya,
      'PlannedEndSurah': plannedEndSurah,
      'PlannedEndAya': plannedEndAya,
      'ExecutedStartSurah': executedStartSurah,
      'ExecutedStartAya': executedStartAya,
      'ExecutedEndSurah': executedEndSurah,
      'ExecutedEndAya': executedEndAya,
      'ExecutedRate': executedRate,
      'PlanMonth': planMonth,
      'isSync': isSync,
    };
  }

  /// إنشاء نموذج من Map من قاعدة بيانات SQLite
  factory ConservationPlanModel.fromMap(Map<String, dynamic> map) {
    return ConservationPlanModel(
      conservationPlanId: map['ConservationPlanID'],
      elhalagatId: map['ElhalagatID'],
      studentId: map['StudentID'],
      plannedStartSurah: map['PlannedStartSurah'],
      plannedStartAya: map['PlannedStartAya'],
      plannedEndSurah: map['PlannedEndSurah'],
      plannedEndAya: map['PlannedEndAya'],
      executedStartSurah: map['ExecutedStartSurah'],
      executedStartAya: map['ExecutedStartAya'],
      executedEndSurah: map['ExecutedEndSurah'],
      executedEndAya: map['ExecutedEndAya'],
      executedRate: map['ExecutedRate'] != null
          ? (map['ExecutedRate'] as num).toDouble()
          : 0.0,
      planMonth: map['PlanMonth'] ,
      isSync: map['isSync'],
    );
  }

  /// تحويل النموذج إلى Map للحفظ في Firestore
  Map<String, dynamic> toJson() {
    return {
      'conservationPlanId': conservationPlanId,
      'elhalagatId': elhalagatId,
      'studentId': studentId,
      'PlannedStartSurah': plannedStartSurah,
      'PlannedStartAya': plannedStartAya,
      'PlannedEndSurah': plannedEndSurah,
      'PlannedEndAya': plannedEndAya,
      'ExecutedStartSurah': executedStartSurah,
      'ExecutedStartAya': executedStartAya,
      'ExecutedEndSurah': executedEndSurah,
      'ExecutedEndAya': executedEndAya,
      'executedRate': executedRate,
      'planMonth': planMonth,
      'isSync': isSync,
    };
  }
}
