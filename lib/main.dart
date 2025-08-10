import 'package:al_furqan/models/provider/halaqa_provider.dart';
import 'package:al_furqan/models/provider/message_provider.dart';
import 'package:al_furqan/models/provider/student_provider.dart';
import 'package:al_furqan/models/provider/user_provider.dart';
import 'package:al_furqan/views/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

late SharedPreferences perf;

void main() async {
  // ErrorWidget.builder = (FlutterErrorDetails details) {
  //   return Material(
  //     child: Center(
  //       child: Text(
  //         'حدث خطا ما الرجاء اعادة تشغيل التطبيق',
  //         style: TextStyle(color: Colors.red, fontSize: 20),
  //         textDirection: TextDirection.rtl,
  //       ),
  //     ),
  //   );
  // };
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  perf = await SharedPreferences.getInstance();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => HalaqaProvider()),
      ChangeNotifierProvider(create: (_) => MessageProvider()),
      ChangeNotifierProvider(create: (_) => StudentProvider())
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      title: "الفرقان",
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 1, 117, 70)),
        useMaterial3: true,
        fontFamily: 'RB',
      ),
      locale: Locale('ar'), // تحديد اللغة الافتراضية
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl, // جعل التطبيق بالكامل RTL
          child: child!,
        );
      },
      home: SplashScreen(),
    );
  }
}
