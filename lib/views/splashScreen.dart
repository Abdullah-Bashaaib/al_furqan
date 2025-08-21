import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/current_user.dart';
import 'package:al_furqan/main.dart';
import 'package:al_furqan/models/provider/user_provider.dart';
import 'package:al_furqan/views/SchoolDirector/main_screenD.dart';
import 'package:al_furqan/views/Supervisor/AdminHomePage.dart';
import 'package:al_furqan/views/SchoolDirector/SchoolDirectorHome.dart';
import 'package:al_furqan/views/Supervisor/mainScreenSupervisor.dart';
import 'package:al_furqan/views/Teacher/mainTeacher.dart';
import 'package:al_furqan/views/Teacher/main_screenT.dart';
import 'package:al_furqan/views/login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // loadUserAndHalaga();
    // _checkLoginStatus();
    init();
  }

  init() async {
    await loadUserAndHalaga();
    _checkLoginStatus();
  }

  Future<void> loadUserAndHalaga() async {
    String? hID = perf.getString('halagaID');
    CurrentUser.user = await userController.loadUserFromPrefs();
    if (hID != null) {
      // print('====== 1111111111111111111111111111111111111111111 ======');
      CurrentUser.halaga = await halagaController.getHalagaByHalagaID(hID);
    }
    // print(CurrentUser.user);
  }

  /// التحقق مما إذا كان المستخدم مسجل الدخول
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  /// الحصول على رقم الدور المحفوظ في SharedPreferences
  Future<int?> getUserRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('roleID');
  }

  /// الحصول على رقم التفعيل المحفوظ في SharedPreferences
  Future<int?> getIsActivate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('isActivate');
  }

  /// التحقق من حالة تسجيل الدخول وتوجيه المستخدم
  void _checkLoginStatus() async {
    debugPrint(
        "----------------------Here check Login Status--------------------------");
    bool isLogin = await isUserLoggedIn();
    debugPrint("-------------: $isLogin");
    if (isLogin) {
      debugPrint(
          "----------------------Here if check Login Status--------------------------");
      _loginPref();
    } else {
      // الانتقال إلى شاشة تسجيل الدخول إذا لم يكن هناك مستخدم مسجل
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  /// تسجيل الدخول باستخدام البيانات المحفوظة في SharedPreferences
  void _loginPref() async {
    try {
      int? roleId = await getUserRoleId();
      int? isActivate = await getIsActivate();
      if (roleId != null) {
        await chooseScreen(context);
      } else {
        _showErrorDialog(context, "خطأ", "حسابك غير مفعل أو بيانات غير صحيحة.");
      }
    } catch (e) {
      _showErrorDialog(context, "خطأ", "حدث خطأ: $e");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  /// اختيار الشاشة المناسبة للمستخدم بناءً على دوره
  Future<void> chooseScreen(BuildContext context) async {
    int? roleId = await getUserRoleId();
    if (roleId == null) {
      _showErrorDialog(context, "خطأ", "فشل في تحديد دور المستخدم.");
      return;
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade100, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/pictures/al_furqan_icon.png',
                  height: 180,
                  width: MediaQuery.of(context).size.width * 0.7,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.green),
              SizedBox(height: 20),
              Text(
                "جاري التحميل...",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
