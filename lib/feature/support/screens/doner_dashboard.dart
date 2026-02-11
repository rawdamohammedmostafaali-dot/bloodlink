import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
class DonorDashboardScreen extends StatefulWidget {
  const DonorDashboardScreen({super.key});

  @override
  State<DonorDashboardScreen> createState() => _DonorDashboardScreenState();
}

class _DonorDashboardScreenState extends State<DonorDashboardScreen> {
  String searchQuery = "";
  final uid = FirebaseAuth.instance.currentUser!.uid;
  String donorName = FirebaseAuth.instance.currentUser?.displayName ?? "متبرع";

  String formatDate(dynamic timestamp) {
    if (timestamp == null) return 'غير محدد';
    DateTime dt;
    if (timestamp is Timestamp) dt = timestamp.toDate();
    else if (timestamp is DateTime) dt = timestamp;
    else return 'غير محدد';
    return DateFormat('dd / MM / yyyy').format(dt);
  }
  Color getBloodTypeColor(String bloodType) {
    switch (bloodType) {
      case 'A+': return Colors.redAccent;
      case 'A-': return Colors.red.shade200;
      case 'B+': return Colors.blueAccent;
      case 'B-': return Colors.blue.shade200;
      case 'AB+': return Colors.purpleAccent;
      case 'AB-': return Colors.purple.shade200;
      case 'O+': return Colors.greenAccent;
      case 'O-': return Colors.green.shade200;
      default: return Colors.grey;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard المتبرع"), backgroundColor: Colors.red),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('blood_requests')
                  .where('bloodType', isEqualTo: FirebaseAuth.instance.currentUser?.displayName)
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var requests = snapshot.data!.docs;

                if (searchQuery.isNotEmpty) {
                  requests = requests.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final patientId = (data['patientId'] ?? '').toString().toLowerCase();
                    return patientId.contains(searchQuery);
                  }).toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final data = requests[index].data() as Map<String, dynamic>;
                    final docId = requests[index].id;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text("فصيلة الدم: ${data['bloodType']}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("الكمية: ${data['amount']} ml"),
                            Text("المستشفى: ${data['hospital']}"),
                            Text("المحافظة: ${data['governorate']}"),
                            Text("الحالة: ${data['status']}"),
                          ],
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () async {
                            await FirebaseFirestore.instance.collection('donation_history').add({
                              'donorId': uid,
                              'donorName': donorName,
                              'bloodType': data['bloodType'],
                              'amount': data['amount'],
                              'requestId': docId,
                              'date': Timestamp.now(),
                            });

                            // تحديث حالة الطلب
                            await FirebaseFirestore.instance.collection('blood_requests').doc(docId).update({
                              'status': 'accepted',
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("تم حجز التبرع بنجاح ✅")),
                            );
                          },
                          child: const Text("سأتبرع"),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("سجل التبرعات السابقة", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('donation_history')
                  .where('donorId', isEqualTo: uid)
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final donations = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    final data = donations[index].data() as Map<String, dynamic>;
                    return Card(
                      color: getBloodTypeColor(data['bloodType'] ?? '').withOpacity(0.2),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: getBloodTypeColor(data['bloodType'] ?? ''),
                          child: Text(data['bloodType'] ?? '', style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(data['donorName'] ?? 'غير محدد'),
                        subtitle: Text("الكمية: ${data['amount']} ml\nتاريخ: ${formatDate(data['date'])}"),
                      ),
                    );
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
