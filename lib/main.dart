import 'package:attendify/const/app_color.dart';
import 'package:attendify/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() {
  final String appId = '9955bcc4-5061-4e60-b304-dbaca583d39f';
  WidgetsFlutterBinding.ensureInitialized();
  OneSignal.initialize(appId);
  OneSignal.Notifications.requestPermission(true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      theme: ThemeData(
        textTheme: GoogleFonts.lexendTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary),
      ),
    );
  }
}
