import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    List<Widget> pages = [
      _buildHome(uid),
      _buildBloodRequests(uid),
      _buildDonationHistory(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة تحكم المريض"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          // زر لإضافة طلب دم جديد
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("إضافة طلب دم جديد")),
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'طلبات الدم'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'سجل التبرعات'),
        ],
      ),
    );
  }
  Widget _buildHome(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('blood_requests')
          .where('patientId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final requests = snapshot.data!.docs;

        if (requests.isEmpty) {
          return const Center(child: Text("لا توجد طلبات دم حالياً"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final data = requests[index].data() as Map<String, dynamic>;
            return _requestCard(data);
          },
        );
      },
    );
  }
  Widget _buildBloodRequests(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('blood_requests')
          .where('patientId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final requests = snapshot.data!.docs;

        if (requests.isEmpty) {
          return const Center(child: Text("لا توجد طلبات دم سابقة"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final data = requests[index].data() as Map<String, dynamic>;
            return _requestCard(data);
          },
        );
      },
    );
  }
  Widget _buildDonationHistory() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.bloodtype, color: Colors.red),
            title: Text("تبرع فصيلة A+"),
            subtitle: Text("تاريخ التبرع: 20/01/2026 | 450 ml"),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.bloodtype, color: Colors.red),
            title: Text("تبرع فصيلة O-"),
            subtitle: Text("تاريخ التبرع: 10/01/2026 | 500 ml"),
          ),
        ),
      ],
    );
  }
  Widget _requestCard(Map<String, dynamic> data) {
    final bloodType = data['bloodType'] ?? '-';
    final amount = data['amount'] ?? '-';
    final hospital = data['hospital'] ?? '-';
    final governorate = data['governorate'] ?? '-';
    final status = data['status'] ?? 'pending';
    final createdAt = data['createdAt'] as Timestamp?;

    Color getStatusColor(String status) {
      switch (status) {
        case "pending":
          return Colors.orange;
        case "accepted":
          return Colors.green;
        case "completed":
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }

    String formatDate(Timestamp? timestamp) {
      if (timestamp == null) return '-';
      final date = timestamp.toDate();
      return "${date.day}/${date.month}/${date.year}";
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bloodtype, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  "$bloodType | $amount ml",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  decoration: BoxDecoration(
                    color: getStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status == 'pending'
                        ? "معلق"
                        : status == 'accepted'
                        ? "مقبول"
                        : "مكتمل",
                    style: TextStyle(
                        color: getStatusColor(status), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.local_hospital, size: 18),
                const SizedBox(width: 6),
                Text(hospital),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_city, size: 18),
                const SizedBox(width: 6),
                Text(governorate),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 6),
                Text(formatDate(createdAt)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
