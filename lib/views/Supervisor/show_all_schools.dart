import 'package:al_furqan/controllers/StudentController.dart';
import 'package:al_furqan/controllers/TeacherController.dart';
import 'package:al_furqan/controllers/school_controller.dart';
import 'package:al_furqan/models/schools_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowAllSchools extends StatefulWidget {
  const ShowAllSchools({super.key});

  @override
  State<ShowAllSchools> createState() => _ShowAllSchoolsState();
}

class _ShowAllSchoolsState extends State<ShowAllSchools> {
  String _searchQuery = '';
  bool _isLoading = false;

  List<SchoolModel> _filterSchools() {
    if (_searchQuery.isEmpty) return schoolController.schools;
    return schoolController.schools.where((school) {
      final fullName = '${school.school_name ?? ''}'.toLowerCase();
      return fullName.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Function to fetch teachers and schools data
  void _refreshData() async {
    setState(() => _isLoading = true);
    try {
      await schoolController.getData();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب البيانات: $e')),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final filteredSchools = _filterSchools();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المدارس',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 2,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'تحديث',
            onPressed: () {
              _refreshData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم تحديث البيانات'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              keyboardType: TextInputType.name,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                labelText: 'بحث عن مدرسة',
                hintText: 'اكتب اسم المدرسة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : filteredSchools.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await Future.delayed(
                              const Duration(milliseconds: 300));
                          _refreshData();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredSchools.length,
                          itemBuilder: (context, index) {
                            final school = filteredSchools[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      primaryColor.withOpacity(0.2),
                                  child:
                                      Icon(Icons.school, color: primaryColor),
                                ),
                                title: Text(
                                  school.school_name!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            school.school_location ??
                                                'لا يوجد موقع',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  color: primaryColor,
                                  onPressed: () {
                                    // يمكن إضافة عرض تفاصيل المدرسة هنا
                                    _showSchoolDetails(context, school);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEditSchoolDialog(context);
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget to display when no schools are found
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
            'لا يوجد مدارس حالياً',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'لم يتم العثور على أي مدرسة'
                : 'لم يتم العثور على نتائج لـ "$_searchQuery"',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('تحديث'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show school details in a dialog
  void _showSchoolDetails(BuildContext context, SchoolModel school) async {
    List _numberStudentOfSchool =
        await studentController.getSchoolStudents(school.schoolID!);
    await teacherController.getTeachersBySchoolID(school.schoolID!);
    List _teacher = await teacherController.teachers;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.school, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'تفاصيل المدرسة',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem(
                    'اسم المدرسة', school.school_name ?? '-', Icons.school),
                const Divider(),
                _buildDetailItem('الموقع', school.school_location ?? 'غير محدد',
                    Icons.location_on),
                if (school.schoolID != null) ...[
                  const Divider(),
                  _buildDetailItem('عدد المعلمين', _teacher.length.toString(),
                      Icons.numbers_rounded),
                  const Divider(),
                  _buildDetailItem('عدد الطلاب',
                      _numberStudentOfSchool.length.toString(), Icons.numbers),
                ],
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.edit, color: Colors.blue),
              label: const Text('تعديل'),
              onPressed: () {
                Navigator.of(context).pop();
                _showAddEditSchoolDialog(context, school: school);
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.close),
              label: const Text('إغلاق'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Helper method to build detail items in the dialog
  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // دالة لعرض مربع حوار إضافة أو تعديل مدرسة
  void _showAddEditSchoolDialog(BuildContext context, {SchoolModel? school}) {
    final bool isEditing = school != null;
    final TextEditingController nameController =
        TextEditingController(text: isEditing ? school.school_name : '');
    final TextEditingController locationController =
        TextEditingController(text: isEditing ? school.school_location : '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isEditing ? Icons.edit : Icons.add_circle,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                isEditing ? 'تعديل المدرسة' : 'إضافة مدرسة جديدة',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'اسم المدرسة',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.school),
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال اسم المدرسة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: 'موقع المدرسة',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال موقع المدرسة';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton.icon(
              icon: Icon(
                isEditing ? Icons.save : Icons.add,
                color: Colors.green,
              ),
              label: Text(isEditing ? 'حفظ التغييرات' : 'إضافة'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // إنشاء نموذج المدرسة
                  final SchoolModel schoolModel = SchoolModel(
                    schoolID: isEditing ? school.schoolID : null,
                    school_name: nameController.text,
                    school_location: locationController.text,
                  );

                  try {
                    // عرض مؤشر التحميل
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return const AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('جاري الحفظ...'),
                            ],
                          ),
                        );
                      },
                    );

                    // حفظ البيانات
                    if (isEditing) {
                      await schoolController.updateSchool(schoolModel, 1);
                    } else {
                      await schoolController.addSchool(schoolModel, 1);
                    }

                    // إغلاق مؤشر التحميل
                    Navigator.of(context).pop();

                    // إغلاق مربع الحوار
                    Navigator.of(context).pop();

                    // تحديث البيانات
                    _refreshData();

                    // عرض رسالة نجاح
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing
                              ? 'تم تعديل المدرسة بنجاح'
                              : 'تم إضافة المدرسة بنجاح',
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  } catch (e) {
                    // إغلاق مؤشر التحميل إذا كان مفتوحًا
                    Navigator.of(context).pop();

                    // عرض رسالة خطأ
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('حدث خطأ: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
