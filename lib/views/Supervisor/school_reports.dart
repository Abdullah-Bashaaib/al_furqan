import 'package:al_furqan/controllers/school_controller.dart';
import 'package:al_furqan/models/schools_model.dart';
import 'package:al_furqan/utils/utils.dart';
import 'package:al_furqan/views/Supervisor/report.dart';
import 'package:flutter/material.dart';

import '../../controllers/StudentController.dart';
import '../../controllers/TeacherController.dart';

class SchoolReports extends StatefulWidget {
  const SchoolReports({super.key});

  @override
  State<SchoolReports> createState() => _SchoolReports();
}

class _SchoolReports extends State<SchoolReports> {
  String _searchQuery = '';
  bool _isLoading = false;
  int numberStudent = 0;
  int numberTeacher = 0;

  Future<void> schoolData(int schoolID) async {
    Utils.showDialogLoading(context: context);
    List numberStudentOfSchool =
        await studentController.getSchoolStudents(schoolID);
    await teacherController.getTeachersBySchoolID(schoolID);
    List teacher = teacherController.teachers;
    setState(() {
      numberStudent = numberStudentOfSchool.length;
      numberTeacher = teacher.length;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  List<SchoolModel> _filterSchools() {
    if (_searchQuery.isEmpty) return schoolController.schools;
    return schoolController.schools.where((school) {
      final fullName = (school.school_name ?? '').toLowerCase();
      return fullName.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Function to fetch teachers and schools data
  void _refreshData() async {
    setState(() => _isLoading = true);
    try {
      await schoolController.getData();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب البيانات: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final filteredSchools = _filterSchools();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المدارس',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 2,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'تحديث',
            onPressed: () {
              _refreshData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم تحديث البيانات'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              keyboardType: TextInputType.name,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                labelText: 'بحث عن مدرسة',
                hintText: 'اكتب اسم المدرسة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : filteredSchools.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await Future.delayed(
                              const Duration(milliseconds: 300));
                          _refreshData();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredSchools.length,
                          itemBuilder: (context, index) {
                            final school = filteredSchools[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                  onTap: () async {
                                    await schoolData(school.schoolID!);
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SchoolReportPage(
                                          schoolModel: school,
                                          numberS: numberStudent,
                                          numberT: numberTeacher,
                                        ),
                                      ),
                                    );
                                  },
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        primaryColor.withOpacity(0.2),
                                    child:
                                        Icon(Icons.school, color: primaryColor),
                                  ),
                                  title: Text(
                                    school.school_name!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              school.school_location ??
                                                  'لا يوجد موقع',
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                      onPressed: () async {
                                        await schoolData(school.schoolID!);
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SchoolReportPage(
                                              schoolModel: school,
                                              numberS: numberStudent,
                                              numberT: numberTeacher,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.picture_as_pdf))
                                  // Column(
                                  //   children: [
                                  //     Text(
                                  //       "التقارير الجاهزة: 0",
                                  //       style: TextStyle(color: Colors.green),
                                  //     ),
                                  //     SizedBox(
                                  //       height: 10,
                                  //     ),
                                  //     Text(
                                  //       "التقارير الغير جاهزة: 0",
                                  //       style: TextStyle(color: Colors.red),
                                  //     )
                                  //   ],
                                  // ),
                                  ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // Widget to display when no schools are found
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد مدارس حالياً',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'لم يتم العثور على أي مدرسة'
                : 'لم يتم العثور على نتائج لـ "$_searchQuery"',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('تحديث'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build detail items in the dialog
  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
