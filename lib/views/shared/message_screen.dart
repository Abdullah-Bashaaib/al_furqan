import 'package:al_furqan/controllers/message_controller.dart';
import 'package:al_furqan/models/messages_model.dart';
import 'package:al_furqan/models/provider/message_provider.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/message_sevice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final UserModel currentUser;
  final UserModel? selectedUser;

  const ChatScreen({
    super.key,
    required this.currentUser,
    this.selectedUser,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> messages = [];
  List<Message> receivedMessages = [];

  @override
  void initState() {
    super.initState();
    // print(widget.selectedUser);
    if (widget.selectedUser != null) {
      loadMessages();
    } else {
      loadReceivedMessages();
    }

    // Mark messages as read when the chat is opened
    if (widget.currentUser.user_id != null) {
      markMessagesAsRead();
    }
    (context).read<MessageProvider>().loadUnreadMessage();
  }

  // دالة لتحميل المحادثة بين المستخدم الحالي والمستخدم المختار
  Future<void> loadMessages() async {
    if (widget.selectedUser == null || widget.selectedUser!.user_id == null) {
      debugPrint('خطأ: لا يوجد مستخدم مختار أو معرف المستخدم غير موجود');
      return;
    }

    List<Message> allMessages = await messageController.getMessages();
    setState(() {
      messages = allMessages
          .where((msg) =>
              (msg.senderId == widget.currentUser.user_id &&
                  msg.receiverId == widget.selectedUser!.user_id) ||
              (msg.senderId == widget.selectedUser!.user_id &&
                  msg.receiverId == widget.currentUser.user_id))
          .toList();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    // Mark messages as read after loading
    markMessagesAsRead();
  }

  // دالة لتحميل الرسائل المرسلة إلى المستخدم الحالي فقط
  Future<void> loadReceivedMessages() async {
    if (widget.currentUser.user_id == null) {
      debugPrint('خطأ: معرف المستخدم الحالي غير موجود');
      return;
    }

    List<Message> allMessages = await messageController.getMessages();
    setState(() {
      receivedMessages = allMessages
          .where((msg) => msg.receiverId == widget.currentUser.user_id)
          .toList();
    });

    // Mark messages as read after loading
    markMessagesAsRead();
  }

  // دالة لإرسال رسالة جديدة
  Future<void> sendMessage() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال رسالة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.selectedUser == null || widget.selectedUser!.user_id == null) {
      debugPrint('خطأ: لا يمكن إرسال رسالة بدون مستخدم مختار');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: اختر مستخدمًا للمراسلة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final message = Message(
      senderId: widget.currentUser.user_id,
      receiverId: widget.selectedUser!.user_id!,
      content: _controller.text,
      timestamp: DateTime.now().toIso8601String(),
      sync: 0,
      senderType: widget.currentUser.roleID.toString(),
    );

    try {
      await messageService.saveMessage(message, 1);
      _controller.clear();
      loadMessages(); // تحديث الرسائل بعد الإرسال
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال الرسالة'),
          // ignore: use_build_context_synchronously
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    } catch (e) {
      debugPrint('خطأ في إرسال الرسالة: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل إرسال الرسالة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // دالة لحذف رسالة
  Future<void> deleteMessage(int messageId) async {
    await messageService.deleteMessage(messageId.toString(), messageId);
    loadMessages(); // تحديث الرسائل بعد الحذف
    loadReceivedMessages(); // تحديث الرسائل المستلمة
  }

  // دالة لتعليم الرسائل كمقروءة
  Future<void> markMessagesAsRead() async {
    if (widget.currentUser.user_id == null) {
      debugPrint('خطأ: معرف المستخدم الحالي غير موجود');
      return;
    }

    try {
      // تعليم جميع الرسائل الخاصة بالمستخدم الحالي كمقروءة
      await messageController.markMessagesAsRead(widget.currentUser.user_id!);
      debugPrint('تم تعليم الرسائل كمقروءة');
    } catch (e) {
      debugPrint('خطأ في تعليم الرسائل كمقروءة: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
        return 'أمس ${DateFormat('HH:mm').format(dateTime)}';
      } else {
        // غير ذلك، أظهر التاريخ
        return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
      }
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showReceivedMessages = widget.selectedUser == null;
    List<Message> displayMessages =
        showReceivedMessages ? receivedMessages : messages;

    // ترتيب الرسائل حسب الوقت (الأحدث أولاً)
    displayMessages.sort(
      (a, b) =>
          DateTime.parse(a.timestamp).compareTo(DateTime.parse(b.timestamp)),
    );

    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text(
            textAlign: TextAlign.center,
            showReceivedMessages
                ? 'الرسائل المستلمة'
                : '${widget.selectedUser!.first_name} ${widget.selectedUser!.middle_name ?? ''} ${widget.selectedUser!.last_name}',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
          ),
          subtitle: Container(
            width: 100,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (widget.selectedUser != null &&
                      (widget.selectedUser!.roleID == 2 ||
                          widget.selectedUser!.roleID == 1))
                  ? Colors.blue.shade50
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                widget.selectedUser!.roleID == 1
                    ? 'مدير'
                    : widget.selectedUser!.roleID == 2
                        ? 'معلم'
                        : 'ولي أمر',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.selectedUser!.roleID == 2 ||
                          widget.selectedUser!.roleID == 1
                      ? Colors.blue.shade700
                      : Colors.green.shade700,
                ),
              ),
            ),
          ),
        ),
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
            tooltip: 'بحث في الرسائل',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed:
                showReceivedMessages ? loadReceivedMessages : loadMessages,
            tooltip: 'تحديث الرسائل',
          ),
        ],
      ),
      body: Column(
        children: [
          // قائمة الرسائل
          Expanded(
            child: RefreshIndicator(
              onRefresh:
                  showReceivedMessages ? loadReceivedMessages : loadMessages,
              child: displayMessages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 64, color: Theme.of(context).disabledColor),
                          SizedBox(height: 16),
                          Text(
                            showReceivedMessages
                                ? 'لا توجد رسائل مستلمة'
                                : 'لا توجد رسائل، ابدأ المحادثة!',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      reverse: false, // Keep messages in chronological order
                      itemCount: displayMessages.length,
                      itemBuilder: (context, index) {
                        final message = displayMessages[index];
                        final isSender =
                            message.senderId == widget.currentUser.user_id;

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: isSender
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isSender)
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: showReceivedMessages
                                      ? Colors.orange.shade100
                                      : widget.selectedUser!.roleID == 2
                                          ? Colors.blue.shade100
                                          : Colors.green.shade100,
                                  child: Text(
                                    showReceivedMessages
                                        ? (message.senderType == '2'
                                            ? 'م'
                                            : 'و')
                                        : widget.selectedUser!.first_name?[0] ??
                                            '?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: showReceivedMessages
                                          ? Colors.orange.shade800
                                          : widget.selectedUser!.roleID == 2
                                              ? Colors.blue.shade700
                                              : Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSender
                                        ? Colors.blue.shade100
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        // ignore: deprecated_member_use
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 2,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message.content,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        _formatTimestamp(message.timestamp),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              if (isSender)
                                IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      size: 18, color: Colors.red.shade300),
                                  constraints: BoxConstraints(
                                      maxWidth: 24, maxHeight: 24),
                                  padding: EdgeInsets.zero,
                                  onPressed: () => deleteMessage(message.id!),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
          // شريط إدخال الرسائل (داخل الـ Column بدلاً من bottomNavigationBar)
          if (!showReceivedMessages)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: MediaQuery.of(context).viewInsets.bottom > 0
                      ? 8
                      : 8 + MediaQuery.of(context).padding.bottom),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.grey.shade600),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('سيتم إضافة إرفاق الملفات قريباً')));
                    },
                    tooltip: 'إرفاق ملف',
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                    ),
                  ),
                  SizedBox(width: 8),
                  Material(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: sendMessage,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
