import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:flutter/material.dart';

class AddStudentsToHalqaScreen extends StatefulWidget {
  final String? halqaID;
  final int? schoolID;
  const AddStudentsToHalqaScreen({
    super.key,
    required this.halqaID,
    required this.schoolID,
  });

  @override
  _AddStudentsToHalqaScreenState createState() =>
      _AddStudentsToHalqaScreenState();
}

class _AddStudentsToHalqaScreenState extends State<AddStudentsToHalqaScreen> {
  List<StudentModel> availableStudents = [];
  List<String> selectedStudentIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableStudents();
  }

  Future<void> _loadAvailableStudents() async {
    if (widget.schoolID == null) {
      debugPrint("schoolID is null");
      if (mounted) {
        setState(() {
          availableStudents = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ: معرف المدرسة غير متوفر')),
        );
      }
      return;
    }

    try {
      if (mounted) setState(() => _isLoading = true);
      final students =
          await studentController.getSchoolStudents(widget.schoolID!);
      final available = students
          .where((student) =>
              student.elhalaqaID == null ||
              student.elhalaqaID != widget.halqaID)
          .toList();
      if (mounted) {
        setState(() {
          availableStudents = available;
          _isLoading = false;
          debugPrint("Available students: ${availableStudents.length}");
        });
      }
    } catch (e) {
      debugPrint("Error loading available students: $e");
      if (mounted) {
        setState(() {
          availableStudents = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في جلب الطلاب: $e')),
        );
      }
    }
  }

  Future<void> _addSelectedStudents() async {
    if (selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار طالب واحد على الأقل')),
      );
      return;
    }

    try {
      if (mounted) setState(() => _isLoading = true);
      for (final studentId in selectedStudentIds) {
        await studentController.assignStudentToHalqa(
            studentId, widget.halqaID!);
      }
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت إضافة الطلاب بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error adding students to halqa: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في إضافة الطلاب: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة طلاب إلى الحلقة'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : availableStudents.isEmpty
              ? const Center(
                  child: Text(
                    'لا يوجد طلاب متاحين',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: availableStudents.length,
                        itemBuilder: (context, index) {
                          final student = availableStudents[index];
                          final isSelected =
                              selectedStudentIds.contains(student.studentID);
                          return CheckboxListTile(
                            title: Text(
                              '${student.firstName ?? ''} ${student.middleName ?? ''} ${student.grandfatherName ?? ''} ${student.lastName ?? ''}'
                                  .trim(),
                              style: const TextStyle(fontSize: 16),
                            ),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedStudentIds.add(student.studentID!);
                                } else {
                                  selectedStudentIds.remove(student.studentID);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _addSelectedStudents,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'إضافة الطلاب المحددين',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
