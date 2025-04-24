import 'package:al_furqan/controllers/some_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/password_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class UserController {
  final List<UserModel> _users = [];
  final List<UserModel> _requests = [];
  final SqlDb _sqlDb = SqlDb();
  final FirebaseHelper _service = FirebaseHelper();
  final PasswordResetModel _model = PasswordResetModel();


  List<UserModel> get users => _users;
  List<UserModel> get requests => _requests;
  List<UserModel> _mapResponseToUserModel(List<Map> response) {
    return response.map((data) {
      return UserModel(
        user_id: data['user_id'] as int?,
        first_name: data['first_name'],
        middle_name: data['middle_name'],
        grandfather_name: data['grandfather_name'],
        last_name: data['last_name'],
        phone_number: int.tryParse(data['phone_number'].toString()),
        telephone_number: int.tryParse(data['telephone_number'].toString()),
        email: data['email'],
        password: data['password'] as int?, // Ensure password is a string
        roleID: data['roleID'] as int?,
        schoolID: data['schoolID'] as int?,
        date: data['date'],
        isActivate: data['isActivate'] as int?,
      );
    }).toList();
  }

  Future<void> addRequest(UserModel userModel) async {
      userModel.user_id = await someController.newId("USERS", "user_id");
      int response = await _sqlDb.insertData('''
    INSERT INTO USERS (user_id, first_name, middle_name, grandfather_name, last_name, phone_number, telephone_number, email, password, roleID, schoolID, date, isActivate)
    VALUES (${userModel.user_id}, '${userModel.first_name}', '${userModel.middle_name}', '${userModel.grandfather_name}', '${userModel.last_name}', '${userModel.phone_number}', '${userModel.telephone_number}', '${userModel.email}', '${userModel.password}', ${userModel.roleID}, ${userModel.schoolID}, '${userModel.date}', 0);
    ''');
      print("request school id : ${userModel.schoolID}");
      print("response = $response, isActivate = ${userModel.isActivate}");
      await firebasehelper.addRequest(response, userModel);
    }

  // Method to get all data
  Future<void> getData() async {
    await getDataUsers();
    // await getDataRequests();
  }

  Future<void> getDataUsers() async {
    // 1. جلب البيانات من قاعدة البيانات المحلية (SQLite) أولاً
    List<Map> response =
        await _sqlDb.readData("SELECT * FROM USERS WHERE isActivate = 1");
    _users.clear();
    _users.addAll(_mapResponseToUserModel(response));
    print("Users List (Local): ${_users.isEmpty}");
  }

  Future<void> getDataRequests() async {
    // 1. جلب البيانات من قاعدة البيانات المحلية (SQLite) أولاً
    List<Map> response =
        await _sqlDb.readData("SELECT * FROM USERS WHERE isActivate = 0");
    _requests.clear();
    _requests.addAll(_mapResponseToUserModel(response));
    print("_requests List (Local): ${_requests.isEmpty}");
  }

  // Method to add a new user
  Future<void> addUser(UserModel userModel, int type) async {
    if(type == 1){
    userModel.user_id = await someController.newId("USERS", "user_id");
    int response = await _sqlDb.insertData('''
    INSERT INTO USERS (user_id, first_name, middle_name, grandfather_name, last_name, password, email, phone_number, telephone_number, roleID, schoolID, date, isActivate)
    VALUES (${userModel.user_id}, '${userModel.first_name}', '${userModel.middle_name}', '${userModel.grandfather_name}', '${userModel.last_name}', '${userModel.password}', '${userModel.email}', '${userModel.phone_number}', '${userModel.telephone_number}', ${userModel.roleID}, ${userModel.schoolID}, '${userModel.date}', '${userModel.isActivate}');
    ''');
    print("response = $response, isActivate = ${userModel.isActivate}");
    await firebasehelper.addUser(response, userModel);
    
  } else {
    userModel.user_id = await someController.newId("USERS", "user_id");
    int response = await _sqlDb.insertData('''
    INSERT INTO USERS (user_id, first_name, middle_name, grandfather_name, last_name, password, email, phone_number, telephone_number, roleID, schoolID, date, isActivate)
    VALUES (${userModel.user_id}, '${userModel.first_name}', '${userModel.middle_name}', '${userModel.grandfather_name}', '${userModel.last_name}', '${userModel.password}', '${userModel.email}', '${userModel.phone_number}', '${userModel.telephone_number}', ${userModel.roleID}, ${userModel.schoolID}, '${userModel.date}', '${userModel.isActivate}');
    ''');
    print("response = $response, isActivate = ${userModel.isActivate}");
  }
   }

  // Method to delete a user
  Future<void> deleteUser(int userId) async {
    int response =
        await _sqlDb.deleteData("DELETE FROM USERS WHERE user_id = $userId");
    print(response);
    await getDataUsers();
    // await firebasehelper.deleteUser(userId);
  }

  // Method to activate a user
  Future<void> activateUser(int userId) async {
    await _sqlDb.updateData('''
    UPDATE USERS SET isActivate = 1 WHERE user_id = $userId
    ''');
    await getData();
    await firebasehelper.activateUser(userId);
  }

  // Method to delete a request
  Future<void> deleteRequest(int userId) async {
    await _sqlDb.deleteData(
        "DELETE FROM USERS WHERE user_id = $userId AND isActivate = 0");
    await getDataRequests();
  }

  // Method to update a user
  Future<void> updateUser(UserModel userModel, int type) async {
    if (type == 1) {
      int response = await _sqlDb.updateData('''
    UPDATE USERS SET
      ActivityID = ${userModel.activityID},
      ElhalagatID = ${userModel.elhalagatID},
      first_name = '${userModel.first_name}',
      middle_name = '${userModel.middle_name}',
      grandfather_name = '${userModel.grandfather_name}',
      last_name = '${userModel.last_name}',
      password = '${userModel.password}',
      email = '${userModel.email}',
      phone_number = '${userModel.phone_number}',
      telephone_number = '${userModel.telephone_number}',
      roleID = ${userModel.roleID},
      schoolID = ${userModel.schoolID},
      date = '${userModel.date}',
      isActivate = ${userModel.isActivate}
    WHERE user_id = ${userModel.user_id}
    ''');
      print("response = $response");

      await firebasehelper.updateUser(userModel.user_id!, userModel);
      // await getData();
    } else {
      int response = await _sqlDb.updateData('''
    UPDATE USERS SET
      ActivityID = ${userModel.activityID},
      ElhalagatID = ${userModel.elhalagatID},
      first_name = '${userModel.first_name}',
      middle_name = '${userModel.middle_name}',
      grandfather_name = '${userModel.grandfather_name}',
      last_name = '${userModel.last_name}',
      password = '${userModel.password}',
      email = '${userModel.email}',
      phone_number = '${userModel.phone_number}',
      telephone_number = '${userModel.telephone_number}',
      roleID = ${userModel.roleID},
      schoolID = ${userModel.schoolID},
      date = '${userModel.date}',
      isActivate = ${userModel.isActivate}
    WHERE user_id = ${userModel.user_id}
    ''');
      print("response = $response");
    }
  }
  // إرسال رمز التحقق
  Future<void> sendVerificationCode(int phoneNumber) async {
    _model.phoneNumber = phoneNumber;
    _model.generatedCode = await _service.sendWhatsAppVerification(phoneNumber);
    _model.codeSent = true;
  }

  // تغيير كلمة المرور
  Future<void> resetPassword() async {
    if (!_model.isValidCode) {
      throw 'رمز التحقق غير صحيح';
    }

    if (!_model.isValidNewPassword) {
      throw 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }

    await _service.updatePassword(
      _model.phoneNumber!,
      _model.newPassword!,
    );
  }

  // Getters للوصول إلى بيانات النموذج
  bool get codeSent => _model.codeSent;
    int? get phoneNumber => _model.phoneNumber;
  
  // Setters لتحديث بيانات النموذج
  set verificationCode(String code) => _model.verificationCode = code;
  set newPassword(String password) => _model.newPassword = password;
}


UserController userController = UserController();
