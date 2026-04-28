import 'package:flutter/material.dart';
import 'package:the_digital_registration/views/login_screen.dart';
import 'package:the_digital_registration/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Digital Registration',
      theme: AppTheme.lightTheme(),
      home: const LoginScreen(),
    );
  }
}
