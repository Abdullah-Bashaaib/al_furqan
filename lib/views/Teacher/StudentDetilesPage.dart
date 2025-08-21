import 'package:al_furqan/models/student_model.dart';
import 'package:flutter/material.dart';

class StudentDetailsPage extends StatelessWidget {
  final String studentName;
  @override
  const StudentDetailsPage({super.key, required this.studentName, required StudentModel student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          studentName, // اسم الطالب
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // نسب الحفظ والحضور
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard("نسبة الحفظ", "progressPercentage%"),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child:
                        _buildInfoCard("نسبة الحضور", "attendancePercentage%"),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // مقدار الحفظ
              _buildSectionTitle("مقدار الحفظ"),
              _buildTextField("اكتب مقدار الحفظ هنا"),

              SizedBox(height: 16),
              _buildSectionTitle("مخطط الحفظ"),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField("من (مثل سورة المدثر آية 5)")),
                  SizedBox(width: 16),
                  Expanded(child: _buildTextField("إلى (مثل سورة الجن آية 5)")),
                ],
              ),
              Divider(),

              _buildSectionTitle("منفذ الحفظ"),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField("من (مثل سورة المدثر آية 5)")),
                  SizedBox(width: 16),
                  Expanded(
                      child: _buildTextField("إلى (مثل سورة المزمل آية 5)")),
                ],
              ),
              SizedBox(height: 16),

              // أزرار التعديل والحذف
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton("تعديل", Colors.blue, Icons.edit, () {}),
                  _buildActionButton("حذف", Colors.red, Icons.delete, () {}),
                ],
              ),
              SizedBox(height: 16),

              // كارد رسم بياني (تطور الحفظ)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      '📊 رسم بياني (تطور الحفظ)',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700]),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // زر الحفظ
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.save, size: 24),
                  label: Text('حفظ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت لإنشاء كاردات نسبة الحفظ والحضور
  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت لإنشاء عناوين الأقسام
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
    );
  }

  // ويدجت لإنشاء حقل إدخال نص
  Widget _buildTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  // ويدجت لإنشاء أزرار التعديل والحذف
  Widget _buildActionButton(
      String label, Color color, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      label: Text(label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
