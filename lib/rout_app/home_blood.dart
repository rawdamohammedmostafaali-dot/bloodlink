
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../screens/splash_screen.dart';

class HomeBlood extends StatelessWidget {
  const HomeBlood({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
