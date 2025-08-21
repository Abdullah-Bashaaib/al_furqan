import 'package:al_furqan/controllers/TeacherController.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/models/provider/user_provider.dart';
import 'package:al_furqan/views/SchoolDirector/add_teacher.dart';
import 'package:al_furqan/views/SchoolDirector/teacher_list.dart';
import 'package:al_furqan/views/SchoolDirector/teacher_request.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherManagement extends StatefulWidget {
  const TeacherManagement({super.key});

  @override
  State<TeacherManagement> createState() => _TeacherManagementState();
}

class _TeacherManagementState extends State<TeacherManagement>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isVisible = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _refreshData();
    });
    _tabController = TabController(length: 2, vsync: this);
    // _refreshData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    debugPrint("TeacherManagement refreshing data...");
    try {
      (context).read<UserProvider>().loadTeachers();
      // await teacherController.getTeachers();
      // debugPrint(
      //     "TeacherManagement: Teachers fetched - count: ${teacherController.teachers.length}");
    } catch (e) {
      debugPrint("TeacherManagement: Error fetching teachers - $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
      debugPrint("TeacherManagement: Loading state set to false");
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'إدارة المعلمين',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 1, 117, 70),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshData,
          tooltip: 'تحديث البيانات',
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(
            text: 'المعلمين',
            icon: Icon(Icons.people),
          ),
          Tab(
            text: 'الطلبات',
            icon: Icon(Icons.assignment),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: FloatingActionButton.extended(
        onPressed: _isVisible
            ? () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => AddTeacher()))
                    .then((result) {
                  if (result == true) {
                    // Show a success message if the add operation was successful
                    if (mounted) {
                      debugPrint(
                          "TeacherManagement: Teacher added successfully");
                    } else {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("تم إضافة المعلم بنجاح وتحديث القائمة"),
                        backgroundColor: Color.fromARGB(255, 1, 117, 70),
                      ),
                    );
                  }
                  // Refresh data regardless of result
                  _refreshData();
                });
              }
            : null,
        tooltip: 'إضافة معلم جديد',
        icon: const Icon(Icons.add),
        label: const Text('إضافة معلم'),
        backgroundColor: const Color.fromARGB(255, 1, 117, 70),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color.fromARGB(255, 1, 117, 70),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'جاري تحميل البيانات...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo is ScrollUpdateNotification) {
                  // If scroll direction is downward, hide FAB
                  if (scrollInfo.dragDetails != null &&
                      scrollInfo.dragDetails!.primaryDelta != null &&
                      scrollInfo.dragDetails!.primaryDelta! < 0) {
                    if (_isVisible) {
                      setState(() {
                        _isVisible = false;
                      });
                    }
                  }
                  // If scroll direction is upward, show FAB
                  else if (scrollInfo.dragDetails != null &&
                      scrollInfo.dragDetails!.primaryDelta != null &&
                      scrollInfo.dragDetails!.primaryDelta! > 0) {
                    if (!_isVisible) {
                      setState(() {
                        _isVisible = true;
                      });
                    }
                  }
                }
                return false;
              },
              child: TabBarView(
                controller: _tabController,
                children: const [
                  TeacherList(),
                  TeacherRequest(),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}
