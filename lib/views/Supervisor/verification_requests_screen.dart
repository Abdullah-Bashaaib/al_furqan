import 'package:al_furqan/models/verification_code_model.dart';
import 'package:al_furqan/services/verification_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class VerificationRequestsScreen extends StatefulWidget {
  const VerificationRequestsScreen({super.key});

  @override
  _VerificationRequestsScreenState createState() =>
      _VerificationRequestsScreenState();
}

class _VerificationRequestsScreenState
    extends State<VerificationRequestsScreen> {
  List<VerificationCode> _pendingRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = await verificationService.getPendingRequests();
      setState(() {
        _pendingRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading pending requests: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في تحميل الطلبات: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendVerificationCode(VerificationCode request) async {
    try {
      if (request.phoneNumber.isEmpty) {
        throw Exception('رقم الطلب غير صالح');
      }

      // Generate and save the verification code
      final verificationCode =
          await verificationService.generateAndSaveCode(request);

      // Clean the phone number
      final cleanUserPhone =
          request.phoneNumber.toString().replaceAll(RegExp(r'[^0-9]'), '');

      // Prepare WhatsApp message
      final message = 'رمز التحقق لتغيير كلمة المرور هو: $verificationCode';
      final whatsappUrl =
          "https://wa.me/$cleanUserPhone?text=${Uri.encodeComponent(message)}";

      // Open WhatsApp
      if (await canLaunch(whatsappUrl)) {
        await launch(whatsappUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء الرمز وإرساله عبر واتساب'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        throw 'لا يمكن فتح واتساب';
      }
    } catch (e) {
      debugPrint('Error sending verification code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في إرسال الرمز: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('طلبات التحقق'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPendingRequests,
            tooltip: 'تحديث القائمة',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pendingRequests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mark_email_unread_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد طلبات تحقق',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'ستظهر طلبات التحقق هنا عند ورودها',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadPendingRequests,
                        icon: Icon(Icons.refresh),
                        label: Text('تحديث'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    itemCount: _pendingRequests.length,
                    itemBuilder: (context, index) {
                      final request = _pendingRequests[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.phone_android,
                                      color: Theme.of(context).primaryColor),
                                  SizedBox(width: 8),
                                  Text(
                                    'رقم الهاتف:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      request.phoneNumber,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 20, color: Colors.grey[600]),
                                  SizedBox(width: 8),
                                  Text(
                                    'تاريخ الطلب:',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    DateFormat('yyyy/MM/dd HH:mm')
                                        .format(request.createdAt),
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _sendVerificationCode(request),
                                  icon: Icon(Icons.send),
                                  label: Text('إرسال رمز التحقق'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
