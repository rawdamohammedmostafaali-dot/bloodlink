import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddDonationScreen extends StatefulWidget {
  const AddDonationScreen({super.key});

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  String bloodType = "A+";
  bool isLoading = false;

  final List<String> bloodTypes = [
    "A+","A-","B+","B-","AB+","AB-","O+","O-"
  ];

  Future<void> addDonation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('donation_history').add({
      'donorId': uid,
      'bloodType': bloodType,
      'amount': amountController.text.trim(),
      'date': Timestamp.now(),
      'status': 'booked',
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم إضافة التبرع بنجاح")),
    );

    Navigator.pop(context);
  }

  InputDecoration _inputDecoration({required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: Colors.red) : null,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إضافة تبرع جديد"),
        backgroundColor: Colors.red,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bloodtype, size: 70, color: Colors.red),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? "الحقل مطلوب" : null,
                      decoration: _inputDecoration(label: "الكمية (ml)", icon: Icons.format_list_numbered),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: bloodType,
                      items: bloodTypes
                          .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                          .toList(),
                      onChanged: (val) => setState(() => bloodType = val!),
                      decoration: _inputDecoration(label: "فصيلة الدم", icon: Icons.bloodtype),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : addDonation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 6,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("حفظ التبرع", style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
