import 'package:flutter/material.dart';

class AddStudentData extends StatelessWidget {
  const AddStudentData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('إضافة بيانات الطالب',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                title: 'مخطط الحفظ',
                fields: ['من', 'إلى'],
              ),
              SizedBox(height: 16),
              _buildSectionCard(
                title: 'منفذ الحفظ',
                fields: ['من', 'إلى'],
              ),
              SizedBox(height: 16),
              _buildAttendanceCard(),
              SizedBox(height: 16),
              _buildNotesSection('أسباب الغياب'),
              SizedBox(height: 16),
              _buildNotesSection('الملاحظات'),
              SizedBox(height: 16),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // دالة لإنشاء كروت البيانات
  Widget _buildSectionCard(
      {required String title, required List<String> fields}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10),
            Column(
              children: fields.map((label) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: label,
                      prefixIcon: Icon(Icons.bookmark_border),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // دالة لإنشاء كارت بيانات الحضور والغياب
  Widget _buildAttendanceCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('بيانات الحضور والغياب',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10),
            _buildTextRow('أيام الدوام:', '25 يوم'),
            SizedBox(height: 12),
            _buildTextFieldRow('أيام الغياب بدون عذر:'),
            _buildTextFieldRow('أيام الحضور:'),
            _buildTextFieldRow('أيام الغياب بعذر:'),
          ],
        ),
      ),
    );
  }

  // دالة لإنشاء صف يتضمن نص وإدخال بيانات
  Widget _buildTextFieldRow(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(label,
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // دالة لإنشاء قسم الملاحظات
  Widget _buildNotesSection(String title) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'اكتب $title هنا',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة لإنشاء صف زر الإضافة والإلغاء
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {
            // تنفيذ عملية الإضافة
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          child: Text('إضافة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // إغلاق الصفحة عند الضغط على إلغاء
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          child: Text('إلغاء',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // دالة لإنشاء صف نصي بسيط
  Widget _buildTextRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
