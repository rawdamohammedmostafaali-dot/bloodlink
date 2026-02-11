import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  String? selectedBloodType;
  String? selectedGovernorate;
  String? selectedHospital;

  final List<String> bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];
  final List<String> hospitals = ["مستشفى 1", "مستشفى 2", "مستشفى 3"];
  final List<String> governorates = ["القاهرة", "الجيزة", "الإسكندرية"];

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    Query requestsQuery = FirebaseFirestore.instance.collection('blood_requests');

    if (selectedBloodType != null) requestsQuery = requestsQuery.where('bloodType', isEqualTo: selectedBloodType);
    if (selectedGovernorate != null) requestsQuery = requestsQuery.where('governorate', isEqualTo: selectedGovernorate);
    if (selectedHospital != null) requestsQuery = requestsQuery.where('hospital', isEqualTo: selectedHospital);

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard الموظف"), backgroundColor: Colors.deepPurple),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "فصيلة الدم"),
                    value: selectedBloodType,
                    items: bloodTypes.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                    onChanged: (val) => setState(() => selectedBloodType = val),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "المحافظة"),
                    value: selectedGovernorate,
                    items: governorates.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (val) => setState(() => selectedGovernorate = val),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "المستشفى"),
                    value: selectedHospital,
                    items: hospitals.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
                    onChanged: (val) => setState(() => selectedHospital = val),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: requestsQuery.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final requests = snapshot.data!.docs;
                if (requests.isEmpty) return const Center(child: Text("لا توجد طلبات"));

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final data = requests[index].data() as Map<String, dynamic>;
                    final docId = requests[index].id;
                    final status = data['status'] ?? 'pending';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [Colors.deepPurple.withOpacity(0.05), Colors.deepPurple.withOpacity(0.15)],
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          title: Text("فصيلة الدم: ${data['bloodType']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("المريض: ${data['patientId']}"),
                              Text("الكمية: ${data['amount']} ml"),
                              Text("المستشفى: ${data['hospital']}"),
                              Text("المحافظة: ${data['governorate']}"),
                              const SizedBox(height: 6),
                              Text(
                                "الحالة: $status",
                                style: TextStyle(fontWeight: FontWeight.bold, color: getStatusColor(status)),
                              ),
                            ],
                          ),
                          trailing: status != 'completed'
                              ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('blood_requests')
                                  .doc(docId)
                                  .update({'status': 'completed'});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("تم تحديث حالة الطلب ✅")),
                              );
                            },
                            child: const Text("إنهاء"),
                          )
                              : null,
                        ),
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
