import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../screens/splash_screen.dart';

class HomeBlood extends StatefulWidget {
  const HomeBlood({super.key});

  @override
  State<HomeBlood> createState() => _HomeBloodState();
}

class _HomeBloodState extends State<HomeBlood> {

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    String? token = await messaging.getToken();
    print("🔥 FCM Token: $token");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Foreground message: ${message.notification?.title}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📲 Notification clicked");
    });
  }

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
