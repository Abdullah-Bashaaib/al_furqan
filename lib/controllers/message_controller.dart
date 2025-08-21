import 'package:al_furqan/helper/sqldb.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:al_furqan/services/message_sevice.dart';

import '../models/messages_model.dart';

class MessageController {
  // Save message to SQLite
  Future<int> saveMessage(Message message) async {
    final db = await sqlDb.database;
    return await db.insert('messages', message.toMap());
  }

  // Update message in SQLite
  Future<int> updateMessage(Message message) async {
    final db = await sqlDb.database;
    return await db.update(
      'messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  // Delete message from SQLite
  Future<int> deleteMessage(int id) async {
    final db = await sqlDb.database;
    return await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get all messages
  Future<List<Message>> getMessages() async {
    final db = await sqlDb.database;
    final result = await db.query('messages');
    return result.map((json) => Message.fromMap(json)).toList();
  }

  // Get messages for a specific receiver
  Future<List<Message>> getMessagesForReceiver(int receiverId) async {
    final db = await sqlDb.database;
    final result = await db.query(
      'messages',
      where: 'receiverId = ?',
      whereArgs: [receiverId],
    );
    return result.map((json) => Message.fromMap(json)).toList();
  }

  // عدد الرسائل غير المقروءة للمستخدم
  Future<int> getUnreadMessagesCount(String receiverId) async {
    try {
      final db = await sqlDb.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM messages WHERE receiverId = ? AND isRead = 0',
        [receiverId],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      debugPrint('خطأ في عد الرسائل غير المقروءة: $e');
      return 0; // إرجاع 0 في حالة حدوث خطأ
    }
  }

  // تعليم الرسائل كمقروءة
  Future<void> markMessagesAsRead(String receiverId) async {
    try {
      // تحديث قاعدة البيانات المحلية
      final db = await sqlDb.database;
      await db.update(
        'messages',
        {'isRead': 1},
        where: 'receiverId = ? AND isRead = 0',
        whereArgs: [receiverId],
      );

      // تحديث قاعدة بيانات الفايربيس
      await messageService.updateMessagesReadStatus(receiverId);
    } catch (e) {
      debugPrint('خطأ في تعليم الرسائل كمقروءة: $e');
    }
  }

  Future<void> deleteConversation(String senderId, String receiverId) async {
    try {
      // 🔹 حذف من SQLite
      final db = await sqlDb.database;
      await db.delete(
        'Messages',
        where: 'senderId = ? AND receiverId = ?',
        whereArgs: [senderId, receiverId],
      );
      print('📌 تم حذف الرسائل من SQLite بين $senderId و $receiverId');

      await messageService.deleteConversationFire(senderId, receiverId);
    } catch (e) {
      print('❌ خطأ أثناء حذف المحادثة: $e');
    }
  }

  Future close() async {
    final db = await sqlDb.database;
    db.close();
  }
}

MessageController messageController = MessageController();
