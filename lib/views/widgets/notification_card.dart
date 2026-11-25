import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الإشعارات',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildNotificationItem('انخفاض نسبة الأنشطة مقارنة بالشهر الماضي'),
            _buildNotificationItem('زيادة في نسبة الانضباط داخل المدارس'),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String message) {
    return Row(
      children: [
        Icon(Icons.notifications, color: Colors.orange),
        SizedBox(width: 10),
        Expanded(child: Text(message)),
      ],
    );
  }
}
