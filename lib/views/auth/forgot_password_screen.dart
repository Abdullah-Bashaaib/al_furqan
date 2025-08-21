import 'package:al_furqan/services/verification_service.dart';
import 'package:al_furqan/views/auth/change_password.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isCodeSent = false;
  bool _isLoading = false;

  // Timer for verification code countdown
  Timer? _timer;
  int _countdownSeconds = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendVerificationRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        debugPrint(_phoneController.text);
        debugPrint('=========================================');
        await verificationService
            .verificationRequest(int.parse(_phoneController.text));

        setState(() {
          _isCodeSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إرسال رمز التحقق بنجاح'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إرسال رمز التحقق: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // جلب الكود من Firestore ومقارنته
        final code = _codeController.text.trim();

        final snapshot = await FirebaseFirestore.instance
            .collection('verification_codes')
            .where('code', isEqualTo: code)
            .where('used', isEqualTo: 0) // تأكد أنه لم يُستخدم
            .get();

        if (snapshot.docs.isNotEmpty) {
          // ✅ الكود صحيح ولم يُستخدم
          final docId = snapshot.docs.first.id;

          // يمكنك هنا تحديث الحقل لجعل الكود مستعملاً
          await FirebaseFirestore.instance
              .collection('verification_codes')
              .doc(docId)
              .update({'used': 1});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('رمز التحقق صحيح، يمكنك تغيير كلمة المرور الآن'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // ✅ الانتقال لصفحة تغيير كلمة المرور
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangePasswordScreen(), // ضع صفحتك هنا
            ),
          );
        } else {
          // ❌ الرمز غير صحيح أو مستعمل
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('رمز التحقق غير صحيح أو تم استخدامه'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startCountdown() {
    _countdownSeconds = 60; // 1 minute countdown
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('نسيت كلمة المرور'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header icon and text
                  Center(
                    child: Icon(
                      Icons.lock_reset,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'استعادة كلمة المرور',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'سيتم إرسال رمز تحقق إلى رقم هاتفك',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 32),

                  // Phone number field
                  TextFormField(
                    controller: _phoneController,
                    enabled: !_isCodeSent || _countdownSeconds == 0,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      hintText: 'أدخل رقم الهاتف',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال رقم الهاتف';
                      }
                      if (int.tryParse(value) == null) {
                        return 'الرجاء إدخال رقم هاتف صحيح';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Verification code field (only shown after code is sent)
                  if (_isCodeSent) ...[
                    TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: 'رمز التحقق',
                        hintText: 'أدخل رمز التحقق',
                        prefixIcon: Icon(Icons.pin),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال رمز التحقق';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),

                    // Resend code option with countdown
                    if (_countdownSeconds > 0)
                      Center(
                        child: Text(
                          'يمكنك طلب رمز جديد بعد $_countdownSeconds ثانية',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: () {
                          _sendVerificationRequest();
                          _startCountdown();
                        },
                        child: Text('إعادة إرسال رمز التحقق'),
                      ),
                  ],

                  SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    height: 50,
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () {
                              if (_isCodeSent) {
                                _verifyCode();
                              } else {
                                _sendVerificationRequest();
                                _startCountdown();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              _isCodeSent
                                  ? 'تحقق من الرمز'
                                  : 'إرسال رمز التحقق',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
