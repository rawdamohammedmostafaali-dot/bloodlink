import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../blood_requests/screens/blood_requests_screen.dart';
import '../../../../widgets/home_slider.dart';


class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final String name = FirebaseAuth.instance.currentUser?.displayName ?? "المريض";

    List<Widget> pages = [
      _buildHome(uid, name),
      const Center(child: Text("الإشعارات")),
      const Center(child: Text("البروفايل")),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("مرحباً $name"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'الإشعارات'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'البروفايل'),
        ],
      ),
    );
  }

  Widget _buildHome(String? uid, String name) {
    if (uid == null) return const Center(child: Text("المستخدم غير مسجل"));

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Center(child: Text("لا توجد بيانات للمريض"));
        }

        final data = snapshot.data!.data()!;
        final bloodType = data['bloodType'] ?? 'غير محدد';
        final lastRequestDate = data['lastRequestDate'] != null
            ? (data['lastRequestDate'] as Timestamp).toDate()
            : null;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const HomeSlider(),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "❤️ صحتك تهمنا",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("🩸 فصيلة الدم: $bloodType"),
                  const Text("👤 النوع: مريض"),
                  if (lastRequestDate != null)
                    Text(
                      "⏳ آخر طلب دم: ${lastRequestDate.day}/${lastRequestDate.month}/${lastRequestDate.year}",
                      style: const TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BloodRequestsScreen()),
                  );
                },
                child: const Text("🩸 اطلب دم", style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerRight,
              child: Text("الخدمات", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _HomeButton(icon: Icons.history, text: "طلباتك السابقة", onTap: () {}),
                const SizedBox(width: 12),
                _HomeButton(icon: Icons.support_agent, text: "الدعم", onTap: () {}),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _HomeButton({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 110,
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
