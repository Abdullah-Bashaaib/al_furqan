// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Supervisor/AdminHomePage.dart';
// import '../SchoolDirector/SchoolDirectorHome.dart';
// import '../Teacher/mainTeacher.dart';
// import 'signup_screen.dart';

// int id = 0;

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool _isLoading = false;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   /// حفظ بيانات تسجيل الدخول في SharedPreferences
//   Future<void> saveUserLogin(
//       String email, int roleId, int isActivate, String userId) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('email', email);
//     await prefs.setInt('roleID', roleId);
//     await prefs.setInt('isActivate', isActivate);
//     await prefs.setString('userId', userId);
//     await prefs.setBool('isLoggedIn', true);
//   }

//   /// تسجيل خروج المستخدم وحذف جميع البيانات المحفوظة
//   Future<void> logoutUser() async {
//     await _auth.signOut();
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//     Navigator.pushReplacement(
//         context, MaterialPageRoute(builder: (context) => const LoginScreen()));
//   }

//   /// التحقق مما إذا كان المستخدم مسجل الدخول
//   Future<bool> isUserLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('isLoggedIn') ?? false;
//   }

//   /// الحصول على البريد الإلكتروني المحفوظ
//   Future<String?> getUserEmail() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('email');
//   }

//   /// الحصول على رقم الدور المحفوظ
//   Future<int?> getUserRoleId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getInt('roleID');
//   }

//   /// الحصول على رقم التفعيل المحفوظ
//   Future<int?> getIsActivate() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getInt('isActivate');
//   }

//   /// الحصول على معرف المستخدم المحفوظ
//   Future<String?> getUserId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('userId');
//   }

//   /// التحقق من حالة تسجيل الدخول
//   void _checkLoginStatus() async {
//     bool isLogin = await isUserLoggedIn();
//     if (isLogin) {
//       _loginPref();
//     }
//   }

//   /// تسجيل الدخول باستخدام البيانات المحفوظة
//   void _loginPref() async {
//     setState(() => _isLoading = true);
//     try {
//       int? roleId = await getUserRoleId();
//       int? isActivate = await getIsActivate();
//       String? userId = await getUserId();
//       setState(() => _isLoading = false);
//       if (roleId != null && userId != null) {
//         id = int.parse(userId);
//         await chooseScreen(context);
//       } else {
//         _showErrorDialog(context, "خطأ", "حسابك غير مفعل أو بيانات غير صحيحة.");
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showErrorDialog(context, "خطأ", "حدث خطأ: $e");
//     }
//   }

//   /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
//   void _login(BuildContext context) async {
//     String email = emailController.text.trim();
//     String password = passwordController.text.trim();
//     setState(() => _isLoading = true);

//     if (email.isEmpty || password.isEmpty) {
//       setState(() => _isLoading = false);
//       _showErrorDialog(context, "خطأ", "الرجاء إدخال البريد الإلكتروني وكلمة المرور.");
//       return;
//     }

//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       DocumentSnapshot userDoc = await _firestore
//           .collection('users')
//           .doc(userCredential.user!.uid)
//           .get();

//       if (!userDoc.exists) {
//         setState(() => _isLoading = false);
//         _showErrorDialog(context, "خطأ", "بيانات المستخدم غير موجودة.");
//         return;
//       }

//       Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
//       int roleId = userData['roleID'] ?? -1;
//       int isActivate = userData['isActivate'] ?? 0;

//       if (isActivate == 0) {
//         setState(() => _isLoading = false);
//         _showErrorDialog(context, "خطأ", "حسابك غير مفعل، تواصل مع الإدارة.");
//         return;
//       }

//       id = int.parse(userCredential.user!.uid);
//       await saveUserLogin(email, roleId, isActivate, userCredential.user!.uid);
//       setState(() => _isLoading = false);
//       await chooseScreen(context);
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showErrorDialog(context, "خطأ", "فشل تسجيل الدخول: ${e.toString()}");
//     }
//   }

//   /// اختيار الشاشة المناسبة للمستخدم بناءً على دوره
//   Future<void> chooseScreen(BuildContext context) async {
//     int? roleId = await getUserRoleId();
//     if (roleId == null) {
//       _showErrorDialog(context, "خطأ", "فشل في تحديد دور المستخدم.");
//       return;
//     }
//     switch (roleId) {
//       case 0:
//         Navigator.pushReplacement(context,
//             MaterialPageRoute(builder: (context) => DashboardScreen()));
//         break;
//       case 1:
//         Navigator.pushReplacement(context,
//             MaterialPageRoute(builder: (context) => SchoolManagerScreen()));
//         break;
//       case 2:
//         Navigator.pushReplacement(context,
//             MaterialPageRoute(builder: (context) => TeacherDashboard()));
//         break;
//       default:
//         _showErrorDialog(context, "خطأ", "حسابك غير مفعل، تواصل مع الإدارة.");
//     }
//   }

//   /// عرض رسالة خطأ في حوار
//   void _showErrorDialog(BuildContext context, String title, String content) {
//     showCupertinoDialog(
//       context: context,
//       builder: (context) => CupertinoAlertDialog(
//         title: Text(title),
//         content: Text(content),
//         actions: [
//           CupertinoDialogAction(
//             child: const Text("موافق"),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Center(
//               child: Column(
//                 children: [
//                   Text(
//                     "مرحباً",
//                     style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     "سجل الدخول باستخدام بريدك الإلكتروني",
//                     style: TextStyle(fontSize: 16, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),
//             _buildTextField(
//                 emailController, Icons.email, "البريد الإلكتروني"),
//             const SizedBox(height: 15),
//             _buildTextField(
//                 passwordController, Icons.lock, "كلمة المرور",
//                 obscureText: true),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => _login(context),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(25),
//                 ),
//               ),
//               child: const Text("سجل الدخول",
//                   style: TextStyle(fontSize: 18, color: Colors.white)),
//             ),
//             const SizedBox(height: 10),
//             Center(
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const SignupScreen(),
//                     ),
//                   );
//                 },
//                 child: const Text(
//                   "ليس لديك حساب؟ إنشاء حساب",
//                   style: TextStyle(
//                     color: Colors.blue,
//                     decoration: TextDecoration.underline,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// بناء حقل نصي مع أيقونة
//   Widget _buildTextField(
//       TextEditingController controller, IconData icon, String hint,
//       {bool obscureText = false}) {
//     return TextField(
//       controller: controller,
//       obscureText: obscureText,
//       decoration: InputDecoration(
//         prefixIcon: Icon(icon, color: Colors.green),
//         hintText: hint,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(25),
//         ),
//       ),
//     );
//   }
// }
