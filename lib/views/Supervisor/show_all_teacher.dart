import 'package:al_furqan/controllers/TeacherController.dart';
import 'package:al_furqan/controllers/school_controller.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/schools_model.dart';

class ShowAllTeacher extends StatefulWidget {
  const ShowAllTeacher({super.key});

  @override
  State<ShowAllTeacher> createState() => _ShowAllTeacherState();
}

class _ShowAllTeacherState extends State<ShowAllTeacher> {
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // Function to fetch teachers and schools data
  void _refreshData() async {
    setState(() => _isLoading = true);
    try {
      await teacherController.getTeachers();
      await schoolController.getData();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب البيانات: $e')),
      );
    }
  }

  // Filter teachers based on search query
  List<UserModel> _filterTeachers() {
    if (_searchQuery.isEmpty) return teacherController.teachers;
    return teacherController.teachers.where((teacher) {
      final fullName =
          '${teacher.first_name ?? ''} ${teacher.middle_name ?? ''} ${teacher.last_name ?? ''}'
              .toLowerCase();
      return fullName.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Find school name by schoolID
  // String _getSchoolName(int? schoolID) {
  //   print(schoolID);
  //   if (schoolID == null) return 'غير معروف';
  //   final school = schoolController.schools.firstWhere(
  //     (school) => school.schoolID == schoolID,
  //     orElse: () => SchoolModel(schoolID: -1, school_name: 'غير معروف'),
  //   );
  //   return school.school_name ?? 'غير معروف';
  // }

  @override
  Widget build(BuildContext context) {
    final filteredTeachers = _filterTeachers();
      List<SchoolModel> schools = schoolController.schools;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "المعلمين",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'تحديث البيانات',
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              keyboardType: TextInputType.name,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'بحث عن معلم...',
                prefixIcon:
                    Icon(Icons.search, color: Theme.of(context).primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                ? Center(
                    child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ))
                : filteredTeachers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'لا يوجد معلمين',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredTeachers.length,
                        itemBuilder: (context, index) {
                          final teacher = filteredTeachers[index];
                          final school = schools.firstWhere(
                            (element) => element.schoolID == teacher.schoolID,
                          );
                          // _getSchoolName(teacher.schoolID);

                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                child: Text(
                                  '${teacher.first_name?[0] ?? ''}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                '${teacher.first_name ?? ''} ${teacher.middle_name ?? ''} ${teacher.last_name ?? ''}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.school,
                                          size: 16, color: Colors.grey),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          school.school_name!,
                                          style: TextStyle(
                                              color: Colors.grey[700]),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.grey),
                              onTap: () {
                                // Handle teacher selection
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('تم اختيار ${teacher.first_name}'),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        tooltip: 'تحديث البيانات',
        child: Icon(Icons.refresh),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
