import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class BloodRequestsScreen extends StatelessWidget {
  const BloodRequestsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("طلبات الدم"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('blood_requests').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final requests = snapshot.data!.docs;
          if (requests.isEmpty) return const Center(child: Text("لا توجد طلبات دم"));

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data();
              final status = data['status'] ?? 'قيد الانتظار';
              final statusColor = status == "مكتمل" ? Colors.green : Colors.orange;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  title: Text("المتبرع: ${data['donorName'] ?? 'غير محدد'}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("الكمية: ${data['bagsNeeded'] ?? '-'}"),
                      const SizedBox(height: 4),
                      Text("الحالة: $status", style: TextStyle(color: statusColor)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status != "مكتمل")
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                          onPressed: () async {
                            final docId = requests[index].id;
                            await FirebaseFirestore.instance
                                .collection('blood_requests')
                                .doc(docId)
                                .update({'status': 'مكتمل'});
                            await FirebaseFirestore.instance.collection('donation_history').add({
                              'donorName': data['donorName'] ?? 'غير محدد',
                              'bagsDonated': data['bagsNeeded'] ?? '-',
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                          },
                        ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          FirebaseFirestore.instance
                              .collection('blood_requests')
                              .doc(requests[index].id)
                              .update({'status': value});
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: "مكتمل", child: Text("تم التبرع")),
                          PopupMenuItem(value: "قيد الانتظار", child: Text("قيد الانتظار")),
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
