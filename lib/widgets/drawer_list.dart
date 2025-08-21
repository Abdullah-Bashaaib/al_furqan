// ignore: file_names

import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/Supervisor/school_reports.dart';
import 'package:al_furqan/views/Supervisor/show_all_schools.dart';
import 'package:al_furqan/views/Supervisor/show_all_teacher.dart';
import 'package:al_furqan/views/checkDBlocal/database_viewer_entry.dart';
import 'package:al_furqan/views/supervisor/verification_requests_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/views/Supervisor/UserManagementPage.dart';

class DrawerList extends StatelessWidget {
  UserModel? user;
  DrawerList({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  maxRadius: 40,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  child: Center(
                    child: Text(
                      user!.first_name!.substring(0, 1),
                      style: TextStyle(
                        fontSize: 45,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${user!.first_name} ${user!.middle_name} ${user!.last_name}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _createDrawerItem(
            context,
            icon: Icons.home,
            text: 'الصفحة الرئيسية',
            onTap: () {
              // Navigate to home page
              Navigator.of(context).pop();
            },
          ),
          _createDrawerItem(
            context,
            icon: Icons.school,
            text: 'المدارس',
            onTap: () {
              Navigator.of(context).pop();
              // Navigate to schools page
              Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) => ShowAllSchools()));
            },
          ),
          _createDrawerItem(
            context,
            icon: Icons.bar_chart,
            text: 'تقارير المدارس',
            onTap: () {
              Navigator.of(context).pop();
              // Navigate to schools page
              Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) => SchoolReports()));
            },
          ),
          _createDrawerItem(
            context,
            icon: Icons.person,
            text: 'المعلمين',
            onTap: () {
              Navigator.of(context).pop();
              // Navigate to teachers page
              Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) => ShowAllTeacher()));
            },
          ),
          _createDrawerItem(
            context,
            icon: Icons.group,
            text: 'المستخدمين',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => UserManagementPage()),
              );
            },
          ),
          _createDrawerItem(
            context,
            icon: Icons.notifications,
            text: 'طلبات التحقق',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => VerificationRequestsScreen()),
              );
            },
          ),
          // إضافة رابط لصفحة فحص قاعدة البيانات
          _createDrawerItem(
            context,
            icon: Icons.storage,
            text: 'فحص قاعدة البيانات',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => DatabaseViewerEntry()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _createDrawerItem(BuildContext context,
      {required IconData icon,
      required String text,
      GestureTapCallback? onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: 24,
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      selected: false,
      hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      visualDensity: VisualDensity.compact,
    );
  }
}
