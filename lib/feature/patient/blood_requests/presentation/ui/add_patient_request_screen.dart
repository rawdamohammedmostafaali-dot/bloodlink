import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPatientRequestScreen extends StatefulWidget {
  const AddPatientRequestScreen({super.key});

  @override
  State<AddPatientRequestScreen> createState() => _AddPatientRequestScreenState();
}

class _AddPatientRequestScreenState extends State<AddPatientRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final bloodUnitsController = TextEditingController();
  String bloodType = "A+";
  bool isLoading = false;

  final List<String> bloodTypes = [
    "A+","A-","B+","B-","AB+","AB-","O+","O-"
  ];

  Future<void> addRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('blood_requests').add({
        'patientId': uid,
        'bloodType': bloodType,
        'units': int.parse(bloodUnitsController.text.trim()),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تسجيل طلب الدم بنجاح")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    bloodUnitsController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: Colors.red) : null,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("حجز دم جديد"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: bloodType,
                items: bloodTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => bloodType = value!),
                decoration: _inputDecoration(label: "فصيلة الدم", icon: Icons.bloodtype),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: bloodUnitsController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(label: "عدد الأكياس المطلوبة", icon: Icons.format_list_numbered),
                validator: (val) => val == null || val.isEmpty ? "الحقل مطلوب" : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : addRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("حجز الدم", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
