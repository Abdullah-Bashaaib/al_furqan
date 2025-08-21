class RolesModel {
  int? roleID, isSync;
  String? roleName, roleDescription;

  RolesModel({this.roleID, this.roleName, this.roleDescription, int? isSync});

  factory RolesModel.fromJeson(Map<String, dynamic> map) {
    return RolesModel(
        roleID: map['roleID3'] as int?,
        isSync: map['isSync'] as int?,
        roleName: map['role_name'] as String?,
        roleDescription: map['role_description'] as String?);
  }

  Map<String, dynamic> toMap() {
    return {
      'roleID': roleID,
      'role_name': roleName,
      'role_description': roleDescription,
      'isSync': isSync,
    };
  }
}