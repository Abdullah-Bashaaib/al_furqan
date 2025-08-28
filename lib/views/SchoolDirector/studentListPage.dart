// ignore_for_file: file_names
import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/provider/student_provider.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:al_furqan/views/SchoolDirector/AddStudent.dart';
import 'package:al_furqan/views/SchoolDirector/updateStudent.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

class StudentsListPage extends StatefulWidget {
  final UserModel? user;
  const StudentsListPage({super.key, this.user});

  @override
  State<StudentsListPage> createState() => _StudentsListPageState();
}

class _StudentsListPageState extends State<StudentsListPage> {
  final sqlDb = SqlDb();
  final halagaController = HalagaController();
  // List<StudentModel> students = [];
  // List<UserModel> fathers = [];
  // Map<String?, String> halaqaNames = {}; // To store halaqat names by ID
  // List<HalagaModel> halaqat = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      (context).read<StudentProvider>().loadStudentFromFirebase();
    });
    // int? schoolID = perf.getInt('schoolId');
    // studentController.addToLocalOfFirebase(schoolID!);

    // _loadStudent();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// تتحقق من اتصال بالانترنت
  Future<bool> checkInternet() async {
    bool hasInternet =
        await InternetConnectionChecker.createInstance().hasConnection;
    return hasInternet;
  }

  /// تحمل آباء الطلاب
  // Future<void> _loadFathersStudents() async {
  //   List<UserModel> temp = [];
  //   if (mounted) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  //   debugPrint("==> بداية تحميل آباء الطلاب <==");
  //   for (var i = 0; i < students.length; i++) {
  //     if (students[i].userID != null) {
  //       final dad = await fathersController.getFatherByID(students[i].userID!);
  //       temp.add(dad);
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           behavior: SnackBarBehavior.floating,
  //           backgroundColor: Colors.red,
  //           content: Text(
  //             "المصفوفة فارغة أو معرف الطالب غير موجود!",
  //           ),
  //         ),
  //       );
  //     }
  //   }
  //   if (mounted) {
  //     setState(() {
  //       fathers = temp;
  //       isLoading = false;
  //     });
  //   }
  //   log(">>> Fathers length: ${fathers.length}");
  //   for (var i = 0; i < fathers.length; i++) {
  //     log("father[$i].userID = ${fathers[i].user_id}");
  //   }
  // }

  /// تحمل اسم الحلقة
  // Future<void> _loadHalaqaNames(int schoolID) async {
  //   try {
  //     halaqat = await halagaController.getData(schoolID);
  //     debugPrint("تم جلب ${halaqat.length} حلقة من المدرسة $schoolID");
  //     Map<String?, String> names = {};
  //     for (var halqa in halaqat) {
  //       if (halqa.halagaID != null) {
  //         names[halqa.halagaID] = halqa.Name ?? 'حلقة بدون اسم';
  //         debugPrint("إضافة حلقة: ${halqa.halagaID} -> ${halqa.Name}");
  //       }
  //     }
  //     if (mounted) {
  //       setState(() {
  //         halaqaNames = names;
  //       });
  //     }
  //     debugPrint("تم تحميل ${halaqaNames.length} حلقة في القاموس");
  //   } catch (e) {
  //     debugPrint("خطأ في تحميل أسماء الحلقات: $e");
  //   }
  // }

  /* تحمل الحلقات المرتبطة بالطالب */
  // Future<void> _loadHalaqat(String halagaID) async {
  //   halaqat = await halagaController.getHalagaByHalagaID(halagaID);
  // }

  // تحمل الطلاب من باستخدام معرف المدرسة
  // Future<void> _loadStudent() async {
  //   if (mounted) {
  //     setState(() {
  //       isLoading = true;
  //     });
  //   }
  //   debugPrint("=== بداية تحميل بيانات الطلاب ===");
  //   int schoolID = widget.user!.schoolID!;
  //   debugPrint("معرف المدرسة: $schoolID");
  //   // تحميل أسماء الحلقات أولاً
  //   await _loadHalaqaNames(schoolID);
  //   // تحميل البيانات من القاعدة المحلية فقط
  //   debugPrint("جاري تحميل البيانات من قاعدة البيانات المحلية...");
  //   List<StudentModel>? loadedStudent =
  //       await studentController.getSchoolStudents(schoolID);
  //   debugPrint(
  //       "تم تحميل ${loadedStudent.length ?? 0} طالب من قاعدة البيانات المحلية");
  //   if (mounted) {
  //     setState(() {
  //       students = loadedStudent;
  //       log("student [father ID :\n ${loadedStudent.map((e) => e.userID).join('\n ')}]");

  //       isLoading = false;
  //       debugPrint("تم تحديث واجهة المستخدم بـ ${students.length} طالب");
  //     });
  //   }
  //   debugPrint("=== انتهاء تحميل بيانات الطلاب ===");

  //   await _loadFathersStudents();
  // }

  // String getHalaqaName(String? halaqaId) {
  //   if (halaqaId == null) {
  //     debugPrint("الطالب بدون حلقة (معرف الحلقة: null)");
  //     return 'بدون حلقة';
  //   }
  //   String halaqaName = halaqaNames[halaqaId] ?? 'بدون حلقة';
  //   debugPrint(
  //       "معرف الحلقة: $halaqaId، اسم الحلقة: $halaqaName، القاموس يحتوي على: ${halaqaNames.keys.toList()}");
  //   return halaqaName;
  // }

  @override
  Widget build(BuildContext context) {
    // if (isLoading || fathers.length < students.length) {
    //   return Center(child: CircularProgressIndicator());
    // }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text('طلاب المدرسة',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<StudentProvider>().loadStudentFromFirebase();
            },
          )
        ],
      ),
      body: Consumer<StudentProvider>(
        builder: (context, prov, child) =>
            //isLoading ||
            //         prov.fathers.length < prov.students.length
            //     ? Center(child: CircularProgressIndicator(color: Colors.teal))
            // :
            Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'عدد الطلاب: ${prov.students.length}',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            Expanded(
              child: prov.students.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off, size: 48, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('لا يوجد طلاب', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: prov.students.length,
                      itemBuilder: (context, index) {
                        final student = prov.students[index];
                        final father = prov.fathers[index];
                        // final halaqaName =
                        //     getHalaqaName(student.elhalaqaID);

                        // Only load halaqat if there is a valid ID

                        student.elhalaqaID == null
                            ? "الطالب: بدون حلقة"
                            : "الحلقة: ${prov.halaqaNames[student.elhalaqaID] ?? 'غير معروف'}";
                        return Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              child: Text("${index + 1}"),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "${student.firstName ?? ''} ${student.lastName ?? ''}",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.group,
                                      size: 16,
                                      color: student.elhalaqaID == null
                                          ? Colors.red
                                          : Colors.teal,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      student.elhalaqaID == null
                                          ? "الطالب: بدون حلقة"
                                          : "الحلقة: ${prov.halaqat.firstWhere((h) => h.halagaID == student.elhalaqaID, orElse: () => HalagaModel(Name: 'غير معروف')).Name}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: student.elhalaqaID == null
                                            ? Colors.red
                                            : Colors.grey[800],
                                        fontWeight: student.elhalaqaID == null
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.teal),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditStudentScreen(
                                          student: student,
                                          father: father,
                                        ),
                                      ),
                                    ).then((_) => prov.loadStudents());
                                  },
                                ),
                                IconButton(
                                  onPressed: () async {
                                    if (!mounted) return;
                                    bool confirm = await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('تأكيد الحذف'),
                                              content: Text(
                                                  'هل أنت متأكد من حذف هذا الطالب؟'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text('إلغاء'),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(false),
                                                ),
                                                TextButton(
                                                  child: Text('حذف'),
                                                  onPressed: () async {
                                                    Navigator.of(context)
                                                        .pop(true);
                                                    await prov.loadStudents();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        ) ??
                                        false;
                                    if (confirm) {
                                      try {
                                        final messenger =
                                            ScaffoldMessenger.maybeOf(context);
                                        await studentController
                                            .delete(student.studentID!);
                                        if (await checkInternet()) {
                                          await firebasehelper.delete(
                                              student.studentID!, "Students");
                                        }
                                        if (!context.mounted) return;
                                        if (messenger == null) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('تم حذف الطالب بنجاح')),
                                        );
                                        await prov.loadStudents();
                                      } catch (e) {
                                        final messenger =
                                            ScaffoldMessenger.maybeOf(context);
                                        if (!context.mounted ||
                                            messenger == null) {
                                          return;
                                        }
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  ' ${e.toString()} في حذف الطالب')),
                                        );
                                      }
                                    }
                                  },
                                  icon: Icon(Icons.delete),
                                  color: Colors.redAccent,
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditStudentScreen(
                                    student: student,
                                    father: father,
                                  ),
                                ),
                              ).then((_) => prov.loadStudents());
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddStudentScreen(user: widget.user)),
          ).then((_) => context.read<StudentProvider>().loadStudents());
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
