import 'package:flutter/material.dart';
import 'package:al_furqan/controllers/users_controller.dart';
import '../../controllers/school_controller.dart';
import '../../models/schools_model.dart';

class RequestsList extends StatefulWidget {
  const RequestsList({super.key});

  @override
  _RequestsListState createState() => _RequestsListState();
}

class _RequestsListState extends State<RequestsList> {
  // List to hold dropdown menu items for schools
  List<DropdownMenuItem<int>> _schoolItems = [];

  @override
  void initState() {
    // Initialize state and refresh data
    super.initState();
    _refreshData();
  }

  // Function to refresh data from controllers
  void _refreshData() async {
    await userController.getDataRequests();
    await schoolController.getData();
    setState(() {
      _schoolItems = schoolController.schools
          .map((school) => DropdownMenuItem<int>(
                value: school.schoolID,
                child: Text(school.school_name!),
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'طلبات التفعيل',
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
      body: userController.requests.isEmpty
          ? _buildEmptyState(context)
          : RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 300));
                await Future.delayed(Duration(milliseconds: 300));
                _refreshData();
              },
              child: ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: userController.requests.length,
                itemBuilder: (context, index) {
                  // Determine role name based on roleID
                  String? roleName;
                  Color roleColor;
                  IconData roleIcon;

                  switch (userController.requests[index].roleID) {
                    case 0:
                      roleName = 'مشرف';
                      roleColor = Colors.purple;
                      roleIcon = Icons.admin_panel_settings;
                      break;
                    case 1:
                      roleName = 'مدير';
                      roleColor = Colors.blue;
                      roleIcon = Icons.school;
                      break;
                    case 2:
                      roleName = 'معلم';
                      roleColor = Colors.green;
                      roleIcon = Icons.person;
                      break;
                    case 3:
                      roleName = 'ولي أمر';
                      roleColor = Colors.green;
                      roleIcon = Icons.person;
                      break;
                    default:
                      roleName = 'غير محدد';
                      roleColor = Colors.grey;
                      roleIcon = Icons.person_outline;
                  }

                  // Find the school associated with the request
                  final school = schoolController.schools.firstWhere(
                      (school) =>
                          school.schoolID ==
                          userController.requests[index].schoolID,
                      orElse: () => SchoolModel(school_name: 'المكتب'));

                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => showDialogDetailsRequest(context, index),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: roleColor.withOpacity(0.2),
                                  child: Icon(roleIcon,
                                      color: roleColor, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${userController.requests[index].first_name!} ${userController.requests[index].middle_name!} ${userController.requests[index].last_name!}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.phone,
                                              size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${userController.requests[index].phone_number}',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton(
                                  icon: Icon(Icons.more_vert),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: Row(
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: Colors.green),
                                          const SizedBox(width: 8),
                                          Text('قبول الطلب'),
                                        ],
                                      ),
                                      onTap: () => Future.delayed(
                                        Duration.zero,
                                        () => acceptRequest(index, context),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      child: Row(
                                        children: [
                                          Icon(Icons.info, color: Colors.blue),
                                          const SizedBox(width: 8),
                                          Text('تفاصيل الطلب'),
                                        ],
                                      ),
                                      onTap: () => Future.delayed(
                                        Duration.zero,
                                        () => showDialogDetailsRequest(
                                            context, index),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          const SizedBox(width: 8),
                                          Text('حذف الطلب'),
                                        ],
                                      ),
                                      onTap: () => Future.delayed(
                                        Duration.zero,
                                        () => showDialogDeleteRequest(
                                            context, index),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoChip(
                                  label: roleName,
                                  icon: roleIcon,
                                  color: roleColor,
                                ),
                                _buildInfoChip(
                                  label: school.school_name!,
                                  icon: Icons.location_on,
                                  color: Colors.orange,
                                ),
                                _buildInfoChip(
                                  label: 'طلب تفعيل',
                                  icon: Icons.pending_actions,
                                  color: Colors.amber,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionButton(
                                  label: 'قبول',
                                  icon: Icons.check_circle,
                                  color: Colors.green,
                                  onPressed: () =>
                                      acceptRequest(index, context),
                                ),
                                _buildActionButton(
                                  label: 'حذف',
                                  icon: Icons.delete,
                                  color: Colors.red,
                                  onPressed: () =>
                                      showDialogDeleteRequest(context, index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد طلبات حالياً',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر طلبات التفعيل الجديدة هنا',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: Icon(Icons.refresh),
            label: Text('تحديث'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Function to accept a request and refresh data
  void acceptRequest(int index, BuildContext context) async {
    await userController.activateUser(userController.requests[index].user_id!);
    _refreshData();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("تم تنشيط الحساب"),
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // Function to show a dialog for deleting a request
  Future<dynamic> showDialogDeleteRequest(BuildContext context, int index) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.delete_forever, color: Colors.red),
              const SizedBox(width: 8),
              Text('تأكيد الحذف',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'هل أنت متأكد من حذف هذا الطلب؟',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'سيتم حذف طلب المستخدم ${userController.requests[index].first_name} ${userController.requests[index].last_name} نهائياً.',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.cancel, color: Colors.grey),
              label: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text('حذف', style: TextStyle(color: Colors.red)),
              onPressed: () {
                userController
                    .deleteRequest(userController.requests[index].user_id!);
                _refreshData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("تم حذف الطلب"),
                    duration: const Duration(seconds: 1),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to show a dialog with request details
  Future<dynamic> showDialogDetailsRequest(BuildContext context, int index) {
    final request = userController.requests[index];
    final school = schoolController.schools.firstWhere(
        (school) => school.schoolID == request.schoolID,
        orElse: () => SchoolModel(school_name: 'المكتب'));

    // Determine role name based on roleID
    String roleName;
    switch (request.roleID) {
      case 0:
        roleName = 'مشرف';
        break;
      case 1:
        roleName = 'مدير';
        break;
      case 2:
        roleName = 'معلم';
        break;
      case 3:
        roleName = 'ولي أمر';
      default:
        roleName = 'غير محدد';
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text('تفاصيل الطلب',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem(
                    context,
                    'الاسم الكامل',
                    '${request.first_name} ${request.middle_name} ${request.last_name}',
                    Icons.person),
                Divider(),
                _buildDetailItem(context, 'رقم الجوال',
                    '${request.phone_number}', Icons.phone),
                Divider(),
                _buildDetailItem(context, 'البريد الإلكتروني',
                    '${request.email}', Icons.email),
                Divider(),
                _buildDetailItem(context, 'المدرسة', '${school.school_name}',
                    Icons.location_on),
                Divider(),
                _buildDetailItem(context, 'الدور', roleName, Icons.badge),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton.icon(
              icon: Icon(Icons.check_circle, color: Colors.green),
              label: Text('قبول'),
              onPressed: () {
                Navigator.of(context).pop();
                acceptRequest(index, context);
              },
            ),
            TextButton.icon(
              icon: Icon(Icons.delete, color: Colors.red),
              label: Text('حذف'),
              onPressed: () {
                Navigator.of(context).pop();
                showDialogDeleteRequest(context, index);
              },
            ),
            TextButton.icon(
              icon: Icon(Icons.close),
              label: Text('إغلاق'),
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
  Widget _buildDetailItem(
      BuildContext context, String label, String value, IconData icon) {
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
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
