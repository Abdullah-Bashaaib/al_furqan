// models/password_reset_model.dart
class PasswordResetModel {
  int? phoneNumber;
  String? newPassword;
  String? verificationCode;
  String? generatedCode;
  bool codeSent = false;

  PasswordResetModel();

  bool get isValidCode => verificationCode == generatedCode;
  bool get isValidNewPassword => newPassword != null && newPassword!.length >= 6;
}