import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final Widget destination;
  final Color color;

  const CustomButton({super.key, 
    required this.label,
    required this.destination,
    this.color = Colors.deepOrange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 8.0, horizontal: 20.0), // تحسين التباعد
      child: SizedBox(
        width: double.infinity, // جعل الأزرار تأخذ العرض الكامل
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: EdgeInsets.symmetric(vertical: 16), // تحسين حجم الزر
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)), // إضافة حواف دائرية
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          },
          child: Text(
            label,
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
