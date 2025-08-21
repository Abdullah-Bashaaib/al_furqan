import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:al_furqan/models/student_model.dart';

class AttendanceScreen extends StatefulWidget {
  final int? halagaId;
  
  const AttendanceScreen({Key? key, this.halagaId}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // حالة الحضور لكل طالب
  Map<int, bool> _attendanceStatus = {};
  Map<int, String> _absenceReasons = {};
  
  // تاريخ اليوم للحضور
  DateTime _selectedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    // تهيئة حالة الحضور الافتراضية
    
  }
  
  // تغيير حالة حضور طالب
  void _toggleAttendance(int studentId, bool isPresent) {
    setState(() {
      _attendanceStatus[studentId] = isPresent;
      
      // إذا كان الطالب غائب، نطلب سبب الغياب
      if (!isPresent && _absenceReasons[studentId]?.isEmpty == true) {
        _showAbsenceReasonDialog(studentId);
      }
    });
  }
  
  // عرض مربع حوار لإدخال سبب الغياب
  void _showAbsenceReasonDialog(int studentId) {
    TextEditingController reasonController = TextEditingController(
      text: _absenceReasons[studentId] ?? ''
    );
    
    // البحث عن الطالب
    // StudentModel? student = StudentModel();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('سبب غياب Student $studentId'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'أدخل سبب الغياب',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // إذا لم يتم إدخال سبب، نعتبر الطالب حاضرًا مرة أخرى
              if (reasonController.text.trim().isEmpty) {
                setState(() {
                  _attendanceStatus[studentId] = true;
                });
              }
              Navigator.pop(context);
            },
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _absenceReasons[studentId] = reasonController.text;
              });
              Navigator.pop(context);
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }
  
  // تغيير التاريخ المحدد
  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('سجل حضور الطلاب'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حفظ بيانات الحضور بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            tooltip: 'حفظ بيانات الحضور',
          ),
        ],
      ),
      body: Column(
        children: [
          // معلومات الحلقة والتاريخ
          _buildHeaderSection(),
          
          // ملخص الحضور
          _buildAttendanceSummary(),
          
          // قائمة الطلاب
          Expanded(
            child: _buildStudentsList(),
          ),
          
          // زر تحديد الكل
          _buildBatchActions(),
        ],
      ),
    );
  }
  
  // بناء قسم الرأس مع معلومات الحلقة والتاريخ
  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          // اسم الحلقة
          Text(
            'حلقة: الفرقان',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          
          // اختيار التاريخ
          InkWell(
            onTap: _selectDate,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  'تاريخ الحضور: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // بناء ملخص الحضور
  Widget _buildAttendanceSummary() {
    // حساب الإحصائيات
    int totalStudents = 5;
    int presentCount = 3;
    int absentCount = totalStudents - presentCount;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('إجمالي الطلاب', totalStudents.toString(), Colors.blue),
          _buildSummaryItem('الحضور', presentCount.toString(), Colors.green),
          _buildSummaryItem('الغياب', absentCount.toString(), Colors.red),
        ],
      ),
    );
  }
  
  // بناء عنصر ملخص
  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 4),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ),
      ],
    );
  }
  
  // بناء قائمة الطلاب
  Widget _buildStudentsList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        int studentId = index;
        bool isPresent = _attendanceStatus[studentId] ?? true;
        
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPresent ? Colors.green.shade100 : Colors.red.shade100,
              child: Text(
                'A',
                style: TextStyle(
                  color: isPresent ? Colors.green.shade800 : Colors.red.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              'Student $index',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: !isPresent && _absenceReasons[studentId]?.isNotEmpty == true
                ? Text(
                    'سبب الغياب: ${_absenceReasons[studentId]}',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // زر تعديل سبب الغياب
                if (!isPresent)
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _showAbsenceReasonDialog(studentId),
                    tooltip: 'تعديل سبب الغياب',
                  ),
                
                // مربع اختيار الحضور
                Checkbox(
                  value: isPresent,
                  activeColor: Colors.green,
                  onChanged: (value) => _toggleAttendance(studentId, value ?? true),
                ),
              ],
            ),
            onTap: () => _toggleAttendance(studentId, !isPresent),
          ),
        );
      },
    );
  }
  
  // بناء أزرار الإجراءات الجماعية
  Widget _buildBatchActions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زر تحديد الكل كحاضر
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                
              },
              icon: Icon(Icons.check_circle),
              label: Text('تحديد الكل كحاضر'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          // زر تحديد الكل كغائب
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                
              },
              icon: Icon(Icons.cancel),
              label: Text('تحديد الكل كغائب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}