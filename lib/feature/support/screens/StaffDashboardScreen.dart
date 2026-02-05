import 'package:flutter/material.dart';

class StaffDashboardScreen extends StatelessWidget {
  final String staffName;
  const StaffDashboardScreen({super.key, required this.staffName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  _statsRow(),
                  const SizedBox(height: 24),
                  const Text(
                    "طلبات تحتاج تبرع",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _patientCard(
                    patientName: "أحمد محمد",
                    bloodType: "A+",
                    date: "2026-01-22",
                    context: context,
                  ),
                  _patientCard(
                    patientName: "سارة علي",
                    bloodType: "O-",
                    date: "2026-01-23",
                    context: context,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "مرحباً",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Text(
                staffName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
    );
  }
  Widget _statsRow() {
    return Row(
      children: [
        _statCard(
          title: "طلبات المرضى",
          value: "12",
          icon: Icons.sick,
          color: Colors.red,
        ),
        const SizedBox(width: 12),
        _statCard(
          title: "متبرعين متاحين",
          value: "8",
          icon: Icons.volunteer_activism,
          color: Colors.green,
        ),
      ],
    );
  }
  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
  Widget _patientCard({
    required String patientName,
    required String bloodType,
    required String date,
    required BuildContext context,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patientName,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text("🩸 فصيلة الدم: $bloodType"),
            Text("📅 تاريخ الحجز: $date"),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                    },
                    icon: const Icon(Icons.volunteer_activism),
                    label: const Text("متبرعين مناسبين"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("تم إرسال إشعار للمدير"),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications),
                    label: const Text("إبلاغ المدير"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
