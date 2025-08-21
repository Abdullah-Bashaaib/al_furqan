class SchoolModel {
  int? schoolID, user_id;
  String? school_name;
  String? school_location;
  int? isSync;

  SchoolModel(
      {this.schoolID, this.school_name, this.school_location, this.user_id, this.isSync});

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      schoolID: json['SchoolID'] as int?,
      user_id: json['user_id'] as int?,
      school_name: json['school_name'] as String?,
      school_location: json['school_location'] as String?,
      isSync: json['isSync'] as int?,
    );
  }

}
