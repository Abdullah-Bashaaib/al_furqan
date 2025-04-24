import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({super.key});

  @override
  _AddTeacherScreenState createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  File? _image;
  final picker = ImagePicker();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController grandFatherNameController =
      TextEditingController();
  final TextEditingController tribeController = TextEditingController();

  // لاختيار الصورة من المعرض
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة معلم')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رفع صورة المعلم
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? Icon(Icons.camera_alt, size: 30, color: Colors.grey)
                      : null,
                ),
              ),
            ),

            SizedBox(height: 20),

            // حقول إدخال البيانات
            _buildTextField(firstNameController, 'الاسم الأول'),
            _buildTextField(fatherNameController, 'اسم الأب'),
            _buildTextField(grandFatherNameController, 'اسم الجد'),
            _buildTextField(tribeController, 'القبيلة'),

            SizedBox(height: 20),

            // الأزرار
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // تنفيذ عملية إضافة المعلم
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text('إضافة'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // الانتقال إلى صفحة إدارة المعلمين
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text('إدارة'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // تصميم حقل إدخال نصي
  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
