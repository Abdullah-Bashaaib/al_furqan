import 'package:al_furqan/controllers/message_controller.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/current_user.dart';
import 'package:al_furqan/main.dart';
import 'package:al_furqan/models/messages_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/message_sevice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../controllers/HalagaController.dart';
import '../../controllers/fathers_controller.dart';

class MessageProvider with ChangeNotifier {
  List<Message> messages = [];
  List<UserModel> parents = [];
  List<UserModel> teachers = [];
  List<UserModel> users = [];
  List<String> userIds = [];
  Map<String, Message> lastMessages = {};
  UserModel? managerN;
  int unreadMessagesCount = 0;

  get parentsList => parents;
  get teachersList => teachers;
  int get unReadCount => unreadMessagesCount;
  UserModel? get manager => managerN;

  final int? roleID = perf.getInt('roleID');
  final int? schoolID = perf.getInt('schoolId');
  final String? elhalagatID = perf.getString('halagaID');
  final String? userID = perf.getString('user_id');

  MessageProvider() {
    init();
  }
  init() async {
    print('===== تم تشغيل دالة البناء للرسائل =====');
    // final sw3 = Stopwatch()..start();
    if (CurrentUser.user != null) {
      await loadMessageFromFirebase();
    }
    // sw3.stop();
    // int timeSyncStudents = sw3.elapsedMilliseconds;
    // debugPrint("Time load messages is : $timeSyncStudents ms");
  }

  loadUnreadMessage() async {
    unreadMessagesCount =
        await messageController.getUnreadMessagesCount(userID!);
    print('===== تم تحميل الرسائل الغير مقروءة =====');
    notifyListeners();
  }

  loadMessages() async {
    List<Message> messagesList = await messageController.getMessages();
    messages.clear();
    messages.addAll(messagesList);
    notifyListeners();
  }

  Future<void> loadMessageFromFirebase() async {
    // تحميل الرسائل من فايربيس
    if (userID == null) {
      // print("❌ userID is null. Cannot load messages.");
      return;
    }
    await messageService.loadMessagesFromFirestore(userID!);

    // تحديث قائمة الرسائل في الذاكرة
    await loadMessages();

    // تحميل المستخدمين المرتبطين (آباء/معلمين)
    await loadUsers();

    // إنشاء قائمة المستخدمين الذين يوجد بينهم محادثات
    await loadConversations();

    // جلب آخر رسالة لكل مستخدم
    await getLastMessages();
    notifyListeners();

    // حساب عدد الرسائل غير المقروءة
    await loadUnreadMessage();

    // إعلام الواجهة بالتحديث
    notifyListeners();
  }

  loadUsers() async {
    try {
      // debugPrint('RoleID: $roleID');
      // debugPrint('SchoolID: $schoolID');
      // debugPrint('ElhalagatID: $elhalagatID');
      List<UserModel> parentsList;
      List<UserModel> teachersList;

      if (roleID == 1) {
        // المدير: يحمل كل أولياء الأمور في المدرسة
        parentsList = (await fathersController.getFathersBySchoolId(schoolID!))
            .where((user) => user.user_id != null && user.user_id != 0)
            .toList();
        parents.clear();
        parents.addAll(parentsList);
        debugPrint('Loaded ${parents.length} parents for manager');

        teachersList = (await halagaController.getTeachers(schoolID!))
            .where((user) => user.user_id != null && user.user_id != 0)
            .toList();
        teachers.clear();
        teachers.addAll(teachersList);
        debugPrint('Loaded ${teachers.length} teachers for manager');
      } else if (roleID == 2) {
        // المعلم: يحمل فقط أولياء الأمور من الحلقة المعينة
        if (elhalagatID != null && elhalagatID!.isNotEmpty) {
          parentsList = (await fathersController
                  .getFathersByElhalagaId(elhalagatID!))
              .where((user) => user.user_id != null && user.user_id!.isNotEmpty)
              .toList();
          parents.clear();
          parents.addAll(parentsList);
          managerN = await userController.loadManager(schoolID!);
          print('===== تم تحميل المدير =====');
          debugPrint(
              'Loaded ${parents.length} parents for teacher in halka $elhalagatID');
        } else {
          debugPrint('Warning: elhalagatID is null or empty for teacher');
          parents = [];
        }
      } else {
        debugPrint('Unsupported roleID: $roleID');
        parents = [];
        teachers = [];
      }
    } catch (e) {
      debugPrint('Error in loadUsers: $e');
      parents = [];
      teachers = [];
    }
    notifyListeners();
  }

  Future<void> loadConversations() async {
    // users.clear();
    // await messageService.loadMessagesFromFirestore(userID!);
    await loadMessages();
    for (var message in messages) {
      if (message.senderId == userID) {
        if (!userIds.contains(message.receiverId)) {
          userIds.add(message.receiverId!);
        }
      } else if (message.receiverId == userID) {
        if (!userIds.contains(message.senderId)) {
          userIds.add(message.senderId!);
        }
      }
    }

    for (String userId in userIds) {
      UserModel? user;
      for (var parent in parents) {
        if (parent.user_id == userId) {
          user = parent;
          break;
        }
      }
      if (user == null) {
        for (var teacher in teachers) {
          if (teacher.user_id == userId) {
            user = teacher;
            break;
          }
        }
      }

      if (user == null) {
        try {
          var doc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId.toString())
              .get();
          if (doc.exists) {
            user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
          }
        } catch (e) {
          // log('خطأ في جلب المستخدم $userId: $e');
        }
      }

      user ??= UserModel(
        user_id: userId,
        first_name: 'مستخدم غير معروف',
        roleID: 0,
      );

      if (!users.any((u) => u.user_id == user?.user_id)) {
        users.add(user);
      }
    }
    notifyListeners();
  }

  Future<Map<String, Message>> getLastMessages() async {
    // List<Message> allMessages = await messageController.getMessages();

    for (var user in users) {
      if (user.user_id == null) continue;

      // البحث عن آخر رسالة بين المستخدم الحالي والمستخدم في المحادثة
      List<Message> userMessages = messages
          .where((msg) =>
              (msg.senderId == userID && msg.receiverId == user.user_id) ||
              (msg.senderId == user.user_id && msg.receiverId == userID))
          .toList();

      if (userMessages.isNotEmpty) {
        // ترتيب الرسائل حسب الوقت (الأحدث أولاً)
        userMessages.sort((a, b) =>
            DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp)));

        lastMessages[user.user_id!] = userMessages.first;
      }
    }

    return lastMessages;
  }

  Future<void> delete(String senderId, String receiverId) async {
    await messageController.deleteConversation(senderId, receiverId);
    await loadMessageFromFirebase();
  }

  void clear() {
    messages.clear();
    parents.clear();
    teachers.clear();
    users.clear();
    userIds.clear();
    lastMessages.clear();
    unreadMessagesCount = 0;
    notifyListeners();
  }
}
