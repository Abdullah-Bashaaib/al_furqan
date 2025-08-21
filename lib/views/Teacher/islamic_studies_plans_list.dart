import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/plan_controller.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/islamic_studies_model.dart';
import 'package:al_furqan/models/student_model.dart';
import 'package:flutter/material.dart';
import 'EditHalagaPlanScreen.dart';

class IslamicStudiesPlansListScreen extends StatefulWidget {
  final HalagaModel halaga;

  const IslamicStudiesPlansListScreen({Key? key, required this.halaga})
      : super(key: key);

  @override
  _IslamicStudiesPlansListScreenState createState() =>
      _IslamicStudiesPlansListScreenState();
}

class _IslamicStudiesPlansListScreenState
    extends State<IslamicStudiesPlansListScreen> {
  bool _isLoading = true;
  List<IslamicStudiesModel> _islamicPlans = [];
  List<StudentModel> _students = [];
  String? _filterSubject;
  String? _filterMonth;

  // قائمة بالمواد الشرعية للتصفية
  final List<String> _subjects = [
    'القرآن الكريم',
    'التوحيد',
    'الفقه',
    'الحديث',
    'السيرة النبوية',
    'الآداب الإسلامية',
    'التجويد',
    'العقيدة',
  ];

  // قائمة بالأشهر للتصفية
  final List<String> _months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await planController.getPlans(widget.halaga.halagaID!);
      await studentController.getStudents(widget.halaga.halagaID!);

      setState(() {
        _islamicPlans = planController.islamicStudyPlans;
        _students = studentController.students;
      });
    } catch (e) {
      _showErrorSnackBar('حدث خطأ في تحميل الخطط: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    try {
      await planController.getPlans(widget.halaga.halagaID!);
      setState(() {
        _islamicPlans = planController.islamicStudyPlans;
      });
    } catch (e) {
      _showErrorSnackBar('حدث خطأ في تحديث الخطط: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  List<IslamicStudiesModel> get _filteredPlans {
    return _islamicPlans.where((plan) {
      bool matchesSubject =
          _filterSubject == null || plan.subject == _filterSubject;
      bool matchesMonth =
          _filterMonth == null || plan.planMonth == _filterMonth;
      return matchesSubject && matchesMonth;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'خطط العلوم الشرعية - ${widget.halaga.Name ?? ""}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
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
          : Column(
              children: [
                _buildFilterSection(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    child: _filteredPlans.isEmpty
                        ? _buildEmptyState()
                        : _buildPlansList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تصفية الخطط',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  hint: 'المادة',
                  value: _filterSubject,
                  items: _subjects,
                  onChanged: (value) {
                    setState(() => _filterSubject = value);
                  },
                  icon: Icons.book,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  hint: 'الشهر',
                  value: _filterMonth,
                  items: _months,
                  onChanged: (value) {
                    setState(() => _filterMonth = value);
                  },
                  icon: Icons.calendar_month,
                ),
              ),
            ],
          ),
          if (_filterSubject != null || _filterMonth != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _filterSubject = null;
                        _filterMonth = null;
                      });
                    },
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('مسح التصفية'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(hint, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
          value: value,
          icon: const Icon(Icons.arrow_drop_down),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPlansList() {
    return ListView.builder(
      itemCount: _filteredPlans.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final plan = _filteredPlans[index];
        return _buildPlanCard(plan);
      },
    );
  }

  Widget _buildPlanCard(IslamicStudiesModel plan) {
    // حساب معدل التنفيذ بناءً على محتوى المخطط والمنفذ
    final double executionRate = _calculateExecutionRate(plan);
    final String executionRateText = (executionRate * 100).toStringAsFixed(0);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس البطاقة - معلومات الحلقة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.group,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'خطة الحلقة بأكملها',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildSyncStatus(plan.isSync),
              ],
            ),
          ),

          // قسم الشهر
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade100),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'شهر: ${plan.planMonth ?? "غير محدد"}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
          ),

          // محتوى البطاقة
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // قسم المخطط
                _buildSectionHeader('المخطط', Colors.green),
                const SizedBox(height: 8),
                _buildInfoRow('المادة', plan.subject ?? 'غير محدد'),
                _buildInfoRow('المحتوى', plan.plannedContent ?? 'غير محدد'),

                const SizedBox(height: 16),

                // قسم المنفذ
                _buildSectionHeader('المنفذ', Colors.orange),
                const SizedBox(height: 8),
                _buildInfoRow(
                    'المحتوى المنفذ', plan.executedContent ?? 'غير محدد'),
                _buildInfoRow('معدل التنفيذ', '$executionRateText%'),

                // مؤشر التقدم
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: executionRate,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(executionRate),
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),

          // أزرار الإجراءات
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _editPlan(plan),
                  icon: const Icon(Icons.edit),
                  label: const Text('تعديل'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showDeleteConfirmationDialog(plan),
                  icon: const Icon(Icons.delete),
                  label: const Text('حذف'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                  title == 'المخطط'
                      ? Icons.check_circle
                      : Icons.assignment_turned_in,
                  color: color,
                  size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(color: color.withOpacity(0.3), thickness: 1),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatus(int? isSync) {
    final synced = isSync == 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: synced ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: synced ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            synced ? Icons.cloud_done : Icons.cloud_off,
            color: synced ? Colors.green : Colors.orange,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            synced ? 'متزامن' : 'غير متزامن',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: synced ? Colors.green.shade800 : Colors.orange.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double value) {
    if (value < 0.3) return Colors.red;
    if (value < 0.7) return Colors.orange;
    return Colors.green;
  }

  // حساب معدل التنفيذ بناءً على محتوى المخطط والمنفذ
  double _calculateExecutionRate(IslamicStudiesModel plan) {
    // إذا لم يكن هناك محتوى مخطط أو منفذ، فالمعدل صفر
    if (plan.plannedContent == null || plan.plannedContent!.isEmpty) {
      return 0.0;
    }

    if (plan.executedContent == null || plan.executedContent!.isEmpty) {
      return 0.0;
    }

    // حساب بسيط للمعدل بناءً على طول المحتوى المنفذ مقارنة بالمخطط
    // يمكن تحسين هذه الطريقة بناءً على متطلبات العمل الفعلية
    double plannedLength = plan.plannedContent!.length.toDouble();
    double executedLength = plan.executedContent!.length.toDouble();

    // لا نريد أن يتجاوز المعدل 100%
    double rate = (executedLength / plannedLength).clamp(0.0, 1.0);

    return rate;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _filterSubject != null || _filterMonth != null
                ? 'لا توجد خطط تطابق معايير التصفية'
                : 'لا توجد خطط علوم شرعية متاحة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (_filterSubject == null && _filterMonth == null)
            ElevatedButton.icon(
              onPressed: () => _navigateToAddPlan(context),
              icon: const Icon(Icons.add),
              label: const Text('إضافة خطة جديدة'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToAddPlan(BuildContext context) {
    // التنقل إلى شاشة إضافة خطة جديدة
    // نستخدم طالب افتراضي لأن الخطة للحلقة بأكملها
    // StudentModel dummyStudent = StudentModel(
    //     firstName: "الحلقة", lastName: "بأكملها", studentID: -1 as String);

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => EditHalagaPlanScreen(
          halaga: widget.halaga,
          planType: "islamic",
          student: StudentModel(),
          plan: null,
        ),
      ),
    )
        .then((result) {
      if (result == true) {
        _loadData(); // تحديث القوائم بعد الإضافة
      }
    });
  }

  void _editPlan(IslamicStudiesModel plan) {
    // الانتقال إلى شاشة تعديل الخطة
    // نستخدم طالب افتراضي لأن الخطة للحلقة بأكملها
    // StudentModel dummyStudent = StudentModel(
    //     firstName: "الحلقة", lastName: "بأكملها", studentID: -1 as String);

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => EditHalagaPlanScreen(
          halaga: widget.halaga,
          plan: plan,
          planType: "islamic",
          student: StudentModel(),
        ),
      ),
    )
        .then((result) {
      if (result == true) {
        _loadData(); // تحديث القوائم بعد التعديل
      }
    });
  }

  Future<void> _showDeleteConfirmationDialog(IslamicStudiesModel plan) async {
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
            child: const Text('إلغاء'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade800,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await planController.deletePlan(
                  plan.islamicStudiesID!,
                  "IslamicStudies",
                  "IslamicStudiesID",
                );
                Navigator.of(context).pop(true);
              } catch (e) {
                _showErrorSnackBar('حدث خطأ أثناء الحذف: $e');
                Navigator.of(context).pop(false);
              }
            },
            child: const Text('حذف'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      _showSuccessSnackBar('تم حذف الخطة بنجاح');
      await _loadData(); // تحديث القوائم بعد الحذف
    }
  }
}
