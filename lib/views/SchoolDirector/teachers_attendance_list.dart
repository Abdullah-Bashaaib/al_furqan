import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TeachersAttendanceListScreen extends StatefulWidget {
  final String schoolId;

  const TeachersAttendanceListScreen({super.key, required this.schoolId});

  @override
  State<TeachersAttendanceListScreen> createState() =>
      _TeachersAttendanceListScreenState();
}

class _TeachersAttendanceListScreenState
    extends State<TeachersAttendanceListScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _teachersList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeachersAttendance();
  }

  // تحميل بيانات حضور المعلمين حسب التاريخ المحدد
  Future<void> _loadTeachersAttendance() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // تنسيق التاريخ بالشكل المطلوب (yyyy-MM-dd)
      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // الاستعلام عن بيانات الحضور من Firestore
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(formattedDate)
          .collection('teachers')
          .where('schoolId', isEqualTo: int.tryParse(widget.schoolId))
          .get();

      // تحويل البيانات إلى قائمة
      List<Map<String, dynamic>> teachers = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // إضافة معرف الوثيقة
        teachers.add(data);
      }

      // ترتيب المعلمين حسب الوقت
      teachers.sort((a, b) {
        Timestamp? timestampA = a['timestamp'] as Timestamp?;
        Timestamp? timestampB = b['timestamp'] as Timestamp?;
        if (timestampA == null || timestampB == null) return 0;
        return timestampA.compareTo(timestampB);
      });
      if (!mounted) return;
      setState(() {
        _teachersList = teachers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحميل بيانات الحضور: $e')),
      );
    }
  }

  // تغيير التاريخ المحدد
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadTeachersAttendance();
    }
  }

  // تنسيق وقت الحضور
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'غير معروف';

    DateTime dateTime = timestamp.toDate();
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    // تنسيق التاريخ للعرض
    String formattedDate = DateFormat('yyyy/MM/dd').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('حضور المعلمين',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // شريط اختيار التاريخ
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    color: Theme.of(context).primaryColor),
                SizedBox(width: 12),
                Text(
                  'التاريخ: $formattedDate',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: Icon(Icons.date_range),
                  label: Text('تغيير التاريخ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // عنوان القائمة
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المعلمين الحاضرين: ${_teachersList.length}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _loadTeachersAttendance,
                  tooltip: 'تحديث',
                ),
              ],
            ),
          ),

          // قائمة المعلمين
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _teachersList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'لا يوجد معلمين حاضرين في هذا اليوم',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.all(8),
                        itemCount: _teachersList.length,
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (context, index) {
                          final teacher = _teachersList[index];
                          final isLate = teacher['status'] == 'متأخر';

                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isLate
                                    ? Colors.orange.shade300
                                    : Colors.green.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: isLate
                                    ? Colors.orange.shade100
                                    : Colors.green.shade100,
                                child: Icon(
                                  Icons.person,
                                  color: isLate
                                      ? Colors.orange.shade800
                                      : Colors.green.shade800,
                                ),
                              ),
                              title: Text(
                                teacher['name'] ?? 'غير معروف',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'وقت الحضور: ${_formatTimestamp(teacher['timestamp'])}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isLate
                                      ? Colors.orange.shade100
                                      : Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  teacher['status'] ?? 'غير معروف',
                                  style: TextStyle(
                                    color: isLate
                                        ? Colors.orange.shade800
                                        : Colors.green.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
}
