import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BloodRequestsForDonorScreen extends StatelessWidget {
  const BloodRequestsForDonorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final currentDonorUid = currentUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("طلبات الدم المتاحة"),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('users').doc(currentDonorUid).get(),
        builder: (context, snapshotUser) {
          if (!snapshotUser.hasData) return const Center(child: CircularProgressIndicator());

          final donorData = snapshotUser.data!.data();
          final donorBloodType = donorData?['bloodType'] ?? '';
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('blood_requests')
                .where('bloodType', isEqualTo: donorBloodType)
                .where('status', isEqualTo: 'pending')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

              final requests = snapshot.data!.docs;
              if (requests.isEmpty) return const Center(child: Text("لا توجد طلبات متاحة"));

              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final data = requests[index].data();
                  final requestId = requests[index].id;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      title: Text("المريض: ${data['patientName'] ?? 'غير محدد'}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("فصيلة الدم: ${data['bloodType']}"),
                          Text("الكمية المطلوبة: ${data['amount']} ml"),
                          Text("المستشفى: ${data['hospital']}"),
                          Text("المحافظة: ${data['governorate']}"),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                        onPressed: () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('blood_requests')
                                .doc(requestId)
                                .update({
                              'status': 'completed',
                              'donorId': currentDonorUid,
                              'donorName': donorData?['name'] ?? 'متبرع مجهول',
                            });

                            await FirebaseFirestore.instance.collection('donation_history').add({
                              'donorId': currentDonorUid,
                              'donorName': donorData?['name'] ?? 'متبرع مجهول',
                              'patientId': data['patientId'],
                              'patientName': data['patientName'] ?? 'غير محدد',
                              'bloodType': data['bloodType'],
                              'amount': data['amount'],
                              'hospital': data['hospital'],
                              'governorate': data['governorate'],
                              'timestamp': FieldValue.serverTimestamp(),
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("تم التبرع بنجاح!")),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("حدث خطأ: $e")),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
