import 'package:al_furqan/models/provider/user_provider.dart';
import 'package:al_furqan/utils/utils.dart';
import 'package:al_furqan/views/SchoolDirector/add_teacher.dart';
import 'package:al_furqan/views/SchoolDirector/teacher_list.dart';
import 'package:al_furqan/views/SchoolDirector/teacher_request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      _refreshData();
    });
  }

  void _refreshData() async {
    setState(() => _isLoading = true);
    try {
      await (context).read<UserProvider>().loadTeachers();
    } catch (e) {
      debugPrint("Error fetching teachers: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context)
                .push(CupertinoPageRoute(builder: (context) => AddTeacher()))
                .then((result) {
              if (result == true) {
                Utils.showToast("تم إضافة المعلم بنجاح وتحديث القائمة",
                    backgroundColor: Colors.green);

                _refreshData();
              }
            });
          },
          tooltip: 'إضافة معلم جديد',
          icon: const Icon(Icons.add),
          label: const Text('إضافة معلم'),
          backgroundColor: const Color.fromARGB(255, 1, 117, 70),
          foregroundColor: Colors.white,
        ),
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                        color: Color.fromARGB(255, 1, 117, 70)),
                    SizedBox(height: 16),
                    Text(
                      'جاري تحميل البيانات...',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            : NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    title: const Text(
                      'إدارة المعلمين',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    floating: true,
                    pinned: true,
                    snap: false,
                    backgroundColor: const Color.fromARGB(255, 1, 117, 70),
                    foregroundColor: Colors.white,
                    elevation: innerBoxIsScrolled ? 4 : 0,
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
                        Tab(text: 'المعلمين', icon: Icon(Icons.people)),
                        Tab(text: 'الطلبات', icon: Icon(Icons.assignment)),
                      ],
                    ),
                  ),
                ],
                body: NotificationListener<UserScrollNotification>(
                  onNotification: (notification) {
                    if (notification.direction == ScrollDirection.reverse &&
                        _isVisible) {
                      setState(() => _isVisible = false);
                    } else if (notification.direction ==
                            ScrollDirection.forward &&
                        !_isVisible) {
                      setState(() => _isVisible = true);
                    }
                    return true;
                  },
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      TeacherList(),
                      TeacherRequest(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
