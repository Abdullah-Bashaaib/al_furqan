import 'package:flutter/material.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController repeatController = TextEditingController();
  TimeOfDay? selectedTime;
  List<String> months = [
    "محرم", "صفر", "ربيع الأول", "ربيع الآخر", "جمادى الأولى", "جمادى الآخرة",
    "رجب", "شعبان", "رمضان", "شوال", "ذو القعدة", "ذو الحجة"
  ];
  List<String> selectedMonths = [];

  void pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  void toggleMonthSelection(String month) {
    setState(() {
      if (selectedMonths.contains(month)) {
        selectedMonths.remove(month);
      } else {
        selectedMonths.add(month);
      }
    });
  }

  void addActivity() {
    String name = nameController.text;
    String repeat = repeatController.text;
    if (name.isEmpty || selectedTime == null || selectedMonths.isEmpty || repeat.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("يرجى ملء جميع الحقول")),
      );
      return;
    }
    
    Navigator.pop(context, {
      "name": name,
      "time": selectedTime!.format(context),
      "months": selectedMonths,
      "repeat": repeat,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("إضافة نشاط")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // إدخال اسم النشاط
            Row(
              children: [
                Text("اسم النشاط: ", style: TextStyle(fontSize: 16)),
                Expanded(
                  child: TextField(controller: nameController, decoration: InputDecoration(hintText: "أدخل اسم النشاط")),
                ),
              ],
            ),
            SizedBox(height: 16),

            // اختيار الوقت
            Row(
              children: [
                Text("الزمن: ", style: TextStyle(fontSize: 16)),
                ElevatedButton(
                  onPressed: pickTime,
                  child: Text(selectedTime != null ? selectedTime!.format(context) : "اختيار الوقت"),
                ),
              ],
            ),
            SizedBox(height: 16),

            // اختيار الشهور
            Text("الشهور:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0,
              children: months.map((month) {
                bool isSelected = selectedMonths.contains(month);
                return ChoiceChip(
                  label: Text(month),
                  selected: isSelected,
                  onSelected: (selected) => toggleMonthSelection(month),
                  selectedColor: Colors.blue,
                  backgroundColor: Colors.grey[300],
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            // إدخال عدد التكرار
            Row(
              children: [
                Text("التكرار في الشهر:", style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: repeatController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: "عدد"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // أزرار الإضافة والإلغاء
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: addActivity,
                  child: Text("إضافة"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("إلغاء"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
