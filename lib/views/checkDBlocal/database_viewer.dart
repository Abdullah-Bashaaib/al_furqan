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
      final result = await db.delete(
        selectedTable!,
        where: '$primaryKeyColumn = ?',
        whereArgs: [primaryKeyValue],
      );

      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف الصف بنجاح')),
        );
        // إعادة تحميل بيانات الجدول
        _loadTableData(selectedTable!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في حذف الصف')),
        );
      }
    } catch (e) {
      debugPrint('خطأ في حذف الصف: $e');
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
      final result = await db.delete(selectedTable!);

      if (result >= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف جميع بيانات الجدول بنجاح')),
        );
        // إعادة تحميل بيانات الجدول (ستكون فارغة الآن)
        _loadTableData(selectedTable!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في حذف بيانات الجدول')),
        );
      }
    } catch (e) {
      debugPrint('خطأ في حذف بيانات الجدول: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في حذف بيانات الجدول: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          selectedTable != null
              ? 'جدول: $selectedTable'
              : 'عارض قاعدة البيانات',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: selectedTable != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    selectedTable = null;
                    tableData = [];
                    columns = [];
                  });
                },
              )
            : null,
        actions: selectedTable != null
            ? [
                // زر حذف جميع بيانات الجدول
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                  tooltip: 'حذف جميع البيانات',
                  onPressed: _deleteAllTableData,
                ),
              ]
            : null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
            Icon(Icons.storage_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد جداول في قاعدة البيانات',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.table_chart, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'جداول قاعدة البيانات (${tables.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // قائمة الجداول
          Expanded(
            child: ListView.builder(
              itemCount: tables.length,
              itemBuilder: (context, index) {
                final tableName = tables[index];
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.table_chart,
                            color: Theme.of(context).primaryColor),
                      ),
                      title: Text(
                        tableName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'انقر لعرض بيانات الجدول',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios,
                          color: Theme.of(context).primaryColor),
                      onTap: () => _loadTableData(tableName),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableDataView() {
    if (tableData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.table_rows_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد بيانات في هذا الجدول',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      );
    }

    // إضافة عمود إضافي للإجراءات (الحذف)
    List<DataColumn> dataColumns = [
      ...columns.map(
        (column) => DataColumn(
          label: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(
              column,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
      DataColumn(
        label: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            'الإجراءات',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    ];

    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize:
            MainAxisSize.min, // استخدام الحد الأدنى من المساحة الرأسية
        children: [
          // معلومات الجدول
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'عدد الصفوف: ${tableData.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'عدد الأعمدة: ${columns.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // جدول البيانات
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: 80,
                  columnSpacing: 20,
                  horizontalMargin: 16,
                  dividerThickness: 1,
                  border: TableBorder(
                    horizontalInside:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  columns: dataColumns,
                  rows: tableData.map((row) {
                    return DataRow(
                      color: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          // تلوين الصفوف بالتناوب
                          return tableData.indexOf(row) % 2 == 0
                              ? Colors.white
                              : Colors.grey.shade50;
                        },
                      ),
                      cells: [
                        ...columns.map((column) {
                          final value = row[column];
                          // تنسيق خاص للقيم المختلفة
                          Widget cellContent;
                          if (value == null) {
                            cellContent = Text(
                              'null',
                              style: TextStyle(
                                  color: Colors.grey[400],
                                  fontStyle: FontStyle.italic),
                            );
                          } else if (column.toLowerCase().contains('id')) {
                            // تنسيق خاص للمعرفات
                            cellContent = Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                value.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            );
                          } else {
                            // تنسيق عام للقيم الأخرى
                            cellContent = Text(
                              value.toString(),
                              style: const TextStyle(fontSize: 14),
                            );
                          }

                          return DataCell(cellContent);
                        }),
                        // خلية الإجراءات (زر الحذف)
                        DataCell(
                          ElevatedButton.icon(
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('حذف'),
                            onPressed: () => _deleteRow(row),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              foregroundColor: Colors.red,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
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
      ),
    );
  }
}
