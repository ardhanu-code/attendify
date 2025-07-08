import 'package:attendify/pages/auth/login_page.dart';
import 'package:attendify/pages/auth/register_page.dart';
import 'package:flutter/material.dart';
import 'package:attendify/pages/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
