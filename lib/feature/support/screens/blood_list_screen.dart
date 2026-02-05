import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BloodListScreen extends StatefulWidget {
  const BloodListScreen({super.key});

  @override
  State<BloodListScreen> createState() => _BloodListScreenState();
}

class _BloodListScreenState extends State<BloodListScreen> {
  String searchText = "";
  String role = "donor";
  String currentUserName = "";

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      role = doc['role'] ?? "donor";
      currentUserName = doc['name'] ?? "المستخدم";
    });
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "لم يتبرع بعد";
    final date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> markAsDonated(String donorId, QueryDocumentSnapshot donor) async {
    await FirebaseFirestore.instance.collection('donation_history').add({
      'donorId': donorId,
      'donorName': donor['name'],
      'bloodType': donor['bloodType'],
      'date': FieldValue.serverTimestamp(),
    });
    await FirebaseFirestore.instance.collection('donors').doc(donorId).update({
      'available': false,
      'lastDonationDate': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم تسجيل التبرع بنجاح")),
    );
  }

  Future<void> bookDonation(String donorId, QueryDocumentSnapshot donor) async {
    await FirebaseFirestore.instance.collection('blood_requests').add({
      'patientId': FirebaseAuth.instance.currentUser!.uid,
      'donorId': donorId,
      'donorName': donor['name'],
      'bloodType': donor['bloodType'],
      'status': 'booked',
      'createdAt': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم حجز الدم بنجاح")),
    );
  }

  void showAddDonorDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String bloodType = "A+";
    final List<String> bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("إضافة متبرع جديد", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "اسم المتبرع",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "رقم الهاتف",
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: bloodType,
                  items: bloodTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => bloodType = val!),
                  decoration: const InputDecoration(
                    labelText: "فصيلة الدم",
                    prefixIcon: Icon(Icons.bloodtype),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                if (nameController.text.isEmpty || phoneController.text.isEmpty) return;
                setState(() => isLoading = true);
                await FirebaseFirestore.instance.collection('donors').add({
                  'name': nameController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'bloodType': bloodType,
                  'available': true,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                setState(() => isLoading = false);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم إضافة المتبرع بنجاح")),
                );
              },
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("حفظ"),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(role == "donor" ? "مرحباً $currentUserName" : "لوحة المريض"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      floatingActionButton: role == "donor"
          ? FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: showAddDonorDialog,
        child: const Icon(Icons.add),
        tooltip: "إضافة متبرع جديد",
      )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                onChanged: (val) => setState(() => searchText = val.trim()),
                decoration: InputDecoration(
                  hintText: "ابحث باسم المتبرع",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('donors')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  var donors = snapshot.data!.docs;
                  if (searchText.isNotEmpty) {
                    donors = donors.where((d) => d['name'].toString().toLowerCase().contains(searchText.toLowerCase())).toList();
                  }
                  if (donors.isEmpty) return const Center(child: Text("لا يوجد متبرعين"));

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: donors.length,
                    itemBuilder: (context, index) {
                      final donor = donors[index];
                      final lastDonation = _formatDate(donor['lastDonationDate']);
                      bool canInteract = role == "donor" ? donor['available'] : true;

                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          leading: const Icon(Icons.person, size: 40, color: Colors.red),
                          title: Text(donor['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("فصيلة الدم: ${donor['bloodType']}"),
                              Text("آخر تبرع: $lastDonation", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                            ],
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: role == "donor" ? Colors.green : Colors.blue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: canInteract
                                ? () => role == "donor"
                                ? markAsDonated(donor.id, donor)
                                : bookDonation(donor.id, donor)
                                : null,
                            child: Text(role == "donor" ? "تم التبرع" : "حجز الدم"),
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
      ),
    );
  }
}
