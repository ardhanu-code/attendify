import 'package:attendify/const/app_color.dart';
import 'package:attendify/models/login_model.dart';
import 'package:attendify/pages/auth/forgot_password_page.dart';
import 'package:attendify/pages/auth/register_page.dart';
import 'package:attendify/pages/home/home_page.dart';
import 'package:attendify/preferences/preferences.dart';
import 'package:attendify/services/auth_services.dart';
import 'package:attendify/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isVisiblePassword = true;

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColor.primary),
      ),
    );

    try {
      print('DEBUG: Starting login process...');
      print('DEBUG: Email: ${_emailController.text.trim()}');
      print('DEBUG: Password length: ${_passwordController.text.length}');

      // Clear any existing session before login
      await Preferences.clearSession();
      print('DEBUG: Cleared existing session');

      UserLogin result;

      try {
        // Try login without token first
        print('DEBUG: Attempting login without token...');
        result = await loginUserWithoutToken(
          _emailController.text.trim(),
          _passwordController.text,
        );
        print('DEBUG: Login without token successful');
      } catch (e) {
        print('DEBUG: Login without token failed: $e');
        print('DEBUG: Attempting login with empty token...');

        // Try with empty token as fallback
        result = await loginUser(
          _emailController.text.trim(),
          _passwordController.text,
          '',
        );
        print('DEBUG: Login with empty token successful');
      }

      print('DEBUG: Login result: $result');
      await Preferences.saveLoginSession();

      Navigator.of(context).pop(); // Close the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    } catch (e) {
      print('DEBUG: Login error: $e');
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.text,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/logo/attendify_black.png',
                              height: 150,
                              width: 150,
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Login into your account',
                              style: GoogleFonts.lexend(fontSize: 14),
                            ),
                          ),
                          SizedBox(height: 28),
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
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(Icons.email_outlined),
                                hintText: 'Email',
                                hintStyle: GoogleFonts.lexend(fontSize: 14),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
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
                              controller: _passwordController,
                              obscureText: isVisiblePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(Icons.lock_outlined),
                                hintText: 'Password',
                                hintStyle: GoogleFonts.lexend(fontSize: 14),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isVisiblePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isVisiblePassword = !isVisiblePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          // Lupa password (placeholder)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgotPasswordPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Lupa password?',
                                style: GoogleFonts.lexend(
                                  fontSize: 13,
                                  color: AppColor.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 34),
                          CustomButton(
                            onPressed: _handleLogin,
                            text: 'LOGIN',
                            textStyle: GoogleFonts.lexend(),
                            backgroundColor: AppColor.primary,
                            height: 54,
                          ),
                          SizedBox(height: 34),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 1.2,
                                  color: Colors.grey.shade300,
                                  endIndent: 12,
                                ),
                              ),
                              Text(
                                'Or sign in with',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 1.2,
                                  color: Colors.grey.shade300,
                                  indent: 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Google login button
                              InkWell(
                                onTap: () {
                                  // TODO: Implement Google login
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/icons/google.png',
                                        height: 24,
                                        width: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Google',
                                        style: GoogleFonts.lexend(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              // WhatsApp login button
                              InkWell(
                                onTap: () {
                                  // TODO: Implement WhatsApp login
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/icons/whatsapp.png',
                                        height: 24,
                                        width: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'WhatsApp',
                                        style: GoogleFonts.lexend(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(top: 26.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have account? ",
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RegisterPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign up',
                                    style: GoogleFonts.lexend(
                                      fontSize: 14,
                                      color: AppColor.primary,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
