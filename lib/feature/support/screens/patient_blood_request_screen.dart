import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientBloodRequestsScreen extends StatelessWidget {
  const PatientBloodRequestsScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("طلباتك السابقة"),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('blood_requests')
            .where('patientId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("لا توجد طلبات دم حتى الآن"));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;
              final bloodType = data['bloodType'] ?? '-';
              final amount = data['amount'] ?? '-';
              final hospital = data['hospital'] ?? '-';
              final governorate = data['governorate'] ?? '-';
              final status = data['status'] ?? 'pending';
              final createdAt = data['createdAt'] as Timestamp?;

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
            },
          );
        },
      ),
    );
  }
}
