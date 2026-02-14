import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/list_state.dart';
import '../../cubit/patients_cubit.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  String selectedBloodType = 'الكل';
  String selectedGovernorate = 'الكل';

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("تأكيد العملية"),
        content: const Text("هل أنتِ متأكدة من تسجيل هذا التبرع؟"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("تأكيد"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatientsCubit()..fetchPatients(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              "قائمة طلبات المرضى",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: BlocBuilder<PatientsCubit, PatientsState>(
                  builder: (context, state) {
                    final cubit = context.read<PatientsCubit>();
                    return Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedBloodType,
                            decoration: const InputDecoration(
                              labelText: "فصيلة الدم",
                              border: OutlineInputBorder(),
                            ),
                            items: ['الكل', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                                .map((type) =>
                                DropdownMenuItem(value: type, child: Text(type)))
                                .toList(),
                            onChanged: (value) {
                              setState(() => selectedBloodType = value ?? 'الكل');
                              cubit.filterPatients(
                                  bloodType: selectedBloodType,
                                  governorate: selectedGovernorate);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedGovernorate,
                            decoration: const InputDecoration(
                              labelText: "المحافظة",
                              border: OutlineInputBorder(),
                            ),
                            items: cubit.governorates
                                .map((gov) => DropdownMenuItem(value: gov, child: Text(gov)))
                                .toList(),
                            onChanged: (value) {
                              setState(() => selectedGovernorate = value ?? 'الكل');
                              cubit.filterPatients(
                                  bloodType: selectedBloodType,
                                  governorate: selectedGovernorate);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: BlocConsumer<PatientsCubit, PatientsState>(
                  listener: (context, state) {
                    if (state is PatientsError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is PatientsLoading) {
                      return const Center(
                          child: CircularProgressIndicator(color: Colors.red));
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
                          String cleanAmount =
                              double.tryParse(amountText)?.toInt().toString() ?? amountText;
                          final fulfilled = patient['fulfilled'] ?? false;
                          final patientId = patient['id'] ?? '';

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(15),
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.red.shade50,
                                child: Text(
                                  patient['bloodType']?.toString() ?? '?',
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22),
                                ),
                              ),
                              title: Text(
                                  patient['hospital']?.toString() ??
                                      "مستشفى غير محدد",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 18)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text("المحافظة: ${patient['governorate'] ?? '-'}"),
                                  const SizedBox(height: 5),
                                  Text("الكمية المطلوبة: $cleanAmount ml",
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    fulfilled ? Colors.grey : Colors.red,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12))),
                                onPressed: fulfilled || patientId.isEmpty
                                    ? null
                                    : () async {
                                  final confirmed =
                                  await _showConfirmationDialog(context);
                                  if (confirmed == true) {
                                    await context
                                        .read<PatientsCubit>()
                                        .markAsDonated(patientId);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "تم تسجيل التبرع بنجاح 💖"),
                                          backgroundColor: Colors.green),
                                    );
                                  }
                                },
                                child: Text(fulfilled ? "تم التبرع" : "تأكيد التبرع",
                                    style: const TextStyle(color: Colors.white)),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
