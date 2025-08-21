// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:al_furqan/controllers/message_controller.dart';
import 'package:al_furqan/main.dart';
import 'package:al_furqan/models/messages_model.dart';
import 'package:al_furqan/models/provider/message_provider.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/shared/message_screen.dart';
import 'package:al_furqan/views/shared/users_screen.dart';

import '../../helper/current_user.dart';

class ConversationsScreen extends StatefulWidget {
  final UserModel currentUser;

  const ConversationsScreen({
    super.key,
    required this.currentUser,
  });

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  // List<UserModel> conversationUsers = [];

  @override
  void initState() {
    super.initState();
    // loadConversations();
    int? r = perf.getInt('roleID');
    print("====================== $r");
    Future.microtask(() async {
      var prov = Provider.of<MessageProvider>(context, listen: false);
      await prov.loadMessageFromFirebase();
    });
  }

  // Future<void> loadConversations() async {
  //   await messageService.loadMessagesFromFirestore(widget.currentUser.user_id!);
  //   List<Message> messages = await messageController.getMessages();
  //   List<String> userIds = [];
  //   for (var message in messages) {
  //     if (message.senderId == widget.currentUser.user_id) {
  //       if (!userIds.contains(message.receiverId)) {
  //         userIds.add(message.receiverId!);
  //       }
  //     } else if (message.receiverId == widget.currentUser.user_id) {
  //       if (!userIds.contains(message.senderId)) {
  //         userIds.add(message.senderId!);
  //       }
  //     }
  //   }
  //
  //   List<UserModel> users = [];
  //   for (String userId in userIds) {
  //     UserModel? user;
  //     for (var parent in widget.availableParents) {
  //       if (parent.user_id == userId) {
  //         user = parent;
  //         break;
  //       }
  //     }
  //     if (user == null) {
  //       for (var teacher in widget.availableTeachers) {
  //         if (teacher.user_id == userId) {
  //           user = teacher;
  //           break;
  //         }
  //       }
  //     }
  //
  //     if (user == null) {
  //       try {
  //         var doc = await FirebaseFirestore.instance
  //             .collection('Users')
  //             .doc(userId.toString())
  //             .get();
  //         if (doc.exists) {
  //           user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
  //         }
  //       } catch (e) {
  //         log('خطأ في جلب المستخدم $userId: $e');
  //       }
  //     }
  //
  //     user ??= UserModel(
  //       user_id: userId,
  //       first_name: 'مستخدم غير معروف',
  //       roleID: 0,
  //     );
  //
  //     users.add(user);
  //   }
  //   if (!mounted) return;
  //   setState(() {
  //     conversationUsers = users;
  //   });
  // }

  // استخراج آخر رسالة لكل مستخدم
  // Future<Map<String, Message>> _getLastMessages() async {
  //   List<Message> allMessages = await messageController.getMessages();
  //   Map<String, Message> lastMessages = {};
  //
  //   for (var user in conversationUsers) {
  //     if (user.user_id == null) continue;
  //
  //     // البحث عن آخر رسالة بين المستخدم الحالي والمستخدم في المحادثة
  //     List<Message> userMessages = allMessages
  //         .where((msg) =>
  //             (msg.senderId == widget.currentUser.user_id &&
  //                 msg.receiverId == user.user_id) ||
  //             (msg.senderId == user.user_id &&
  //                 msg.receiverId == widget.currentUser.user_id))
  //         .toList();
  //
  //     if (userMessages.isNotEmpty) {
  //       // ترتيب الرسائل حسب الوقت (الأحدث أولاً)
  //       userMessages.sort((a, b) =>
  //           DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp)));
  //
  //       lastMessages[user.user_id!] = userMessages.first;
  //     }
  //   }
  //
  //   return lastMessages;
  // }

