import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BloodRequestsScreen extends StatefulWidget {
  const BloodRequestsScreen({super.key});

  @override
  State<BloodRequestsScreen> createState() => _BloodRequestsScreenState();
}

class _BloodRequestsScreenState extends State<BloodRequestsScreen> {
  String? bloodType;
  double amount = 250;
  String? selectedGovernorate;
  String? selectedHospital;
  bool isLoading = false;

  final List<String> bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];

  bool get isFormValid =>
      bloodType != null && selectedGovernorate != null && selectedHospital != null;

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> sendRequest() async {
    if (!isFormValid) return;

    setState(() => isLoading = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('blood_requests').add({
        'patientId': uid,
        'bloodType': bloodType,
        'amount': amount.toInt(),
        'hospital': selectedHospital,
        'governorate': selectedGovernorate,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'lastRequestDate': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("تم إرسال الطلب بنجاح ✅")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("حدث خطأ: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("طلب دم"), backgroundColor: Colors.red),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: DropdownButtonFormField<String>(
                  decoration: inputDecoration("اختر فصيلة الدم"),
                  value: bloodType,
                  items: bloodTypes
                      .map((type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  ))
                      .toList(),
                  onChanged: (val) => setState(() => bloodType = val),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("الكمية: ${amount.toInt()} ml"),
                    Slider(
                      value: amount,
                      min: 100,
                      max: 500,
                      divisions: 8,
                      label: amount.toInt().toString(),
                      activeColor: Colors.red,
                      onChanged: (val) => setState(() => amount = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('governorates').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final governorates = snapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      decoration: inputDecoration("اختر المحافظة"),
                      value: selectedGovernorate,
                      items: governorates
                          .map((doc) => DropdownMenuItem<String>(
                        value: doc['name'].toString(),
                        child: Text(doc['name'].toString()),
                      ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedGovernorate = val;
                          selectedHospital = null;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (selectedGovernorate != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('governorates')
                        .doc(selectedGovernorate)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const CircularProgressIndicator();
                      final hospitals = snapshot.data!['hospitals'] as List<dynamic>;
                      return DropdownButtonFormField<String>(
                        decoration: inputDecoration("اختر المستشفى"),
                        value: selectedHospital,
                        items: hospitals
                            .map((h) => DropdownMenuItem<String>(
                          value: h.toString(),
                          child: Text(h.toString()),
                        ))
                            .toList(),
                        onChanged: (val) => setState(() => selectedHospital = val),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isFormValid && !isLoading ? sendRequest : null,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("إرسال الطلب", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
