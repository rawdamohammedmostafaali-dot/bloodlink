import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DonationHistoryScreen extends StatefulWidget {
  const DonationHistoryScreen({super.key});

  @override
  State<DonationHistoryScreen> createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  String searchQuery = "";

  Color getBloodTypeColor(String bloodType) {
    switch (bloodType) {
      case 'A+':
        return Colors.redAccent;
      case 'A-':
        return Colors.red.shade200;
      case 'B+':
        return Colors.blueAccent;
      case 'B-':
        return Colors.blue.shade200;
      case 'AB+':
        return Colors.purpleAccent;
      case 'AB-':
        return Colors.purple.shade200;
      case 'O+':
        return Colors.greenAccent;
      case 'O-':
        return Colors.green.shade200;
      default:
        return Colors.grey;
    }
  }

  String formatDate(dynamic timestamp) {
    if (timestamp == null) return 'غير محدد';
    DateTime dt;
    if (timestamp is Timestamp) {
      dt = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dt = timestamp;
    } else {
      return 'غير محدد';
    }
    return DateFormat('dd / MM / yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("سجل التبرعات"),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "ابحث بالاسم...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white70,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('donation_history')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("لا يوجد تبرعات حتى الآن"));
                }

                var donations = snapshot.data!.docs;

                if (searchQuery.isNotEmpty) {
                  donations = donations.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['donorName'] ?? '').toString().toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();
                }

                if (donations.isEmpty) {
                  return const Center(child: Text("لا يوجد نتائج"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    final data = donations[index].data() as Map<String, dynamic>;
                    final donorName = data['donorName'] ?? 'غير محدد';
                    final bloodType = data['bloodType'] ?? '-';
                    final timestamp = data['date'];
                    final date = formatDate(timestamp);

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      color: getBloodTypeColor(bloodType).withOpacity(0.2),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor: getBloodTypeColor(bloodType),
                          child: Text(
                            bloodType,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(donorName,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("تاريخ آخر تبرع: $date"),
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
