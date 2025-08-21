class StudentModel {
  String? studentID;
  String? elhalaqaID;
  int? schoolId;
  String? userID; // father
  String? firstName;
  String? middleName;
  String? grandfatherName;
  String? lastName;
  int? attendanceDays;
  int? absenceDays;
  String? excuse;
  String? reasonAbsence;
  int? isSync;

  StudentModel(
      {this.studentID,
      this.elhalaqaID,
      this.schoolId,
      this.userID,
      this.firstName,
      this.middleName,
      this.grandfatherName,
      this.lastName,
      this.attendanceDays,
      this.absenceDays,
      this.excuse,
      this.reasonAbsence,
      this.isSync});

  Map<String, dynamic> toMap() {
    return {
      'StudentID': studentID,
      'ElhalagatID': elhalaqaID,
      'SchoolID': schoolId,
      'userID': userID,
      'FirstName': firstName,
      'MiddleName': middleName,
      'grandfatherName': grandfatherName,
      'LastName': lastName,
      'AttendanceDays': attendanceDays,
      'AbsenceDays': absenceDays,
      'Excuse': excuse,
      'ReasonAbsence': reasonAbsence,
      'isSync': isSync
    };
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    // معالجة ElhalagatID إذا كان نصاً
    String? elhalaqaID;
    if (json['ElhalagatID'] != null) {
      if (json['ElhalagatID'] is String) {
        elhalaqaID = json['ElhalagatID'];
      } else {
        elhalaqaID = json['ElhalagatID'] as String?;
      }
    }

    return StudentModel(
        studentID: json['StudentID'],
        elhalaqaID: elhalaqaID,
        schoolId: json['SchoolID'],
        userID: json['userID'],
        firstName: json['FirstName'],
        middleName: json['MiddleName'],
        grandfatherName: json['grandfatherName'],
        lastName: json['LastName'] as String?,
        attendanceDays: json['AttendanceDays'],
        absenceDays: json['AbsenceDays'],
        excuse: json['Excuse'] as String?,
        reasonAbsence: json['ReasonAbsence'],
        isSync: json['isSync']);
  }
}
