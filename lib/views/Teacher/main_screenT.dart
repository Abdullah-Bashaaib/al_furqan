import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/plan_controller.dart';
import 'package:al_furqan/main.dart';
import 'package:al_furqan/utils/utils.dart';
import 'package:al_furqan/views/Teacher/mainTeacher.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../../services/message_sevice.dart';
import '../../services/sync.dart';
// import '../../services/sync.dart';

class MainScreenT extends StatefulWidget {
  const MainScreenT({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreenT> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    // Clean up any controllers, streams, or other resources here
    super.dispose();
  }

  Future<bool> isConnected() async {
    var conn = InternetConnectionChecker.createInstance().hasConnection;
    return conn;
  }

  Future<void> load() async {
    if (await isConnected()) {
      await sync.syncUsers();
      await sync.syncElhalagat();
      await sync.syncStudents();
      await loadStudent();
      await loadPlans();

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => TeacherDashboard()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => TeacherDashboard()));
      Utils.showToast('لا يوجد اتصال بالانترنت لتحديث البيانات',
          backgroundColor: Colors.redAccent);
    }
  }

  // Future<void> loadMessages() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     String? id = prefs.getString('user_id');
  //     debugPrint('===== ($id) =====');
  //     // تحميل الرسائل من فايربيس
  //     await messageService.loadMessagesFromFirestore(id!);
  //   } catch (e) {
  //     debugPrint('خطأ في تحميل الرسائل: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('خطأ في تحميل الرسائل'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  //   setState(() {
  //     isLoading = true;
  //   });
  // }

  // Future<void> loadHalagat() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     String? Id = prefs.getString('halagaID');
  //     debugPrint('===== halagaID ($Id) =====');
  //     // تحميل الحلقات من فايربيس
  //     await halagaController.getHalagatFromFirebaseByID(Id!, 'halagaID');
  //   } catch (e) {
  //     debugPrint('خطأ في تحميل الحلقات: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('خطأ في تحميل الحلقات'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  Future<void> loadStudent() async {
    try {
      String? halagaID = perf.getString('halagaID');
      await studentController.addToLocalStudentH(halagaID!);
      await studentController.getStudents(halagaID);
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? Id = prefs.getString('halagaID');
      debugPrint('===== halagaID ($Id) =====');
      // تحميل الرسائل من فايربيس
      await planController.getPlansFirebaseToLocal(Id!);
    } catch (e) {
      debugPrint('خطأ في تحميل البيانات: $e');
      Utils.showToast('خطأ في تحميل البيانات: $e', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: Text('جاري التحميل...',
                style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                    color: Theme.of(context).primaryColor),
                SizedBox(height: 16),
                Text(
                  'جاري تحميل البيانات...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return TeacherDashboard();
  }
}
