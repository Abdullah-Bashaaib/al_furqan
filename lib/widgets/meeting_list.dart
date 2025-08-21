import 'package:flutter/material.dart';

class MeetingList extends StatelessWidget {
  const MeetingList({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> meetings = [
      {'name': 'اجتماع تطوير التعليم', 'status': true},
      {'name': 'اجتماع الأنشطة المدرسية', 'status': false},
      {'name': 'اجتماع أولياء الأمور', 'status': true},
    ];

    return Column(
      children: meetings.map((meeting) {
        return Card(
          child: ListTile(
            title: Text(meeting['name']),
            trailing: Icon(
                meeting['status'] ? Icons.check_circle : Icons.cancel,
                color: meeting['status'] ? Colors.green : Colors.red),
          ),
        );
      }).toList(),
    );
  }
}
