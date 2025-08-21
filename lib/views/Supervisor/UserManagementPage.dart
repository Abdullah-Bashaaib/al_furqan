import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/views/Supervisor/add_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/views/Supervisor/requests_list.dart';
import 'package:al_furqan/views/Supervisor/user_list.dart';
import 'package:al_furqan/utils/app_theme.dart';
import 'package:al_furqan/utils/constants.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with SingleTickerProviderStateMixin {
  String? _selectedRole;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SqlDb sqlDb = SqlDb();
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
    await userController.getData();
    setState(() {});
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'إدارة المستخدمين',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      actions: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 12),
          child: Tooltip(
            message: 'تحديث البيانات',
            child: IconButton(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
                size: 24,
              ),
              onPressed: _refreshData,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(48),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.outline,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(
                text: 'المستخدمين',
                icon: Icon(Icons.people_outline),
              ),
              Tab(
                text: 'الطلبات',
                icon: Icon(Icons.request_page_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AddUser()))
            .then((_) {
          _refreshData();
        });
      },
      tooltip: 'إضافة مستخدم جديد',
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 4,
      label: Row(
        children: [
          Icon(Icons.add, color: Colors.white),
          SizedBox(width: 8),
          Text('مستخدم جديد', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: UserList(),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: RequestsList(),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}
