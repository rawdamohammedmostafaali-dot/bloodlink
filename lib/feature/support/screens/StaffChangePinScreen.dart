import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'StaffHomeScreen.dart';
class StaffChangePinScreen extends StatefulWidget {
  final String uid;
  const StaffChangePinScreen({super.key, required this.uid});

  @override
  State<StaffChangePinScreen> createState() => _StaffChangePinScreenState();
}

class _StaffChangePinScreenState extends State<StaffChangePinScreen> {
  final TextEditingController pinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();
  bool isLoading = false;

  void updatePin() async {
    String pin = pinController.text.trim();
    String confirmPin = confirmPinController.text.trim();

    if (pin.isEmpty || confirmPin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("من فضلك املأ كل البيانات")),
      );
      return;
    }

    if (pin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الـPIN غير متطابق")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
        'pin': pin,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تحديث الـPIN بنجاح")),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تغيير PIN"), backgroundColor: Colors.red),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "أدخل PIN الجديد"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmPinController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "تأكيد PIN"),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : updatePin,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("تأكيد التغيير"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
