import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/school_controller.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/main.dart';
import 'package:al_furqan/models/provider/halaqa_provider.dart';
import 'package:al_furqan/models/provider/user_provider.dart';
import 'package:al_furqan/models/schools_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:al_furqan/views/SchoolDirector/main_screenD.dart';
import 'package:al_furqan/views/Supervisor/AdminHomePage.dart';
import 'package:al_furqan/views/Supervisor/mainScreenSupervisor.dart';
import 'package:al_furqan/views/Teacher/main_screenT.dart';
import 'package:al_furqan/views/auth/forgot_password_screen.dart';
import 'package:al_furqan/views/login/signup_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helper/current_user.dart';

String id = "";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final SqlDb sqlDb = SqlDb();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // _loadDataFromFirebase();
    loadSchoolsFromFirebase();
  }

  /// تحميل المستخدمين من Firebase
  // Future<void> loadUsersFromFirebase() async {
  //   List<UserModel> users = await firebasehelper.getUsers();
  //   for (var user in users) {
  //     bool exists =
  //         await sqlDb.checkIfitemExists2("Users", user.user_id!, "user_id");
  //     if (exists) {
  //       await userController.updateUser(user, 0);
  //       debugPrint('===== Find user (update) =====');
  //     } else {
  //       await userController.addUser(user, 0);
  //       debugPrint('===== Find user (add) =====');
  //     }
  //   }
  // }

  /// تحميل المدارس من Firebase
  Future<void> loadSchoolsFromFirebase() async {
    List<SchoolModel> schools = await firebasehelper.getSchool();
    for (var school in schools) {
      bool exists = await sqlDb.checkIfitemExists(
          "Schools", school.schoolID!, "schoolID");
      if (exists) {
        await schoolController.updateSchool(school, 0);
      } else {
        await schoolController.addSchool(school, 0);
      }
    }
  }

  Future<bool> isConnected() async {
    bool conn = await InternetConnectionChecker.createInstance().hasConnection;
    return conn;
  }

  /// تحميل البيانات من Firebase
  // Future<void> _loadDataFromFirebase() async {
  //   if (await isConnected()) {
  //     if (mounted) {
  //       setState(() => _isLoading = true);
  //     }
  //     try {
  //       // await loadUsersFromFirebase();
  //       await loadSchoolsFromFirebase();
  //     } catch (e) {
  //       debugPrint("Error loading data from Firebase: $e");
  //     } finally {
  //       if (mounted) {
  //         setState(() => _isLoading = false);
  //       }
  //     }
  //   } else {
  //     setState(() {
  //       _isLoading = false;
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text('لا يوجد اتصال بالانترنت لتحديث البيانات'),
  //         backgroundColor: Colors.red,
  //       ));
  //     });
  //   }
  // }

  /// حفظ بيانات تسجيل الدخول في SharedPreferences
  Future<void> saveUserLogin(
      String phoneUser, int roleId, int isActivate) async {
    await perf.setString('phoneUser', phoneUser);
    await perf.setInt('roleID', roleId);
    await perf.setInt('isActivate', isActivate);
    await perf.setBool('isLoggedIn', true);
    // print('===== sdsc sdsefsdx =====');
  }

  /// تسجيل الدخول باستخدام رقم الهاتف وكلمة المرور
  void _login(BuildContext context) async {
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    if (mounted) {
      setState(() => _isLoading = true);
    }

    /// التحقق من أن الحقول غير فارغة
    if (phone.isEmpty || password.isEmpty) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _showErrorDialog(context, "خطأ", "الرجاء إدخال رقم الجوال وكلمة المرور.");
      return;
    }

    /// التحقق من صحة بيانات تسجيل الدخول
    UserModel? user = await firebasehelper.getUserByPhone(phone);
    // (context).read<UserProvider>().user = user;
    // await userController.addUser(user!, 0);
    if (user != null) {
      await userController.saveUserToPrefs(user);
      CurrentUser.user = user;
      print('${CurrentUser.user}======================');
      print('$user ======================');
      if (user.roleID == 2) {
        print('object');
        await halagaController.getHalagatFromFirebaseByID(
            user.elhalagatID, 'halagaID');
      }
    }
    // sqlDb.getUser(phone, password);

    /// التحقق من أن المستخدم موجود
    if (user == null || user.user_id == null || user.password != password) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      Future<bool> conn =
          InternetConnectionChecker.createInstance().hasConnection;
      if (await conn) {
        _showErrorDialog(context, "خطأ", "بيانات تسجيل الدخول غير صحيحة.");
        return;
      } else {
        _showErrorDialog(context, "خطأ", "لا يوجد اتصال بالانترنت");
        return;
      }
    }

    /// التحقق من أن الحساب مفعل
    await chiceRole(user, context, phone);
  }

  /// اختيار الدور المناسب للمستخدم وتوجيهه إلى الشاشة المناسبة
  Future<void> chiceRole(
      UserModel user, BuildContext context, String phone) async {
    if (user.roleID == null || user.isActivate == 0) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _showErrorDialog(context, "خطأ", "حسابك غير مفعل، تواصل مع الإدارة.");
      return;
    }
    id = user.user_id!;
    String name = "${user.first_name!} ${user.last_name!}";
    await saveUserLogin(phone, user.roleID!, user.isActivate!);
    // final per = await SharedPreferences.getInstance();
    await perf.setString('user_id', id);
    if (user.roleID == 1 || user.roleID == 2) {
      await perf.setInt('schoolId', user.schoolID!);
    }
    await perf.setString('user_name', name);
    if (user.roleID == 2) {
      if (user.elhalagatID == null) {
        return;
      }
      await perf.setString('halagaID', user.elhalagatID!);
    }
    debugPrint('===== save id ($id) =====');
    String? halagaId = perf.getString('halagaID');

    if (user.roleID == 2) {
      if (halagaId == null || halagaId == 'null' || halagaId == 'NULL') {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        _showErrorDialog(context, "خطأ", "لا يوجد لديك حلقة تواصل مع الادارة");
        perf.clear();
      } else {
        await chooseScreen(context);
      }
    } else {
      await chooseScreen(context);
    }
  }

  /// اختيار الشاشة المناسبة للمستخدم بناءً على دوره
  Future<void> chooseScreen(BuildContext context) async {
    int? roleId = perf.getInt('roleID');
    if (roleId == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _showErrorDialog(context, "خطأ", "فشل في تحديد دور المستخدم.");
      return;
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
    switch (roleId) {
      case 0:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => MainScreenSupervisor()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainScreenD()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainScreenT()));
        break;
      default:
        _showErrorDialog(context, "خطأ", "حسابك غير مفعل، تواصل مع الإدارة.");
    }
  }

  /// عرض رسالة خطأ في حوار
  void _showErrorDialog(BuildContext context, String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: Text("موافق"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade100, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 1),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/pictures/al_furqan_icon.png',
                          height: 180,
                          width: MediaQuery.of(context).size.width * 0.7,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "مرحباً بك",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "سجل الدخول للوصول إلى حسابك",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    _buildTextField(
                      phoneController,
                      Icons.phone_android,
                      "رقم الهاتف",
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.lock_rounded, color: Colors.green),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        hintText: "كلمة المرور",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: Colors.green.shade200, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.green, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green.shade700,
                          padding: EdgeInsets.zero,
                          minimumSize: Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'نسيت كلمة المرور؟',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () => _login(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        shadowColor: Colors.green.withOpacity(0.5),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "تسجيل الدخول",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "ليس لديك حساب؟",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignupScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green.shade700,
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            minimumSize: Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            "إنشاء حساب",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// بناء حقل نصي مع أيقونة
  Widget _buildTextField(
      TextEditingController controller, IconData icon, String hint,
      {bool obscureText = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.green.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
