import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final nameController = TextEditingController();
  final pinController = TextEditingController();

  bool isLoading = false;
  String? error;

  Future<void> addStaff() async {
    final name = nameController.text.trim();
    final pin = pinController.text.trim();

    if (name.isEmpty || pin.isEmpty) {
      setState(() => error = "ادخلي الاسم وPIN");
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('pin', isEqualTo: pin)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() => error = "هذا PIN مستخدم بالفعل");
        return;
      }

      await FirebaseFirestore.instance.collection('users').add({
        "name": name,
        "pin": pin,
        "role": "staff",
      });
      nameController.clear();
      pinController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم إضافة الموظف بنجاح")),
      );
    } catch (e) {
      setState(() => error = "حدث خطأ، حاول مرة أخرى");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إضافة موظف"), backgroundColor: Colors.red),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "اسم الموظف"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "PIN"),
            ),
            const SizedBox(height: 20),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : addStaff,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("إضافة"),
            )
          ],
        ),
      ),
    );
  }
}
