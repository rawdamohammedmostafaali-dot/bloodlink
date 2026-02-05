import 'package:flutter/material.dart';
import '../feature/auth/presentation/ui/login/login_screen.dart';
import '../feature/home/presentation/ui/main_screen.dart';
import '../screens/splash_screen.dart';
class HomeBlood extends StatelessWidget {
  const HomeBlood({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BloodLink',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const LoginScreen(),
    );
  }
}