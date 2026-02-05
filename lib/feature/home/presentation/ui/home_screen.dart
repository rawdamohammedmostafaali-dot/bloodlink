import 'package:bloodlink/feature/home/presentation/ui/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../blood_requests/screens/blood_requests_screen.dart';
import '../../../../widgets/home_slider.dart';
import '../../../auth/presentation/ui/login/login_screen.dart';
import '../../../support/screens/BookDonationScreen.dart';
import '../../../support/screens/DonationHistoryScreen.dart';
import '../../../support/screens/hospitals_screen.dart';
import '../../../support/screens/support_screen.dart';
import 'notifications_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  bool canDonate(DateTime? lastDate) {
    if (lastDate == null) return true;
    return DateTime.now().difference(lastDate).inDays >= 90;
  }

  int remainingDays(DateTime lastDate) {
    int passed = DateTime.now().difference(lastDate).inDays;
    return 90 - passed;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    List<Widget> pages = [
      _buildHome(uid),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    List<String> titles = ["قطرة دم", "الإشعارات", "البروفايل"];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        centerTitle: true,
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_selectedIndex == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            } else {
              setState(() {
                _selectedIndex = 0;
              });
            }
          },
        ),
        actions: null,
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

  Widget _buildHome(String? uid) {
    if (uid == null) return const Center(child: Text("المستخدم غير مسجل"));

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Center(child: Text("لا توجد بيانات للمتبرع"));
        }

        final data = snapshot.data!.data()!;
        final bloodType = data['bloodType'] ?? 'غير محدد';
        DateTime? lastDonationDate;
        if (data['lastDonationDate'] != null) {
          lastDonationDate = (data['lastDonationDate'] as Timestamp).toDate();
        }

        final isAllowed = canDonate(lastDonationDate);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            HomeSlider(),
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
                    "❤️ تبرعك ممكن ينقذ حياة",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("🩸  $bloodType  : فصيلة الدم"),
                  const Text("👤 النوع: متبرع"),
                  const SizedBox(height: 8),
                  isAllowed
                      ? const Text("✅ متاح للتبرع الآن", style: TextStyle(color: Colors.green))
                      : Text(
                    "⏳ متبقي ${remainingDays(lastDonationDate!)} يوم للتبرع",
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isAllowed
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookDonationScreen()),
                  );
                }
                    : null,
                child: Text(
                  isAllowed ? "🩸 احجز موعد تبرع" : "غير متاح حاليًا",
                  style: const TextStyle(fontSize: 16),
                ),
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
                _HomeButton(icon: Icons.favorite, text: "طلبات دم", onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BloodRequestsScreen()));
                }),
                const SizedBox(width: 12),
                _HomeButton(icon: Icons.local_hospital, text: "مستشفيات", onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HospitalsScreen()));
                }),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _HomeButton(icon: Icons.history, text: "سجل التبرع", onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DonationHistoryScreen()));
                }),
                const SizedBox(width: 12),
                _HomeButton(icon: Icons.support_agent, text: "الدعم", onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen(isAdmin: false)));
                }),
              ],
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerRight,
              child: Text("الإحصائيات", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 5),
            Row(
              children: const [
                _StatCard(title: "متبرعين", value: "120"),
                SizedBox(width: 12),
                _StatCard(title: "طلبات", value: "8"),
                SizedBox(width: 12),
                _StatCard(title: "مستشفيات", value: "5"),
              ],
            ),
            const SizedBox(height: 80),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(fontSize: 15, color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
