import 'package:al_furqan/helper/current_user.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/helper/user_helper.dart';

class StudentsAttendance extends StatefulWidget {
  const StudentsAttendance({Key? key}) : super(key: key);

  @override
  State<StudentsAttendance> createState() => _StudentsAttendanceState();
}

class _StudentsAttendanceState extends State<StudentsAttendance>
// with UserDataMixin
{
  final StudentController _studentController = StudentController();
  UserModel? user = CurrentUser.user;
  List<StudentModel> _students = [];
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();

  // خريطة لتتبع حالة الحضور لكل طالب
  // المفتاح: معرف الطالب، القيمة: true (حاضر) أو false (غائب)
  Map<String?, bool> _attendanceStatus = {};

  // خريطة لتخزين أسباب الغياب
  Map<String?, String> _absenceReasons = {};

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // if (user == null || user!.elhalagatID == null) {
      //   await fetchUserData();
      //   if (user == null || user!.elhalagatID == null) {
      //     setState(() {
      //       _errorMessage = "لم يتم العثور على بيانات المستخدم أو الحلقة";
      //       _isLoading = false;
      //     });
      //     return;
      //   }
      // }

      // تحميل الطلاب من حلقة المعلم
      final students = await _studentController.getStudents(user!.elhalagatID!);

      // تعيين جميع الطلاب كحاضرين افتراضياً
      for (var student in students) {
        _attendanceStatus[student.studentID] = true;
      }

      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "حدث خطأ أثناء تحميل بيانات الطلاب: $e";
        _isLoading = false;
      });
    }
  }

  // دالة لتغيير التاريخ المحدد
  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // هنا عادة ما تقوم بتحميل بيانات الحضور للتاريخ المحدد
        // حالياً، سنقوم فقط بإعادة تعيين جميع الطلاب كحاضرين
        for (var student in _students) {
          _attendanceStatus[student.studentID] = true;
        }
      });
    }
  }

  // دالة لحفظ بيانات الحضور
  void _saveAttendance() async {
    // عرض مؤشر التقدم أثناء الحفظ
    showDialog(
      context: context,
      barrierDismissible: false, // منع إغلاق الحوار بالنقر خارجه
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('جاري حفظ بيانات الحضور...'),
            ],
          ),
        );
      },
    );

    debugPrint("------> جاري حفظ بيانات الحضور");

    try {
      // هنا يمكنك تنفيذ المنطق اللازم لحفظ بيانات الحضور
      // على سبيل المثال، قد تقوم باستدعاء طريقة في وحدة التحكم للحفظ في قاعدة البيانات
      for (var student in _students) {
        debugPrint("الطالب: ${student.studentID}");
        if (_attendanceStatus[student.studentID] == false) {
          debugPrint("تحديث بيانات الطالب - غائب");
          await _studentController.updateAttendance(
              student.studentID!,
              _attendanceStatus[student.studentID]!,
              _absenceReasons[student.studentID] ?? "بدون سبب");
        } else {
          debugPrint("تحديث بيانات الطالب - حاضر");
          await _studentController.updateAttendance(
              student.studentID!, _attendanceStatus[student.studentID]!, "-");
        }
      }

      // إغلاق مؤشر التقدم
      Navigator.of(context).pop();

      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ بيانات الحضور بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // إغلاق مؤشر التقدم
      Navigator.of(context).pop();

      // عرض رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء حفظ بيانات الحضور: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  // دالة لعرض مربع حوار سبب الغياب
  void _showAbsenceReasonDialog(StudentModel student) {
    final TextEditingController reasonController = TextEditingController();
    reasonController.text = _absenceReasons[student.studentID] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('سبب الغياب'),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(
            hintText: 'أدخل سبب الغياب',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _absenceReasons[student.studentID] = reasonController.text;
              });
              Navigator.pop(context);
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تحضير الطلاب'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: 'اختر تاريخ',
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveAttendance,
            tooltip: 'حفظ التحضير',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child:
                      Text(_errorMessage!, style: TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    // عرض التاريخ
                    Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.grey.shade100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'تاريخ التحضير:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('yyyy-MM-dd').format(_selectedDate),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    // الإحصائيات
                    Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.grey.shade200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            'إجمالي الطلاب',
                            _students.length.toString(),
                            Colors.blue,
                          ),
                          _buildStatCard(
                            'الحضور',
                            _attendanceStatus.values
                                .where((v) => v)
                                .length
                                .toString(),
                            Colors.green,
                          ),
                          _buildStatCard(
                            'الغياب',
                            _attendanceStatus.values
                                .where((v) => !v)
                                .length
                                .toString(),
                            Colors.red,
                          ),
                        ],
                      ),
                    ),
                    // قائمة الطلاب
                    Expanded(
                      child: _students.isEmpty
                          ? Center(child: Text('لا يوجد طلاب في هذه الحلقة'))
                          : ListView.builder(
                              itemCount: _students.length,
                              itemBuilder: (context, index) {
                                final student = _students[index];
                                final isPresent =
                                    _attendanceStatus[student.studentID] ??
                                        true;

                                return Card(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  elevation: 2,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          isPresent ? Colors.green : Colors.red,
                                      child: Icon(
                                        isPresent ? Icons.check : Icons.close,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      '${student.firstName ?? ''} ${student.middleName ?? ''} ${student.lastName ?? ''}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: !isPresent &&
                                            _absenceReasons[student.studentID]
                                                    ?.isNotEmpty ==
                                                true
                                        ? Text(
                                            'سبب الغياب: ${_absenceReasons[student.studentID]}',
                                            style: TextStyle(
                                                color: Colors.red.shade700),
                                          )
                                        : null,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // زر سبب الغياب
                                        if (!isPresent)
                                          IconButton(
                                            icon: Icon(Icons.edit_note,
                                                color: Colors.orange),
                                            onPressed: () =>
                                                _showAbsenceReasonDialog(
                                                    student),
                                            tooltip: 'سبب الغياب',
                                          ),
                                        // مفتاح تبديل الحضور
                                        Switch(
                                          value: isPresent,
                                          activeColor: Colors.green,
                                          inactiveTrackColor:
                                              Colors.red.shade200,
                                          inactiveThumbColor: Colors.red,
                                          onChanged: (value) {
                                            setState(() {
                                              _attendanceStatus[
                                                  student.studentID] = value;
                                              // إذا تم تحديد الطالب كحاضر، قم بمسح سبب الغياب
                                              if (value) {
                                                _absenceReasons
                                                    .remove(student.studentID);
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
