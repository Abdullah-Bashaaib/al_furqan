class ReportModel {
  final String halagaName;
  final String teacherName;
  final int numberStudent;
  // final rate;
  final double attendanceRate;
  final double eltlawahRate;
  final double conservationRate;
  final double islamicRate;
  // final int activitiesCount;
  final String notes;

  ReportModel(
    this.teacherName,
    this.numberStudent,
    this.eltlawahRate,
    this.conservationRate,
    this.islamicRate,
    this.halagaName,
    this.notes,
    this.attendanceRate,
    // this.activitiesCount,
  );

  Map<String, dynamic> toMap() {
    return {
      'halagaName': halagaName,
      'teacherName': teacherName,
      'numberStudent': numberStudent,
      'eltlawahRate': eltlawahRate,
      'conservationRate': conservationRate,
      'islamicRate': islamicRate,
      'attendanceRate': attendanceRate,
      'note': notes
    };
  }
}
