import 'package:al_furqan/helper/sqldb.dart';
import 'package:flutter/material.dart';

class DatabaseViewerScreen extends StatefulWidget {
  const DatabaseViewerScreen({super.key});

  @override
  State<DatabaseViewerScreen> createState() => _DatabaseViewerScreenState();
}

class _DatabaseViewerScreenState extends State<DatabaseViewerScreen> {
  final SqlDb sqlDb = SqlDb();
  List<String> tables = [];
  bool isLoading = true;
  String? selectedTable;
  List<Map<String, dynamic>> tableData = [];
  List<String> columns = [];

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    setState(() {
      isLoading = true;
    });

    try {
      final db = await sqlDb.database;

      // استعلام لجلب جميع أسماء الجداول من قاعدة البيانات
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'",
      );

      setState(() {
        tables = result.map((row) => row['name'] as String).toList();
        isLoading = false;
      });

      debugPrint("تم تحميل ${tables.length} جدول من قاعدة البيانات");
    } catch (e) {
      debugPrint("خطأ في تحميل الجداول: $e");
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحميل الجداول: $e')),
      );
    }
  }

  Future<void> _loadTableData(String tableName) async {
    setState(() {
      isLoading = true;
      selectedTable = tableName;
    });

    try {
      final db = await sqlDb.database;

      // جلب معلومات عن أعمدة الجدول
      final pragmaResult = await db.rawQuery("PRAGMA table_info($tableName)");
      final columnNames =
          pragmaResult.map((col) => col['name'] as String).toList();

      // جلب جميع البيانات من الجدول
      final data = await db.query(tableName);

      setState(() {
        columns = columnNames;
        tableData = data;
        isLoading = false;
      });

      debugPrint("تم تحميل ${tableData.length} صف من جدول $tableName");
      debugPrint("الأعمدة: $columns");
    } catch (e) {
      debugPrint("خطأ في تحميل بيانات الجدول: $e");
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحميل بيانات الجدول: $e')),
      );
    }
  }

  // دالة لحذف صف من الجدول
  Future<void> _deleteRow(Map<String, dynamic> row) async {
    // التحقق من وجود معرف أساسي للصف
    if (selectedTable == null) return;

    // البحث عن العمود الذي يمكن استخدامه كمعرف أساسي
    String? primaryKeyColumn;
    for (var column in columns) {
      if (column.toLowerCase().contains('id')) {
        primaryKeyColumn = column;
        break;
      }
    }

    if (primaryKeyColumn == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لا يمكن تحديد المعرف الأساسي للصف')),
      );
      return;
    }

    final primaryKeyValue = row[primaryKeyColumn];
    if (primaryKeyValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('قيمة المعرف الأساسي غير موجودة')),
      );
      return;
    }

    // تأكيد الحذف
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('تأكيد الحذف'),
            content: Text(
                'هل أنت متأكد من حذف هذا الصف؟ هذا الإجراء لا يمكن التراجع عنه.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('حذف', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmDelete) return;

    try {
      final db = await sqlDb.database;

      // حذف الصف من قاعدة البيانات
      final deletedCount = await db.delete(
        selectedTable!,
        where: '$primaryKeyColumn = ?',
        whereArgs: [primaryKeyValue],
      );

      if (deletedCount > 0) {
        // إعادة تحميل بيانات الجدول
        await _loadTableData(selectedTable!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف الصف بنجاح')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في حذف الصف')),
        );
      }
    } catch (e) {
      debugPrint("خطأ في حذف الصف: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في حذف الصف: $e')),
      );
    }
  }

  // دالة لحذف جميع بيانات الجدول
  Future<void> _deleteAllTableData() async {
    if (selectedTable == null) return;

    // تأكيد الحذف
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('تأكيد حذف جميع البيانات'),
            content: Text(
                'هل أنت متأكد من حذف جميع بيانات الجدول "$selectedTable"؟ هذا الإجراء لا يمكن التراجع عنه.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('حذف الكل', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmDelete) return;

    try {
      final db = await sqlDb.database;

      // حذف جميع بيانات الجدول
      final deletedCount = await db.delete(selectedTable!);

      // إعادة تحميل بيانات الجدول
      await _loadTableData(selectedTable!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف $deletedCount صف من الجدول')),
      );
    } catch (e) {
      debugPrint("خطأ في حذف بيانات الجدول: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في حذف بيانات الجدول: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedTable != null
            ? 'جدول: $selectedTable'
            : 'عارض قاعدة البيانات'),
        actions: [
          if (selectedTable != null)
            IconButton(
              icon: Icon(Icons.delete_sweep),
              tooltip: 'حذف جميع البيانات',
              onPressed: _deleteAllTableData,
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: () {
              if (selectedTable != null) {
                _loadTableData(selectedTable!);
              } else {
                _loadTables();
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : selectedTable == null
              ? _buildTablesList()
              : _buildTableDataView(),
    );
  }

  Widget _buildTablesList() {
    if (tables.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.table_chart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد جداول في قاعدة البيانات',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final tableName = tables[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(Icons.table_chart),
            title: Text(tableName),
            onTap: () => _loadTableData(tableName),
          ),
        );
      },
    );
  }

  Widget _buildTableDataView() {
    if (columns.isEmpty || tableData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد بيانات في الجدول',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.arrow_back),
              label: Text('العودة إلى قائمة الجداول'),
              onPressed: () {
                setState(() {
                  selectedTable = null;
                });
              },
            ),
          ],
        ),
      );
    }

    // إنشاء أعمدة الجدول
    final dataColumns = [
      ...columns.map((column) => DataColumn(
            label: Text(
              column,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )),
      DataColumn(label: Text('إجراءات')),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.info_outline),
              SizedBox(width: 8),
              Text('عدد الصفوف: ${tableData.length}'),
              SizedBox(width: 16),
              Text('عدد الأعمدة: ${columns.length}'),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: dataColumns,
                rows: tableData.map((row) {
                  return DataRow(
                    cells: [
                      ...columns.map((column) {
                        final value = row[column];
                        return DataCell(Text(value?.toString() ?? 'null'));
                      }),
                      DataCell(
                        ElevatedButton(
                          onPressed: () => _deleteRow(row),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('حذف'),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
