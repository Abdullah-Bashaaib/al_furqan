import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/services/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

class HalqaReportScreen extends StatefulWidget {
  final HalagaModel halqa;

  const HalqaReportScreen({Key? key, required this.halqa}) : super(key: key);

  @override
  _HalqaReportScreenState createState() => _HalqaReportScreenState();
}

class _HalqaReportScreenState extends State<HalqaReportScreen> {
  bool _isLoading = true;
  Uint8List? _pdfBytes;
  HalagaModel? _halqaDetails;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHalqaDetails();
  }

  Future<void> _loadHalqaDetails() async {
    try {
      setState(() => _isLoading = true);

      // Get detailed halqa information
      if (widget.halqa.halagaID != null) {
        final details =
            await halagaController.getHalqaDetails(widget.halqa.halagaID!);
        if (details != null) {
          _halqaDetails = details;
          await _generatePdfReport();
        } else {
          _errorMessage = 'لا يمكن العثور على تفاصيل الحلقة';
        }
      } else {
        _errorMessage = 'معرف الحلقة غير متوفر';
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تحميل البيانات: $e';
      print(_errorMessage);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generatePdfReport() async {
    try {
      // if (_halqaDetails != null) {
      //   final bytes = await pdfService.generateHalqaReport(_halqaDetails!);
      //   setState(() => _pdfBytes = bytes);
      // }
    } catch (e) {
      setState(() => _errorMessage = 'حدث خطأ أثناء إنشاء التقرير: $e');
      print('Error generating PDF: $e');
    }
  }

  Future<void> _refreshReport() async {
    setState(() {
      _isLoading = true;
      _pdfBytes = null;
      _errorMessage = null;
    });
    await _loadHalqaDetails();
  }

  Future<void> _sharePdf() async {
    if (_pdfBytes == null) return;

    try {
      // final fileName = 'تقرير_حلقة_${_halqaDetails?.Name ?? "تقرير"}.pdf';
      // await pdfService.savePdfFile(_pdfBytes!, fileName);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('تم حفظ التقرير بنجاح')),
      // );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء حفظ التقرير: $e')),
      );
    }
  }

  Future<void> _printPdf() async {
    if (_pdfBytes == null) return;

    try {
      // final documentName = 'تقرير_حلقة_${_halqaDetails?.Name ?? "تقرير"}';
      // await pdfService.printPdf(_pdfBytes!, documentName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء طباعة التقرير: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'تقرير حلقة ${widget.halqa.Name}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshReport,
            tooltip: 'تحديث التقرير',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _refreshReport,
                          child: Text('إعادة المحاولة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _pdfBytes == null
                  ? Center(child: Text('لم يتم إنشاء التقرير'))
                  : Column(
                      children: [
                        // PDF Preview
                        Expanded(
                          child: PdfPreview(
                            build: (format) => _pdfBytes!,
                            useActions: false,
                            canChangeOrientation: false,
                            canChangePageFormat: false,
                            pdfFileName: 'تقرير_حلقة_${widget.halqa.Name}.pdf',
                          ),
                        ),

                        // Action buttons
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, -3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _sharePdf,
                                  icon: Icon(Icons.save_alt),
                                  label: Text('حفظ'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _printPdf,
                                  icon: Icon(Icons.print),
                                  label: Text('طباعة'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}
