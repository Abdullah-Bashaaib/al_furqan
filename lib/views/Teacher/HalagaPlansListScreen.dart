import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/plan_controller.dart';
import 'package:al_furqan/models/conservation_plan_model.dart';
import 'package:al_furqan/models/eltlawah_plan_model.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'HalagaPlansScreen.dart';
import 'EditHalagaPlanScreen.dart';

// ignore: must_be_immutable
class HalagaPlansListScreen extends StatefulWidget {
  HalagaModel halaga;
  HalagaPlansListScreen({super.key, required this.halaga});

  @override
  _HalagaPlansListScreenState createState() =>
      _HalagaPlansListScreenState(halagaModel: halaga);
}

class _HalagaPlansListScreenState extends State<HalagaPlansListScreen> {
  HalagaModel halagaModel;
  _HalagaPlansListScreenState({required this.halagaModel});
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      await planController.getPlans(halagaModel.halagaID!);
      await studentController.getStudents(halagaModel.halagaID!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في تحميل الخطط: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshPlans() async {
    setState(() => _isRefreshing = true);
    try {
      await planController.getPlans(halagaModel.halagaID!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في تحديث الخطط: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'خطط حلقة: ${halagaModel.Name ?? ""}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
          elevation: 2,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(15),
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(
                text: 'خطط الحفظ',
                icon: Icon(Icons.book),
              ),
              Tab(
                text: 'خطط التلاوة',
                icon: Icon(Icons.menu_book),
              ),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('جاري تحميل الخطط...'),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _refreshPlans,
                child: TabBarView(
                  children: [
                    _buildConservationPlansList(),
                    _buildTlawahPlansList(),
                  ],
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddHalagaPlansScreen(halaga: halagaModel),
              ),
            );
            if (result == true) {
              _loadPlans(); // تحديث القوائم بعد إضافة خطط جديدة
            }
          },
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildConservationPlansList() {
    List<ConservationPlanModel> planC = planController.conservationPlans;
    List<StudentModel> student0 = studentController.students;
    if (planC.isEmpty) {
      return _buildEmptyState('لا توجد خطط حفظ متاحة', Icons.book_outlined);
    }
    return _isRefreshing
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: planC.length,
            padding: const EdgeInsets.all(12.0),
            itemBuilder: (context, index) {
              final plan = planC[index];
              final student = student0[index];
              return _buildPlanCard(
                title: "${student.firstName} ${student.lastName}", // اسم الطالب
                content: [
                  // شهر الخطة بشكل مميز
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_month,
                            color: Colors.blue, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'خطة شهر ${plan.planMonth}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // قسم المخطط
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.check_circle,
                                color: Colors.green, size: 16),
                            SizedBox(width: 8),
                            Text(
                              "المخطط",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        _buildInfoRow('من',
                            '${plan.plannedStartSurah}، آية: ${plan.plannedStartAya ?? 0}'),
                        _buildInfoRow('إلى',
                            '${plan.plannedEndSurah}، آية: ${plan.plannedEndAya ?? 0}'),
                      ],
                    ),
                  ),
                  // قسم المنفذ
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.assignment_turned_in,
                                color: Colors.orange, size: 16),
                            SizedBox(width: 8),
                            Text(
                              "المنفذ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        _buildInfoRow('من',
                            '${plan.executedStartSurah} ، ${plan.executedStartAya}'),
                        _buildInfoRow('إلى',
                            '${plan.executedEndSurah} ، ${plan.executedEndAya}'),
                        _buildInfoRow('معدل التنفيذ',
                            '${(plan.executedRate ?? 0) * 100}%'),

                        // يمكن إضافة معلومات منفذة أخرى هنا إذا كانت متوفرة
                      ],
                    ),
                  ),
                  _buildSyncStatus(plan.isSync),
                ],
                onEdit: () => _editPlan(context, plan),
                onDelete: () => _showDeleteConfirmationDialog(
                  plan.conservationPlanId!,
                  "ConservationPlans",
                  "ConservationPlanID",
                ),
              );
            },
          );
  }

  Widget _buildTlawahPlansList() {
    List<EltlawahPlanModel> planE = planController.eltlawahPlans;
    if (planE.isEmpty) {
      return _buildEmptyState(
          'لا توجد خطط تلاوة متاحة', Icons.menu_book_outlined);
    }
    return _isRefreshing
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: planE.length,
            padding: const EdgeInsets.all(12.0),
            itemBuilder: (context, index) {
              final plan = planE[index];
              return _buildPlanCard(
                title: 'خطة شهر ${plan.planMonth ?? 'غير محدد'}',
                content: [
                  _buildInfoRow('من',
                      '${plan.plannedStartSurah}، آية: ${plan.plannedStartAya ?? 0}'),
                  _buildInfoRow('إلى',
                      '${plan.plannedEndSurah}، آية: ${plan.plannedEndAya ?? 0}'),
                  _buildInfoRow(
                      'معدل التنفيذ', '${(plan.executedRate ?? 0) * 100}%'),
                  _buildSyncStatus(plan.isSync),
                ],
                onEdit: () => _editPlan(context, plan),
                onDelete: () => _showDeleteConfirmationDialog(
                  plan.eltlawahPlanId!,
                  "EltlawahPlans",
                  "EltlawahPlanID",
                ),
              );
            },
          );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      AddHalagaPlansScreen(halaga: halagaModel),
                ),
              );
              if (result == true) {
                _loadPlans();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('إضافة خطة جديدة'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required List<Widget> content,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Show details if needed
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: onEdit,
                        tooltip: 'تعديل',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: onDelete,
                        tooltip: 'حذف',
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              ...content,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatus(int? isSync) {
    final bool synced = isSync == 1;
    debugPrint(
        "------------------------------------------------synced: $synced");
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: synced ? Colors.green.shade50 : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: synced ? Colors.green.shade200 : Colors.orange.shade200,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              synced ? Icons.check_circle : Icons.sync_problem,
              color: synced ? Colors.green : Colors.orange,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'المزامنة: ${synced ? 'تمت' : 'لم تتم'}',
              style: TextStyle(
                color: synced ? Colors.green.shade800 : Colors.orange.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      String planID, String table, String column) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تأكيد الحذف',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('هل أنت متأكد من حذف هذه الخطة؟'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade800,
            ),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await planController.deletePlan(planID, table, column);
                if (table == "ConservationPlans") {
                  await firebasehelper.deleteConservationPlan(planID);
                } else if (table == "EltlawahPlans") {
                  await firebasehelper.deleteEltlawahPlan(planID);
                } else if (table == "IslamicStudies") {
                  await firebasehelper.deleteIslamicStudyplan(planID);
                }
                Navigator.of(context).pop(true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('حدث خطأ أثناء الحذف: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.of(context).pop(false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف الخطة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadPlans(); // تحديث القوائم بعد الحذف
    }
  }

  void _editPlan(BuildContext context, dynamic plan) {
    // تحديد نوع الخطة المراد تعديلها
    String planType = "";
    String studentId = "";

    if (plan is ConservationPlanModel) {
      planType = "conservation";
      studentId = plan.studentId!;
    } else if (plan is EltlawahPlanModel) {
      planType = "tlawah";
      // studentId = plan.studentId!;
    }

    // البحث عن الطالب المناسب
    StudentModel student = StudentModel(
        firstName: "طالب",
        lastName: "افتراضي",
        studentID: studentId); // طالب افتراضي
    bool foundStudent = false;

    for (var s in studentController.students) {
      if (s.studentID == studentId) {
        student = s;
        foundStudent = true;
        break;
      }
    }

    if (!foundStudent && planType == 'conservation') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('لم يتم العثور على الطالب، سيتم استخدام بيانات افتراضية'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    // الانتقال إلى شاشة تعديل الخطة الجديدة
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => EditHalagaPlanScreen(
          halaga: halagaModel,
          plan: plan,
          planType: planType,
          student: student,
        ),
      ),
    )
        .then((result) {
      if (result == true) {
        _loadPlans(); // تحديث القوائم بعد التعديل
      }
    });
  }
}
