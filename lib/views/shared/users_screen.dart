import 'dart:developer';

import 'package:al_furqan/main.dart';
import 'package:al_furqan/models/provider/message_provider.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/shared/message_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UsersScreen extends StatefulWidget {
  final UserModel currentUser;
  // final List<UserModel> availableParents;
  // final List<UserModel> availableTeachers;

  const UsersScreen({
    super.key,
    required this.currentUser,
    // required this.availableParents,
    // required this.availableTeachers,
  });
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<UserModel> displayedUsers = [];
  int? roleID = perf.getInt('roleID');
  bool hasDialogShown = false;
  @override
  void initState() {
    super.initState();
    var prov = Provider.of<MessageProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasDialogShown && widget.currentUser.roleID == 1) {
        hasDialogShown = true;
        if (prov.teachers.isEmpty) {
          // عرض رسالة إذا القائمة فارغة
          showUserTypeDialog();
          showDialogNoUser(context, "معلمين");
        } else if (prov.parents.isEmpty) {
          // عرض رسالة إذا القائمة فارغة
          showUserTypeDialog();
          showDialogNoUser(context, "أولياء الأمور");
        } else {
          // عرض حوار اختيار نوع المستخدم
          showUserTypeDialog();
        }
      }
      if (widget.currentUser.roleID != 1) {
        showUserTypeDialog();
        // displayedUsers = prov.parents
        //     .where((user) => user.user_id != null && user.user_id != 0)
        //     .toList();
      }
    });
  }

  void showUserTypeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('اختيار نوع المحادثة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              roleID == 2
                  ? Container()
                  : Selector<MessageProvider, List<UserModel>>(
                      selector: (context, S) => S.teachersList,
                      builder: (context, prov, child) => ListTile(
                            title: Text('مراسلة معلم',
                                style: TextStyle(color: Colors.grey.shade700)),
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                displayedUsers = prov
                                    .where((user) =>
                                        user.user_id != null &&
                                        user.user_id != 0)
                                    .toList();
                              });
                            },
                          )),
              Selector<MessageProvider, List<UserModel>>(
                  builder: (context, prov, child) => ListTile(
                        title: Text('مراسلة ولي أمر',
                            style: TextStyle(color: Colors.grey.shade700)),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            displayedUsers = prov
                                .where((user) =>
                                    user.user_id != null && user.user_id != 0)
                                .toList();
                          });
                        },
                      ),
                  selector: (_, S) => S.parentsList),
              roleID == 2
                  ? Selector<MessageProvider, UserModel?>(
                      builder: (context, prov, child) => ListTile(
                            title: Text('مراسلة المدير ',
                                style: TextStyle(color: Colors.grey.shade700)),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    currentUser: widget.currentUser,
                                    selectedUser: prov,
                                  ),
                                ),
                              );
                            },
                          ),
                      selector: (_, S) => S.manager)
                  : Container()
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء',
                  style: TextStyle(color: Theme.of(context).primaryColor)),
            ),
          ],
        );
      },
    );
  }

  void showDialogNoUser(BuildContext context, String userType) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تنبيه'),
        content: Text('لا يوجد $userType متاحين حالياً.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً'),
          ),
        ],
      ),
    );
  }

  // دالة للبحث في المستخدمين
  List<UserModel> _filterUsers(String query) {
    if (query.isEmpty) return displayedUsers;

    return displayedUsers.where((user) {
      final name = user.first_name?.toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.currentUser.roleID == 1 && displayedUsers.isEmpty) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     showUserTypeDialog();
    //   });
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text('اختيار مستخدم',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: widget.currentUser.roleID == 1
            ? [
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: showUserTypeDialog,
                  tooltip: 'تصفية المستخدمين',
                ),
              ]
            : [],
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'البحث عن مستخدم...',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              onChanged: (value) {
                setState(() {
                  displayedUsers = _filterUsers(value);
                });
              },
            ),
          ),

          // عنوان القسم
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.currentUser.roleID == 1
                      ? (displayedUsers.isNotEmpty &&
                              displayedUsers[0].roleID == 2
                          ? 'قائمة المعلمين'
                          : 'قائمة أولياء الأمور')
                      : 'قائمة المستخدمين',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  '${displayedUsers.length} مستخدم',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          // قائمة المستخدمين
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {}); // إعادة بناء الصفحة
              },
              child: displayedUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off,
                              size: 64, color: Colors.grey.shade400),
                          SizedBox(height: 16),
                          Text(
                            widget.currentUser.roleID == 1
                                ? 'اختر نوع المستخدم أو أضف مستخدمين'
                                : 'لا يوجد مستخدمين متاحين',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey.shade700),
                            textAlign: TextAlign.center,
                          ),
                          if (widget.currentUser.roleID == 1)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: ElevatedButton(
                                onPressed: showUserTypeDialog,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text('اختيار نوع المستخدم'),
                              ),
                            ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: displayedUsers.length,
                      separatorBuilder: (context, index) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = displayedUsers[index];
                        return InkWell(
                          onTap: () {
                            log('اختيار مستخدم: ${user.first_name!} ${user.last_name!} , user_id: ${user.user_id}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  currentUser: widget.currentUser,
                                  selectedUser: user,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            child: Row(
                              children: [
                                // صورة المستخدم
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: user.roleID == 2
                                      ? Colors.blue.shade100
                                      : Colors.green.shade100,
                                  child: Text(
                                    user.first_name?[0] ?? '?',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: user.roleID == 2
                                          ? Colors.blue.shade700
                                          : Colors.green.shade700,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                // معلومات المستخدم
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${user.first_name} ${user.middle_name} ${user.grandfather_name} ${user.last_name}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: user.roleID == 2
                                                  ? Colors.blue.shade50
                                                  : Colors.green.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              user.roleID == 2
                                                  ? 'معلم'
                                                  : 'ولي أمر',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: user.roleID == 2
                                                    ? Colors.blue.shade700
                                                    : Colors.green.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // زر المحادثة
                                IconButton(
                                  icon: Icon(Icons.chat_outlined,
                                      color: Colors.blue.shade700),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                          currentUser: widget.currentUser,
                                          selectedUser: user,
                                        ),
                                      ),
                                    );
                                  },
                                  tooltip: 'بدء محادثة',
                                ),
                              ],
                            ),
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
}
