import 'package:al_furqan/models/schools_model.dart';
import 'package:flutter/material.dart';

class SchoolReportPage extends StatefulWidget {
  final SchoolModel schoolModel;
  final int numberT;
  final int numberS;

  // static final List<Map<String, dynamic>> halqatReportSample = [
  //   {
  //     "school_name": "مدرسة الفرقان لتحفيظ القرآن الكريم",
  //     "teacher_name": "الشيخ أحمد العتيبي",
  //     "halqa_name": "حلقة النور",
  //     "student_count": 12,
  //     "attendance_percentage": 92,
  //     "memorization_progress": 80,
  //     "notes": "الطلاب ملتزمون، ويوجد تحسن ملحوظ في الأداء."
  //   },
  //   {
  //     "school_name": "مدرسة الفرقان لتحفيظ القرآن الكريم",
  //     "teacher_name": "الشيخ أحمد العتيبي",
  //     "halqa_name": "حلقة النور",
  //     "student_count": 12,
  //     "attendance_percentage": 92,
  //     "memorization_progress": 80,
  //     "notes": "الطلاب ملتزمون، ويوجد تحسن ملحوظ في الأداء."
  //   },
  // ];

  const SchoolReportPage(
      {super.key,
      required this.schoolModel,
      required this.numberT,
      required this.numberS});

  @override
  State<SchoolReportPage> createState() => _SchoolReportPageState();
}

@override
void initState() {
  // syncData();
  // _loadAdditionalData();
}

class _SchoolReportPageState extends State<SchoolReportPage> {
  Future<void> schoolReport(int schoolId) async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تقرير المدرسة"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildRow("اسم المدرسة:", widget.schoolModel.school_name!),
                // buildRow("اسم الحلقة:", widget.),
                buildRow("عدد المعلمين:", widget.numberT.toString()),
                buildRow("عدد الطلاب:", widget.numberS.toString()),
                // buildRow("نسبة الحضور:", "${report['attendance_percentage']}%"),
                // buildRow("نسبة الإنجاز في الحفظ:",
                //     "${report['memorization_progress']}%"),
                // const SizedBox(height: 16),
                // const Text(
                //   "ملاحظات:",
                //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                // ),
                // const SizedBox(height: 8),
                // Text(report['notes']),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await schoolReport(widget.schoolModel.schoolID!);

          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (_) => PdfPreview(
          //             build: (format) => BuildPdf(records: halqatReportSample)
          //                 .buildReportPdf())));
        },
        label: const Text("طباعة"),
        icon: const Icon(Icons.print),
      ),
    );
  }

  Widget buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }
}
