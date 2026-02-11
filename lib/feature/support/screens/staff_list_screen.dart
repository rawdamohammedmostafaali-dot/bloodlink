import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffListScreen extends StatelessWidget {
  const StaffListScreen({super.key});

  static const LinearGradient appBarGradient = LinearGradient(
    colors: [Color(0xffff4b6e), Color(0xffff758f)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: appBarGradient),
        ),
        title: const Text("قائمة الموظفين"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'staff')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("لا يوجد موظفين بعد"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.redAccent),
                  title: Text(
                    data['name'] ?? "لا يوجد اسم",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    children: [
                      const Icon(Icons.lock, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("PIN: ${data['pin'] ?? 'غير محدد'}"),
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
