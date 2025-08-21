import 'dart:developer';
import 'package:flutter/material.dart';
import '../../services/sync.dart';
import 'SchoolDirectorHome.dart';

class MainScreenD extends StatefulWidget {
  const MainScreenD({super.key});
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreenD> {
  bool isLoading = true;
  // bool hasError = false;
  // String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // بعد الإطار الأوّل، نبدأ التحميل
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataAndNavigate();
    });
  }

  Future<void> _loadDataAndNavigate() async {
    // 1) تحقّق من الاتصال
    // final connected = await InternetConnectionChecker().hasConnection;
    // if (!connected) {
    //   setState(() {
    //     isLoading = false;
    //     // hasError = true;
    //     // errorMessage =
    //     //     'لا يوجد اتصال بالإنترنت. الرجاء التحقق ثم إعادة المحاولة.';
    //   });
    //   return;
    // }

    try {
      // 2) مزامنات الـsync عبر alias
      final sw = Stopwatch()..start();
      await sync.syncUsers();
      await sync.syncElhalagat();
      await sync.syncStudents();
      sw.stop();
      log('Total load+sync: ${sw.elapsedMilliseconds} ms');

      // 3) عند النجاح: استبدال الشاشة وإزالة شاشة التحميل
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => SchoolManagerScreen(),
        ),
        (route) => false, // يحذف كل الشاشات السابقة
      );
    } catch (e) {
      // 4) واجهة الخطأ
      log('Load error: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        // hasError = true;
        // errorMessage = 'فشل في تحميل البيانات:\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // شاشة التحميل
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('جاري التحميل...',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor)),
      );
    }

    // شاشة الخطأ مع زر إعادة المحاولة
    // if (hasError) {
    //   return Scaffold(
    //     appBar: AppBar(
    //       title: Text('خطأ', style: TextStyle(fontWeight: FontWeight.bold)),
    //       backgroundColor: Colors.red,
    //     ),
    //     body: Center(
    //       child: Padding(
    //         padding: EdgeInsets.all(24),
    //         child: Column(mainAxisSize: MainAxisSize.min, children: [
    //           Text(errorMessage, textAlign: TextAlign.center),
    //           SizedBox(height: 16),
    //           ElevatedButton(
    //             onPressed: () {
    //               setState(() {
    //                 isLoading = true;
    //                 hasError = false;
    //               });
    //               _loadDataAndNavigate();
    //             },
    //             child: Text('إعادة المحاولة'),
    //           ),
    //         ]),
    //       ),
    //     ),
    //   );
    // }

    // غالبًا لن نصل إلى هنا
    return SizedBox.shrink();
  }
}
