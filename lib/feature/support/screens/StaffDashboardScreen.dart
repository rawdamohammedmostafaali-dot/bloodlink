import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class StaffDashboardScreen extends StatelessWidget {
  final String staffName;
  const StaffDashboardScreen({super.key, required this.staffName});
  static const LinearGradient mainGradient = LinearGradient(
    colors: [Color(0xffff4b6e), Color(0xffff758f)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  Future<int> getDonorsCount() async {
    final snapshot = await FirebaseFirestore.instance.collection('donors').get();
    return snapshot.docs.length;
  }
  Future<int> getRequestsCount() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('blood_requests').get();
    return snapshot.docs.length;
  }
  Widget statCard({required String title, required int value, required IconData icon}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: mainGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              "$value",
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(title,
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
  Widget gradientButton({required String label, required IconData icon, required VoidCallback onTap}) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        gradient: mainGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
  Widget patientCard(BuildContext context, DocumentSnapshot doc) {
    final patientName = doc['patientName'];
    final bloodType = doc['bloodType'];
    final date = doc['createdAt'] != null
        ? (doc['createdAt'] as Timestamp).toDate().toString().split(' ')[0]
        : "غير محدد";
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text("🩸 فصيلة الدم: $bloodType"),
            Text("📅 تاريخ الحجز: $date"),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: gradientButton(
                      label: "متبرعين مناسبين",
                      icon: Icons.volunteer_activism,
                      onTap: () {}),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: gradientButton(
                      label: "إبلاغ المدير",
                      icon: Icons.notifications,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("تم إرسال إشعار للمدير")),
                        );
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: mainGradient,
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
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FutureBuilder<int>(
                  future: getRequestsCount(),
                  builder: (context, snapshot) {
                    int value = snapshot.data ?? 0;
                    return statCard(
                        title: "طلبات المرضى",
                        value: value,
                        icon: Icons.sick);
                  },
                ),
                const SizedBox(width: 12),
                FutureBuilder<int>(
                  future: getDonorsCount(),
                  builder: (context, snapshot) {
                    int value = snapshot.data ?? 0;
                    return statCard(
                        title: "متبرعين متاحين",
                        value: value,
                        icon: Icons.volunteer_activism);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "طلبات تحتاج تبرع",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('blood_requests')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text("لا توجد طلبات حالياً"));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    return patientCard(context, docs[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
