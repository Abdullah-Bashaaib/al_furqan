import 'package:flutter/material.dart';

class TeacherRequest extends StatefulWidget {
  const TeacherRequest({super.key});

  @override
  State<TeacherRequest> createState() => _TeacherRequestState();
}

class _TeacherRequestState extends State<TeacherRequest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Hi Am Teacher Request"),
      ),
    );
  }
}
