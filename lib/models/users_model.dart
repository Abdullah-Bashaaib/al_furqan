class UserModel {
  String? user_id;
  int? activityID;
  String? elhalagatID;
  String? first_name;
  String? middle_name;
  String? grandfather_name;
  String? last_name;
  int? phone_number;
  int? telephone_number;
  String? email;
  String? password;
  int? roleID;
  int? schoolID;
  String? date; // إضافة حقل تاريخ الميلاد
  int? isActivate; // إضافة حقل تفعيل المستخدم
  int? isSync;

  UserModel({
    this.user_id,
    this.activityID,
    this.elhalagatID,
    this.first_name,
    this.middle_name,
    this.grandfather_name,
    this.last_name,
    this.phone_number,
    this.telephone_number,
    this.email,
    this.password,
    this.roleID,
    this.schoolID = 0,
    this.date,
    this.isActivate = 0,
    this.isSync,
  });

  // تحويل الكائن إلى Map
  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'ActivityID': activityID,
      'ElhalagatID': elhalagatID,
      'first_name': first_name,
      'middle_name': middle_name,
      'grandfather_name': grandfather_name,
      'last_name': last_name,
      'phone_number': phone_number,
      'telephone_number': telephone_number,
      'email': email,
      'password': password,
      'roleID': roleID,
      'schoolID': schoolID,
      'date': date,
      'isActivate': isActivate,
      'isSync': isSync
    };
  }

  // تحويل Map إلى كائن UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        user_id: map['user_id'].toString(),
        activityID: map['ActivityID'] as int?,
        elhalagatID: map['ElhalagatID'].toString(),
        first_name: map['first_name'].toString(),
        middle_name: map['middle_name'].toString(),
        grandfather_name: map['grandfather_name'].toString(),
        last_name: map['last_name'].toString(),
        phone_number: map['phone_number'] as int?,
        telephone_number: map['telephone_number'] as int?,
        email: map['email'].toString(),
        password: map['password'].toString(),
        roleID: map['roleID'] as int?,
        schoolID: map['schoolID'] as int?,
        date: map['date'].toString(),
        isActivate: map['isActivate'] as int?,
        isSync: map['isSync'] as int?);
  }
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        user_id: json['user_id'] as String?,
        activityID: json['ActivityID'] as int?,
        elhalagatID: json['ElhalagatID'] as String?,
        first_name: json['first_name'] as String?,
        middle_name: json['middle_name'] as String?,
        grandfather_name: json['grandfather_name'] as String?,
        last_name: json['last_name'] as String?,
        phone_number: json['phone_number'] as int?,
        telephone_number: json['telephone_number'] as int?,
        email: json['email'] as String?,
        password: json['password'] as String?,
        roleID: json['roleID'] as int?,
        schoolID: json['schoolID'] as int?,
        date: json['date'] as String?,
        isActivate: json['isActivate'] as int?,
        isSync: json['isSync']);
  }
}