  // تنسيق التاريخ بشكل أفضل
  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (messageDate == today) {
        // إذا كانت الرسالة اليوم، أظهر الوقت فقط
        return DateFormat('HH:mm').format(dateTime);
      } else if (messageDate == today.subtract(Duration(days: 1))) {
        // إذا كانت الرسالة بالأمس
        return 'أمس';
      } else {
        // غير ذلك، أظهر التاريخ
        return DateFormat('yyyy/MM/dd').format(dateTime);
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Text('المحادثات', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // يمكن إضافة وظيفة البحث في المستقبل
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('سيتم إضافة البحث قريباً')));
              },
              tooltip: 'بحث',
            ),
            Consumer<MessageProvider>(
              builder: (context, prov, child) => IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  // prov.loadConversations();
                  prov.loadMessageFromFirebase();
                },
                tooltip: 'تحديث المحادثات',
              ),
            )
          ],
        ),
        body: Consumer<MessageProvider>(
          builder: (context, prov, child) => RefreshIndicator(
            onRefresh: () async {
              await prov.loadMessageFromFirebase();
              await prov.getLastMessages();
            },
            child: prov.users.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 64, color: Theme.of(context).disabledColor),
                        SizedBox(height: 16),
                        Text(
                          'لا توجد محادثات',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: Icon(Icons.add),
                          label: Text('بدء محادثة جديدة'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UsersScreen(
                                  currentUser: widget.currentUser,
                                ),
                              ),
                            ).then((_) async {
                              await prov.loadMessageFromFirebase();
                              await prov.getLastMessages();
                            });
                          },
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: prov.users.length,
                    separatorBuilder: (context, index) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = prov.users[index];
                      final lastMessage = prov.lastMessages[user.user_id];
                      final hasUnreadMessage = lastMessage != null &&
                          lastMessage.senderId != CurrentUser.user!.user_id &&
                          lastMessage.isRead == 0;

                      return InkWell(
                        // onLongPress: () => showDialog(
                        //   context: context,
                        //   builder: (context) => AlertDialog(
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(15),
                        //     ),
                        //     title: Row(
                        //       children: [
                        //         Icon(Icons.delete_forever,
                        //             color: Colors.red, size: 28),
                        //         SizedBox(width: 8),
                        //         Text(
                        //           'حذف المحادثة',
                        //           style: TextStyle(fontWeight: FontWeight.bold),
                        //         ),
                        //       ],
                        //     ),
                        //     content: Text(
                        //       'هل أنت متأكد أنك تريد حذف هذه المحادثة نهائيًا؟\n'
                        //       'لن تتمكن من استعادتها لاحقًا.',
                        //       style: TextStyle(fontSize: 16, height: 1.5),
                        //     ),
                        //     actionsPadding: EdgeInsets.symmetric(
                        //         horizontal: 16, vertical: 8),
                        //     actions: [
                        //       TextButton(
                        //         onPressed: () => Navigator.pop(context),
                        //         child: Text(
                        //           'إلغاء',
                        //           style: TextStyle(color: Colors.grey[700]),
                        //         ),
                        //       ),
                        //       ElevatedButton.icon(
                        //         style: ElevatedButton.styleFrom(
                        //           backgroundColor: Colors.red,
                        //           shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(8),
                        //           ),
                        //           padding: EdgeInsets.symmetric(
                        //               horizontal: 16, vertical: 10),
                        //         ),
                        //         icon: Icon(Icons.delete, color: Colors.white),
                        //         label: Text(
                        //           'حذف نهائي',
                        //           style: TextStyle(
                        //               color: Colors.white,
                        //               fontWeight: FontWeight.bold),
                        //         ),
                        //         onPressed: () {
                        //           // 🔹 ضع هنا دالة الحذف
                        //           (context).read<MessageProvider>().delete(
                        //               user.user_id!,
                        //               CurrentUser.user!.user_id!);
                        //           Navigator.pop(context);
                        //         },
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                currentUser: widget.currentUser,
                                selectedUser: user,
                              ),
                            ),
                          ).then((_) async {
                            await prov.loadMessageFromFirebase();
                            await prov.getLastMessages();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          color: hasUnreadMessage ? Colors.blue.shade50 : null,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: user.roleID == 2
                                    ? Colors.blue.shade100
                                    : Colors.green.shade100,
                                child: Text(
                                  user.first_name?[0] ?? '?',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: user.roleID == 2
                                        ? Colors.blue.shade700
                                        : Colors.green.shade700,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${user.first_name ?? ''} ${user.middle_name ?? ''} ${user.last_name ?? ''}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: hasUnreadMessage
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (lastMessage != null)
                                          Text(
                                            _formatTimestamp(
                                                lastMessage.timestamp),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: hasUnreadMessage
                                                  ? Colors.blue.shade700
                                                  : Colors.grey.shade600,
                                              fontWeight: hasUnreadMessage
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: user.roleID == 2
                                                ? Colors.blue.shade50
                                                : Colors.green.shade50,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            user.roleID == 1
                                                ? 'مدير'
                                                : user.roleID == 2
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
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            lastMessage?.content ??
                                                'لا توجد رسائل',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: hasUnreadMessage
                                                  ? Colors.black87
                                                  : Colors.grey.shade600,
                                              fontWeight: hasUnreadMessage
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        if (hasUnreadMessage)
                                          Container(
                                            margin: EdgeInsets.only(left: 8),
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        floatingActionButton: Consumer<MessageProvider>(
          builder: (context, prov, child) => FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UsersScreen(
                    currentUser: widget.currentUser,
                  ),
                ),
              ).then((_) => prov.loadConversations());
            },
            backgroundColor: Theme.of(context).primaryColor,
            tooltip: 'محادثة جديدة',
            child: Icon(Icons.add_comment, color: Colors.white),
          ),
        ));
  }
}
