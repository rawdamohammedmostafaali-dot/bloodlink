import 'package:flutter/material.dart';
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {
        'title': 'طلب دم جديد',
        'subtitle': 'يوجد طلب دم O+ في مستشفى الدم بالقاهرة',
        'time': 'قبل 1 ساعة'
      },
      {
        'title': 'تذكير بالتبرع',
        'subtitle': 'موعد التبرع القادم لديك يوم 25 يناير',
        'time': 'أمس'
      },
      {
        'title': 'تنبيه دعم',
        'subtitle': 'تم الرد على استفسارك في صفحة الدعم',
        'time': 'منذ 3 أيام'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.red),
              title: Text(notif['title']!),
              subtitle: Text(notif['subtitle']!),
              trailing: Text(
                notif['time']!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }
}
