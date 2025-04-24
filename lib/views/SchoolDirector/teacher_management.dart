import 'package:al_furqan/controllers/TeacherController.dart';
import 'package:al_furqan/views/SchoolDirector/teacher_list.dart';
import 'package:al_furqan/views/SchoolDirector/teacher_request.dart';
// import 'package:al_furqan/views/Supervisor/add_teacher.dart';
import 'package:al_furqan/views/Supervisor/requests_list.dart';
import 'package:al_furqan/views/Supervisor/user_list.dart';
import 'package:flutter/material.dart';

class TeacherManagement extends StatefulWidget {
  const TeacherManagement({super.key});

  @override
  State<TeacherManagement> createState() => _TeacherManagementState();
}

class _TeacherManagementState extends State<TeacherManagement>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshData() async {
    await teacherController.getTeachers();
    setState(() {});
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('إدارة المعلمين'),
      backgroundColor: Colors.green.withOpacity(0.5),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshData,
          tooltip: 'تحديث البيانات',
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'المعلمين'),
          Tab(text: 'الطلبات'),
        ],
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Navigator.of(context)
        //     .push(MaterialPageRoute(builder: (context) => const AddTeacher()))
        //     .then((_) {
        //   _refreshData();
        // });
      },
      tooltip: 'إضافة معلم جديد',
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TeacherList(),
          TeacherRequest(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}
