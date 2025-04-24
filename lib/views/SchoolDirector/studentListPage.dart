import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/controllers/fathers_controller.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:al_furqan/views/SchoolDirector/AddStuden.dart';
import 'package:al_furqan/views/SchoolDirector/updateStudent.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class StudentsListPage extends StatefulWidget {
  final UserModel? user;
  StudentsListPage({super.key, this.user});

  @override
  State<StudentsListPage> createState() => _StudentsListPageState();
}

class _StudentsListPageState extends State<StudentsListPage> {
  final sqlDb = SqlDb();
  final halagaController = HalagaController();
  List<StudentModel> students = [];
  Map<int?, String> halaqaNames = {}; // To store halaqat names by ID
  List<HalagaModel> halaqat = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadHalaqaNames(int schoolID) async {
    try {
      halaqat = await halagaController.getData(schoolID);
      print("تم جلب ${halaqat.length} حلقة من المدرسة $schoolID");

      Map<int?, String> names = {};

      for (var halqa in halaqat) {
        if (halqa.halagaID != null) {
          names[halqa.halagaID] = halqa.Name ?? 'حلقة بدون اسم';
          print("إضافة حلقة: ${halqa.halagaID} -> ${halqa.Name}");
        }
      }

      setState(() {
        halaqaNames = names;
      });

      print("تم تحميل ${halaqaNames.length} حلقة في القاموس");
    } catch (e) {
      print("خطأ في تحميل أسماء الحلقات: $e");
    }
  }

  Future<void> _loadHalaqat(int halagaID) async {
    halaqat = await halagaController.getHalagaByHalagaID(halagaID);
  }

  Future<void> _loadStudent() async {
    setState(() {
      isLoading = true;
    });

    print("=== بداية تحميل بيانات الطلاب ===");
    int schoolID = widget.user!.schoolID!;
    print("معرف المدرسة: $schoolID");

    if (schoolID != null) {
      // Load halaqat names first
      // print("جاري تحميل أسماء الحلقات...");
      await _loadHalaqaNames(schoolID);
      bool isConnected = await InternetConnectionChecker.createInstance().hasConnection;
      print("حالة الاتصال: $isConnected");

      if (isConnected) {
          // جلب بيانات الطلاب من Firebase
          print("جاري جلب بيانات الطلاب من Firebase...");
          List<Map<String, dynamic>> studentsList =
              await firebasehelper.getStudentData(schoolID);
          print("تم جلب ${studentsList.length} طالب من Firebase");
          print("بيانات الطلاب من Firebase: $studentsList");

          for (var studentData in studentsList) {
            // تحويل البيانات إلى StudentModel
            print("جاري معالجة بيانات الطالب: $studentData");
            StudentModel student = StudentModel.fromJson(studentData);
            print(
                "تم تحويل البيانات إلى نموذج الطالب: ${student.firstName}, ID: ${student.studentID}, حلقة: ${student.elhalaqaID}");
            // التحقق إذا كان الطالب موجودًا في قاعدة البيانات المحلية
            if (student.studentID == null) {
              print("تخطي الطالب لأن studentID هو null");
              continue;
            }

            bool exists = await sqlDb.checkIfitemExists(
                "Students", student.studentID!, 'StudentID');
            print("هل الطالب موجود في قاعدة البيانات المحلية؟ $exists");

            if (exists) {
              // إذا كان موجودًا، يتم التحديث
              await studentController.updateStudent(student, student.studentID!, 0);
              print("تم تحديث بيانات الطالب ${student.firstName}");
            } else {
              // إذا لم يكن موجودًا، يتم إضافته
              await studentController.addStudentToLocal(student);
              print(" : تم إضافة بيانات الطالب ${student.firstName}");
            }
          }
        // تحميل البيانات من القاعدة المحلية
        print("جاري تحميل البيانات من قاعدة البيانات المحلية...");
        List<StudentModel>? loadedStudent =
            await studentController.getSchoolStudents(schoolID);
        print(
            "تم تحميل ${loadedStudent?.length ?? 0} طالب من قاعدة البيانات المحلية");

        setState(() {
          students = loadedStudent ?? [];
          isLoading = false;
          print("تم تحديث واجهة المستخدم بـ ${students.length} طالب");
        });

      } else {
        // إذا لم يكن هناك اتصال بالإنترنت، يتم تحميل البيانات من القاعدة المحلية فقط
        print(
            "لا يوجد اتصال بالإنترنت، جاري تحميل البيانات من قاعدة البيانات المحلية فقط...");
        List<StudentModel>? loadedStudent =
            await studentController.getSchoolStudents(schoolID);
        print(
            "تم تحميل ${loadedStudent?.length ?? 0} طالب من قاعدة البيانات المحلية");

        setState(() {
          students = loadedStudent ?? [];
          isLoading = false;
          print("تم تحديث واجهة المستخدم بـ ${students.length} طالب");
        });
      }
    } else {
      print("معرف المدرسة غير متوفر!");
      setState(() {
        isLoading = false;
      });
    }
    print("=== انتهاء تحميل بيانات الطلاب ===");
  }

  String getHalaqaName(int? halaqaId) {
    if (halaqaId == null) {
      print("الطالب بدون حلقة (معرف الحلقة: null)");
      return 'بدون حلقة';
    }

    String halaqaName = halaqaNames[halaqaId] ?? 'بدون حلقة';
    print(
        "معرف الحلقة: $halaqaId، اسم الحلقة: $halaqaName، القاموس يحتوي على: ${halaqaNames.keys.toList()}");

    return halaqaName;
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => _loadStudent(),
              icon: Icon(Icons.refresh, color: Colors.white))
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.teal))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'عدد الطلاب: ${students.length}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                Expanded(
                  child: students.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_off,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 10),
                              Text('لا يوجد طلاب',
                                  style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            final halaqaName =
                                getHalaqaName(student.elhalaqaID);

                            // Only load halaqat if there is a valid ID
                            if (student.elhalaqaID != null) {
                              _loadHalaqat(student.elhalaqaID!);
                            }

                            return Card(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
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
                                              ? "الحلقة: بدون حلقة"
                                              : "الحلقة: ${halaqat.firstWhere((h) => h.halagaID == student.elhalaqaID, orElse: () => HalagaModel(Name: 'غير معروف')).Name}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: student.elhalaqaID == null
                                                ? Colors.red
                                                : Colors.grey[800],
                                            fontWeight:
                                                student.elhalaqaID == null
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
                                      icon:
                                          Icon(Icons.edit, color: Colors.teal),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditStudentScreen(
                                                      student: student)),
                                        ).then((_) => _loadStudent());
                                      },
                                    ),
                                    IconButton(
                                      onPressed: () async {
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
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(true),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ) ??
                                            false;

                                        if (confirm) {
                                          try {
                                            await studentController
                                                .delete(student.studentID!);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'تم حذف الطالب بنجاح')),
                                            );
                                            await _loadStudent();
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'فشل في حذف الطالب')),
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
                                            student: student)),
                                  ).then((_) => _loadStudent());
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddStudentScreen(user: widget.user)),
          ).then((_) => _loadStudent());
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
