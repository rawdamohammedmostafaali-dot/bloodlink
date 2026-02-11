import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalsScreen extends StatelessWidget {
  const HospitalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> hospitals = [
      {
        'name': 'مستشفى الدم بالقاهرة',
        'phone': '01011112222',
        'latitude': 30.0444,
        'longitude': 31.2357,
      },
      {
        'name': 'مستشفى السلام بالجيزة',
        'phone': '01033334444',
        'latitude': 30.0131,
        'longitude': 31.2089,
      },
      {
        'name': 'مستشفى النور بالإسكندرية',
        'phone': '01055556666',
        'latitude': 31.2001,
        'longitude': 29.9187,
      },
    ];

    Future<void> _callHospital(String phone) async {
      final Uri url = Uri(scheme: 'tel', path: phone);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("لا يمكن إجراء الاتصال")),
        );
      }
    }

    Future<void> _openMap(double lat, double lng) async {
      final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("لا يمكن فتح الخريطة")),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("المستشفيات"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: hospitals.length,
        itemBuilder: (context, index) {
          final hospital = hospitals[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffff4b6e), Color(0xffff758f)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Text(
                hospital['name'],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              leading: const Icon(Icons.local_hospital, color: Colors.white, size: 32),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.phone, color: Colors.white),
                    onPressed: () => _callHospital(hospital['phone']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.map, color: Colors.white),
                    onPressed: () => _openMap(hospital['latitude'], hospital['longitude']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
