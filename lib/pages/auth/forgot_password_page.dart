import 'dart:async';

import 'package:attendify/const/app_color.dart';
import 'package:attendify/pages/auth/reset_password_page.dart';
import 'package:attendify/services/forgot_password_services.dart';
import 'package:attendify/widgets/button.dart';
import 'package:attendify/widgets/copy_right.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isRequestingOtp = false;
  int _resendCountdown = 0;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
    _resendCountdown = 60; // 60 seconds countdown
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isRequestingOtp = true;
    });

    try {
      final result = await ForgotPasswordServices.requestOtp(
        _emailController.text.trim(),
      );

      // Start countdown timer
      _startResendCountdown();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  result.message,
                  style: GoogleFonts.lexend(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate to reset password page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(
            email: _emailController.text.trim(),
            popOnSuccess: true,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Gagal mengirim OTP: $e',
                  style: GoogleFonts.lexend(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isRequestingOtp = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.text,
      appBar: AppBar(
        backgroundColor: AppColor.text,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColor.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Lupa Password',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColor.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Image.asset(
                      'assets/logo/attendify_black.png',
                      height: 120,
                      width: 120,
                    ),
                  ),
                  SizedBox(height: 24),

                  Text(
                    'Reset Password',
                    style: GoogleFonts.lexend(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColor.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Masukkan email Anda untuk menerima kode OTP dan reset password',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 32),

                  // Email Input
                  Text(
                    'Email',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan email Anda';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Masukkan email yang valid';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppColor.primary,
                        ),
                        hintText: 'contoh@email.com',
                        hintStyle: GoogleFonts.lexend(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Request OTP Button
                  CustomButton(
                    onPressed: _isRequestingOtp ? null : _requestOtp,
                    text: _isRequestingOtp ? 'Mengirim OTP...' : 'Kirim OTP',
                    minWidth: double.infinity,
                    height: 50,
                    backgroundColor: AppColor.primary,
                    foregroundColor: AppColor.text,
                    borderRadius: BorderRadius.circular(12),
                    icon: _isRequestingOtp
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColor.text,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.send, size: 20),
                  ),
                  SizedBox(height: 16),

                  // Resend OTP Button
                  Center(
                    child: TextButton(
                      onPressed: (_isRequestingOtp || _resendCountdown > 0)
                          ? null
                          : () async {
                              // Request new OTP
                              await _requestOtp();
                            },
                      child: Text(
                        _resendCountdown > 0
                            ? 'Kirim ulang OTP (${_resendCountdown}s)'
                            : 'Kirim ulang OTP',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: _resendCountdown > 0
                              ? Colors.grey
                              : AppColor.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // Tambahkan copyright di bawah konten utama
                  const SizedBox(height: 24),
                  CopyrightText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
