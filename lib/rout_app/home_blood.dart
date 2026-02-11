import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';

class HomeBlood extends StatelessWidget {
  const HomeBlood({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BloodLink',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const SplashScreen(),
    );
  }
}
