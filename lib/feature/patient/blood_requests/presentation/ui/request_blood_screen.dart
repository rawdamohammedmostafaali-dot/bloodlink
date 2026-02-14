import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cubit/blood_request_cubit.dart';
import '../cubit/blood_request_state.dart';

class RequestBloodScreen extends StatelessWidget {
  const RequestBloodScreen({super.key});
  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.red),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.red.shade100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
  Widget sectionCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RequestBloodCubit()..loadGovernorates(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("قطرة دم", style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.red,
            centerTitle: true,
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topLeft,
                colors: [Colors.red.shade50, Colors.white, Colors.grey.shade50],
              ),
            ),
            child: BlocConsumer<RequestBloodCubit, RequestBloodState>(
              listener: (context, state) {
                if (state is RequestBloodSentSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("تم إرسال الطلب بنجاح ✅"),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                } else if (state is RequestBloodError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("حدث خطأ: ${state.error}"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is RequestBloodUpdated) {
                  final cubit = context.read<RequestBloodCubit>();
                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      sectionCard(
                        child: DropdownButtonFormField<String>(
                          decoration: inputDecoration("اختر فصيلة الدم", Icons.bloodtype),
                          value: state.bloodType,
                          items: ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
                              .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) cubit.selectBloodType(val);
                          },
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.red),
                          iconSize: 30,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "الكمية المطلوبة",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "${state.amount.toInt()} ml",
                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Slider(
                              value: state.amount,
                              min: 100,
                              max: 500,
                              divisions: 4,
                              activeColor: Colors.red,
                              inactiveColor: Colors.red.shade100,
                              onChanged: cubit.setAmount,
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("100ml", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text("500ml", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      sectionCard(
                        child: DropdownButtonFormField<String>(
                          decoration: inputDecoration("اختر المحافظة", Icons.location_city),
                          value: state.selectedGovernorate,
                          items: state.governorates
                              .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g),
                          ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) cubit.selectGovernorate(val);
                          },
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.red),
                          iconSize: 30,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      if (state.selectedGovernorate != null)
                        sectionCard(
                          child: DropdownButtonFormField<String>(
                            decoration: inputDecoration("اختر المستشفى", Icons.local_hospital),
                            value: state.selectedHospital,
                            items: state.hospitals
                                .map((h) => DropdownMenuItem(
                              value: h,
                              child: Text(h),
                            ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) cubit.selectHospital(val);
                            },
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.red),
                            iconSize: 30,
                            alignment: Alignment.centerLeft,
                          ),
                        ),

                      const SizedBox(height: 30),
                      Container(
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            if (state.isFormValid)
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: state.isFormValid && !state.isLoading
                              ? () {
                            final uid = FirebaseAuth.instance.currentUser!.uid;
                            cubit.sendRequest(uid);
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            disabledBackgroundColor: Colors.red.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: state.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "إرسال طلب ",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator(color: Colors.red));
              },
            ),
          ),
        ),
      ),
    );
  }
}
