import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;

  const StatCard({super.key, 
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Color.fromARGB(255, 1, 117, 70),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: Colors.green, width: 2)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('$value',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
