import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../home/staff/presentation/ui/StaffHomeScreen.dart';
class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key});
  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}
class _StaffLoginScreenState extends State<StaffLoginScreen> {
  final pinController = TextEditingController();
  bool isLoading = false;
  String? error;
  bool obscurePin = true;

  Future<void> loginStaff() async {
    final pin = pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => error = "ادخلي PIN");
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
          .where('role', isEqualTo: 'staff')
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() => error = "PIN غير صحيح");
      } else {
        final staffName = snapshot.docs.first['name'] ?? "الموظف";
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => StaffHomeScreen(staffName: staffName)),
        );
      }
    } catch (e) {
      setState(() => error = "حدث خطأ، حاول مرة أخرى");
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration customDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.purple),
      filled: true,
      fillColor: Colors.purple.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      suffixIcon: IconButton(
        icon: Icon(
          obscurePin ? Icons.visibility_off : Icons.visibility,
          color: Colors.purple,
        ),
        onPressed: () => setState(() => obscurePin = !obscurePin),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7B1FA2), Color(0xFFE040FB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 15,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                shadowColor: Colors.black26,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.badge, size: 80, color: Colors.purple),
                      const SizedBox(height: 15),
                      const Text(
                        "تسجيل دخول الموظف",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple),
                      ),
                      const SizedBox(height: 25),
                      TextField(
                        controller: pinController,
                        obscureText: obscurePin,
                        keyboardType: TextInputType.number,
                        decoration: customDecoration("PIN الموظف", Icons.lock_outline),
                      ),
                      const SizedBox(height: 20),
                      if (error != null)
                        Text(error!,
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : loginStaff,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "دخول",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
