import 'package:flutter/material.dart';

class AddIslamicStudiesPlanPage extends StatefulWidget {
  const AddIslamicStudiesPlanPage({super.key});

  @override
  _AddIslamicStudiesPlanPageState createState() =>
      _AddIslamicStudiesPlanPageState();
}

class _AddIslamicStudiesPlanPageState extends State<AddIslamicStudiesPlanPage> {
  // القيم الافتراضية
  String selectedCurriculum = 'الفقه';
  final List<String> curriculums = ['الفقه', 'التفسير', 'الحديث', 'التوحيد'];

  final TextEditingController planController = TextEditingController();
  final TextEditingController executedController = TextEditingController();
  final TextEditingController delayReasonsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('إضافة خطة العلوم الشرعية'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // كارد خطة العلوم الشرعية
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('خطة العلوم الشرعية',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      // اختيار المنهج
                      Row(
                        children: [
                          Text('المقرر:', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedCurriculum,
                              items: curriculums.map((String curriculum) {
                                return DropdownMenuItem<String>(
                                  value: curriculum,
                                  child: Text(curriculum),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCurriculum = value!;
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // المخطط
                      Row(
                        children: [
                          Text('المخطط:', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: planController,
                              decoration: InputDecoration(
                                hintText: 'اكتب ما تم تخطيطه',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // المنفذ
                      Row(
                        children: [
                          Text('المنفذ:', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: executedController,
                              decoration: InputDecoration(
                                hintText: 'اكتب ما تم تنفيذه',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // كارد أسباب التأخر
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('أسباب التأخر في المنهج',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      TextField(
                        controller: delayReasonsController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'اكتب أسباب التأخر هنا',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // أزرار إضافة وإلغاء
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (planController.text.isEmpty ||
                          executedController.text.isEmpty ||
                          delayReasonsController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('يرجى ملء جميع الحقول')),
                        );
                      } else {
                        // تنفيذ عملية الإضافة
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('تم إضافة الخطة بنجاح')),
                        );
                      }
                    },
                    child: Text('إضافة'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // تنفيذ عملية الإلغاء
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text('إلغاء'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
