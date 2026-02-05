import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../widgets/home_slider.dart';
import '../../../support/screens/add_donation_screen.dart';
class DonorHomeScreen extends StatefulWidget {
  const DonorHomeScreen({super.key});

  @override
  State<DonorHomeScreen> createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends State<DonorHomeScreen> {
  int _selectedIndex = 0;

  bool canDonate(DateTime? lastDate) {
    if (lastDate == null) return true;
    return DateTime.now().difference(lastDate).inDays >= 90;
  }

  int remainingDays(DateTime lastDate) {
    int passed = DateTime.now().difference(lastDate).inDays;
    return 90 - passed;
  }

  Future<int> getMyDonationsCount() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('donation_history')
        .where('donorId', isEqualTo: uid)
        .get();
    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final String name = FirebaseAuth.instance.currentUser?.displayName ?? "المتبرع";

    List<Widget> pages = [
      _buildHome(uid, name),
      const Center(child: Text("الإشعارات")), // placeholder
      const Center(child: Text("البروفايل")), // placeholder
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
            const HomeSlider(),
            const SizedBox(height: 16),
            // بطاقة معلومات المتبرع
            FutureBuilder<int>(
              future: getMyDonationsCount(),
              builder: (context, snapshot) {
                int count = snapshot.data ?? 0;
                return Container(
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
                      Text("🩸 فصيلة الدم: $bloodType"),
                      const Text("👤 النوع: متبرع"),
                      const SizedBox(height: 8),
                      isAllowed
                          ? const Text("✅ متاح للتبرع الآن", style: TextStyle(color: Colors.green))
                          : Text(
                        "⏳ متبقي ${remainingDays(lastDonationDate!)} يوم للتبرع",
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 10),
                      Text("عدد التبرعات: $count", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // زر حجز التبرع
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isAllowed
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddDonationScreen()),
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
          ],
        );
      },
    );
  }
}
