import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/list_cubit.dart';
import '../../cubit/list_state.dart';

class PatientsListScreen extends StatelessWidget {
  const PatientsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatientsCubit()..fetchPatients(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("قائمة طلبات المرضي",
                style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          body: BlocBuilder<PatientsCubit, PatientsState>(
            builder: (context, state) {
              if (state is PatientsLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.red));
              }

              if (state is PatientsLoaded) {
                if (state.patients.isEmpty) {
                  return const Center(child: Text("لا توجد طلبات مرضى حالياً"));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.patients.length,
                  itemBuilder: (context, index) {
                    final patient = state.patients[index];
                    String amountText = patient['amount']?.toString() ?? '0';
                    String cleanAmount = double.tryParse(amountText)?.toInt().toString() ?? amountText;

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.red.shade50,
                          child: Text(
                            patient['bloodType']?.toString() ?? '?',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        ),
                        title: Text(
                          patient['hospital']?.toString() ?? "مستشفى غير محدد",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        // المحافظة والكمية المطلوبة
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Text("المحافظة: ${patient['governorate'] ?? '-'}"),
                            const SizedBox(height: 5),
                            Text(
                              "الكمية المطلوبة: $cleanAmount ml",
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return const Center(child: Text("حدث خطأ في تحميل قائمة المرضى"));
            },
          ),
        ),
      ),
    );
  }
}