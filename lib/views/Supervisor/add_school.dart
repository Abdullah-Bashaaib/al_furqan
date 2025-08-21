import 'package:al_furqan/controllers/school_controller.dart';
import 'package:flutter/material.dart';
import '../../models/schools_model.dart';

class AddSchool extends StatefulWidget {
  const AddSchool({super.key});

  @override
  State<AddSchool> createState() => _AddSchoolState();
}

class _AddSchoolState extends State<AddSchool> {
  final _schoolNameController = TextEditingController();
  final _schoolLocationController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  Future<void> _loadSchools() async {
    await schoolController.getData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة مدرسة جديدة',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'معلومات المدرسة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                // Form section with card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _schoolNameController,
                            decoration: InputDecoration(
                              labelText: 'اسم المدرسة',
                              hintText: 'أدخل اسم المدرسة',
                              prefixIcon: Icon(Icons.school, color: primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: primaryColor, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء كتابة اسم المدرسة';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _schoolLocationController,
                            decoration: InputDecoration(
                              labelText: 'موقع المدرسة',
                              hintText: 'أدخل موقع المدرسة',
                              prefixIcon:
                                  Icon(Icons.location_on, color: primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: primaryColor, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء كتابة موقع المدرسة';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                await schoolController.addSchool(
                                    SchoolModel(
                                      school_name: _schoolNameController.text,
                                      school_location:
                                          _schoolLocationController.text,
                                    ),
                                    1);
                                await _loadSchools();
                                _schoolNameController.clear();
                                _schoolLocationController.clear();

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('تمت إضافة المدرسة بنجاح'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add,color: Colors.white,),
                                SizedBox(width: 8),
                                Text(
                                  'إضافة مدرسة',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Schools list header
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'قائمة المدارس',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        '${schoolController.schools.length} مدرسة',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Schools list
                Container(
                  height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: schoolController.schools.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'لا توجد مدارس مضافة',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: schoolController.schools.length,
                            itemBuilder: (context, index) {
                              final school = schoolController.schools[index];
                              return Card(
                                color: Colors.white,
                                margin: EdgeInsets.all(8),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  leading: CircleAvatar(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    child: Text("${index + 1}"),
                                  ),
                                  title: Text(
                                    school.school_name!,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on,
                                            size: 16, color: Colors.grey[600]),
                                        SizedBox(width: 4),
                                        Text(school.school_location!),
                                      ],
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      bool confirmDelete = await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(
                                            'تأكيد الحذف',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          content: Text(
                                            'هل أنت متأكد أنك تريد حذف مدرسة ${school.school_name}؟',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(false),
                                              child: Text(
                                                'إلغاء',
                                                style: TextStyle(
                                                    color: Colors.grey[700]),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: Text('حذف'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmDelete) {
                                        await schoolController
                                            .deleteSchool(school.schoolID!);
                                        await _loadSchools();

                                        // Show deletion message
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('تم حذف المدرسة بنجاح'),
                                            backgroundColor: Colors.red,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                      }
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
          ),
        ),
      ),
    );
  }
}
