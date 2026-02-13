import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../cubit/blood_request_cubit.dart';
import '../cubit/blood_request_state.dart';

class RequestBloodScreen extends StatelessWidget {
  const RequestBloodScreen({super.key});
  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
  Widget sectionCard({required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            title: const Text("طلب دم"),
            backgroundColor: Colors.red,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: BlocConsumer<RequestBloodCubit, RequestBloodState>(
              listener: (context, state) {
                if (state is RequestBloodSentSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تم إرسال الطلب بنجاح ✅")),
                  );
                  Navigator.pop(context);
                } else if (state is RequestBloodError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("حدث خطأ: ${state.error}")),
                  );
                }
              },
              builder: (context, state) {
                if (state is RequestBloodUpdated) {
                  final cubit = context.read<RequestBloodCubit>();
                  return ListView(
                    children: [
                      sectionCard(
                        child: DropdownButtonFormField<String>(
                          decoration: inputDecoration("اختر فصيلة الدم"),
                          value: state.bloodType,
                          items: ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
                              .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) cubit.selectBloodType(val);
                          },
                        ),
                      ),
                      sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "الكمية المطلوبة: ${state.amount.toInt()} ml",
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Slider(
                              value: state.amount,
                              min: 100,
                              max: 500,
                              divisions: 8,
                              activeColor: Colors.red,
                              onChanged: cubit.setAmount,
                            ),
                          ],
                        ),
                      ),

                      sectionCard(
                        child: DropdownButtonFormField<String>(
                          decoration: inputDecoration("اختر المحافظة"),
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
                        ),
                      ),
                      if (state.selectedGovernorate != null)
                        sectionCard(
                          child: DropdownButtonFormField<String>(
                            decoration: inputDecoration("اختر المستشفى"),
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
                          ),
                        ),

                      const SizedBox(height: 16),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: state.isFormValid && !state.isLoading
                              ? () {
                            final uid =
                                FirebaseAuth.instance.currentUser!.uid;
                            cubit.sendRequest(uid);
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: state.isLoading
                              ? const CircularProgressIndicator(
                              color: Colors.white)
                              : const Text("إرسال الطلب",
                              style: TextStyle(fontSize: 18)),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
      ),
    );
  }
}
