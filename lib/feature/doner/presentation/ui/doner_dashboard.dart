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
  final uid = FirebaseAuth.instance.currentUser!.uid;

  String donorName = "متبرع";
  String? donorBloodType;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDonorData();
  }

  Future<void> _loadDonorData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = doc.data();
    if (data != null) {
      donorName = data['name'] ?? donorName;
      donorBloodType = data['bloodType'];
    }

    setState(() => isLoading = false);
  }

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd / MM / yyyy').format(date);
  }

  Color getBloodTypeColor(String bloodType) {
    switch (bloodType) {
      case 'A+': return Colors.red;
      case 'A-': return Colors.redAccent;
      case 'B+': return Colors.blue;
      case 'B-': return Colors.blueAccent;
      case 'AB+': return Colors.purple;
      case 'AB-': return Colors.purpleAccent;
      case 'O+': return Colors.green;
      case 'O-': return Colors.greenAccent;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || donorBloodType == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard المتبرع"),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [

          /// 👤 بيانات المتبرع
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("أهلاً $donorName",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text("فصيلة الدم: $donorBloodType",
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),

          const SizedBox(height: 8),

          /// 🩸 طلبات الدم المناسبة
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('blood_requests')
                  .where('bloodType', isEqualTo: donorBloodType)
                  .where('status', isEqualTo: 'pending')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final requests = snapshot.data!.docs;

                if (requests.isEmpty) {
                  return const Center(
                    child: Text("لا توجد طلبات دم حالياً"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final data =
                    requests[index].data() as Map<String, dynamic>;
                    final docId = requests[index].id;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                          getBloodTypeColor(data['bloodType']),
                          child: Text(
                            data['bloodType'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                            "${data['amount']} ml - ${data['hospital']}"),
                        subtitle: Text(
                            "المحافظة: ${data['governorate']}"),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          onPressed: () async {
                            /// حفظ التبرع
                            await FirebaseFirestore.instance
                                .collection('donation_history')
                                .add({
                              'donorId': uid,
                              'donorName': donorName,
                              'bloodType': data['bloodType'],
                              'amount': data['amount'],
                              'hospital': data['hospital'],
                              'governorate': data['governorate'],
                              'requestId': docId,
                              'date': Timestamp.now(),
                            });

                            /// تحديث الطلب
                            await FirebaseFirestore.instance
                                .collection('blood_requests')
                                .doc(docId)
                                .update({
                              'status': 'accepted',
                              'donorId': uid,
                              'donorName': donorName,
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                  Text("تم حجز التبرع بنجاح ✅")),
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

          const Divider(),

          /// 📜 سجل التبرعات
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("سجل التبرعات السابقة",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('donation_history')
                  .where('donorId', isEqualTo: uid)
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final donations = snapshot.data!.docs;

                if (donations.isEmpty) {
                  return const Center(
                      child: Text("لا يوجد سجل تبرعات"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    final data =
                    donations[index].data() as Map<String, dynamic>;

                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.bloodtype,
                            color: getBloodTypeColor(data['bloodType'])),
                        title: Text("${data['amount']} ml"),
                        subtitle: Text(
                            "${data['hospital']} - ${formatDate(data['date'])}"),
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
