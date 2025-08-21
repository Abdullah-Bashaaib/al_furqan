class HalagaModel {
  String? halagaID;
  int? SchoolID;
  String? Name;
  int? NumberStudent;
  double? AttendanceRate;
  String? teacherName;
  int? isSync;

  HalagaModel(
      {this.halagaID,
      this.SchoolID,
      this.Name,
      this.NumberStudent,
      this.AttendanceRate,
      this.teacherName,
      this.isSync});

  factory HalagaModel.fromJson(Map<String, dynamic> json) {
    return HalagaModel(
      halagaID: json['halagaID'] ?? "",
      SchoolID: json['SchoolID'],
      Name: json['Name'],
      NumberStudent: json['NumberStudent'],
      AttendanceRate: json['AttendanceRate'],
      isSync: json['isSync'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'halagaID': halagaID,
      'SchoolID': SchoolID,
      'Name': Name,
      'NumberStudent': NumberStudent,
      'AttendanceRate': AttendanceRate,
      'isSync': isSync,
    };
  }
}
