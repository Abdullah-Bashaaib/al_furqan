import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final String? selectedRole;
  final int? selectedSchoolId;
  final List<DropdownMenuItem<int>> schoolItems;
  final Function(String?, int?) onApply;

  const FilterDialog({super.key, 
    required this.selectedRole,
    required this.selectedSchoolId,
    required this.schoolItems,
    required this.onApply,
  });

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? tempSelectedRole;
  int? tempSelectedSchoolId;

  @override
  void initState() {
    super.initState();
    tempSelectedRole = widget.selectedRole;
    tempSelectedSchoolId = widget.selectedSchoolId;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.filter_list, color: primaryColor, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تصفية المستخدمين',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 4),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, color: Colors.grey.shade600, size: 20),
                  ),
                ),
              ],
            ),
            Divider(height: 24, thickness: 1),
            
            // Role Dropdown
            Text(
              'الدور',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            _buildRoleDropdown(primaryColor),
            SizedBox(height: 20),
            
            // School Dropdown
            Text(
              'المدرسة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            _buildSchoolDropdown(primaryColor),
            SizedBox(height: 24),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(
                  label: 'إزالة التصفية',
                  icon: Icons.clear_all,
                  color: Colors.red,
                  onPressed: () {
                    widget.onApply(null, null);
                    Navigator.of(context).pop();
                  },
                ),
                _buildActionButton(
                  label: 'تطبيق',
                  icon: Icons.check,
                  color: primaryColor,
                  onPressed: () {
                    widget.onApply(tempSelectedRole, tempSelectedSchoolId);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRoleDropdown(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonFormField<String>(
        value: tempSelectedRole,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.person, color: primaryColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        style: TextStyle(fontSize: 16, color: Colors.black87),
        icon: Icon(Icons.arrow_drop_down, color: primaryColor),
        isExpanded: true,
        dropdownColor: Colors.white,
        items: <String>['مشرف', 'مدير', 'معلم'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            tempSelectedRole = newValue;
          });
        },
      ),
    );
  }
  
  Widget _buildSchoolDropdown(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonFormField<int>(
        value: tempSelectedSchoolId,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.school, color: primaryColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        style: TextStyle(fontSize: 16, color: Colors.black87),
        icon: Icon(Icons.arrow_drop_down, color: primaryColor),
        isExpanded: true,
        dropdownColor: Colors.white,
        items: widget.schoolItems,
        onChanged: (newValue) {
          setState(() {
            tempSelectedSchoolId = newValue;
          });
        },
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
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }
}
