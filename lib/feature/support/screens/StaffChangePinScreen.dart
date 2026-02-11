import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xffff4b6e), Color(0xffff758f)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({'pin': pin});

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
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text("تغيير PIN"),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _textField(pinController, "أدخل PIN الجديد"),
              const SizedBox(height: 20),
              _textField(confirmPinController, "تأكيد PIN"),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: buttonGradient,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: isLoading ? null : updatePin,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "تأكيد التغيير",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
