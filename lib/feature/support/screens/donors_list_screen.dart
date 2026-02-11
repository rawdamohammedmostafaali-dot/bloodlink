import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonorsListScreen extends StatefulWidget {
  const DonorsListScreen({super.key});

  @override
  State<DonorsListScreen> createState() => _DonorsListScreenState();
}

class _DonorsListScreenState extends State<DonorsListScreen> {
  String searchText = "";
  bool isAdding = false;

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String bloodType = "A+";

  final List<String> bloodTypes = [
    "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"
  ];

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> addDonor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isAdding = true);
    try {
      await FirebaseFirestore.instance.collection('donors').add({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'bloodType': bloodType,
        'available': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم إضافة المتبرع بنجاح")),
      );

      nameController.clear();
      phoneController.clear();
      bloodType = "A+";
      setState(() => isAdding = false);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ: $e")),
      );
      setState(() => isAdding = false);
    }
  }

  void showAddDonorBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("إضافة متبرع جديد", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "اسم المتبرع"),
                validator: (value) => value == null || value.isEmpty ? "الحقل مطلوب" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "رقم الهاتف"),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? "الحقل مطلوب" : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: bloodType,
                items: bloodTypes.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (val) => setState(() => bloodType = val!),
                decoration: const InputDecoration(labelText: "فصيلة الدم"),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isAdding ? null : addDonor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isAdding
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("حفظ"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "لم يتبرع بعد";
    final date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> markAsDonated(String donorId, QueryDocumentSnapshot donor) async {
    try {
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المتبرعين"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: showAddDonorBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (val) => setState(() => searchText = val.trim()),
              decoration: const InputDecoration(
                hintText: "ابحث باسم المتبرع",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('donors').orderBy('createdAt', descending: true).snapshots(),
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

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: donor['available']
                              ? [Colors.red.shade200, Colors.red.shade400]
                              : [Colors.grey.shade300, Colors.grey.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        title: Text(donor['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("فصيلة الدم: ${donor['bloodType']}", style: const TextStyle(color: Colors.white70)),
                            Text("آخر تبرع: $lastDonation", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: donor['available'] ? Colors.green : Colors.grey,
                          ),
                          onPressed: donor['available'] ? () => markAsDonated(donor.id, donor) : null,
                          child: Text(donor['available'] ? "تم التبرع" : "تم"),
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
