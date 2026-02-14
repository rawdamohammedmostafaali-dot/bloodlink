import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/doner_list_cubit.dart';
import '../../cubit/doner_list_state.dart';

class DonorsListScreen extends StatelessWidget {
  const DonorsListScreen({super.key});

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "لم يتبرع بعد";
    final date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("تأكيد العملية"),
        content: const Text("هل أنتِ متأكدة من تسجيل هذا التبرع؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
            ),
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
      create: (_) => DonorsListCubit()..fetchDonors(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("قائمة المتبرعين"),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF758C), Color(0xFFFF7EB3)],
              ),
            ),
          ),
        ),
        body: BlocConsumer<DonorsListCubit, DonorsState>(
          listener: (context, state) {
            if (state is DonorsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is DonorsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFE91E63)),
              );
            }

            if (state is DonorsLoaded) {
              if (state.donors.isEmpty) {
                return const Center(
                  child: Text("لا يوجد متبرعين حالياً", style: TextStyle(fontSize: 16)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.donors.length,
                itemBuilder: (context, index) {
                  final donor = Map<String, dynamic>.from(state.donors[index]);
                  final name = donor['name'] ?? 'بدون اسم';
                  final bloodType = donor['bloodType'] ?? '-';
                  final lastDonation = _formatDate(donor['lastDonationDate']);
                  final isAvailable = donor['available'] ?? true;
                  final donorId = donor['id'] ?? '';

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isAvailable
                            ? const [Color(0xFFFFF0F5), Color(0xFFFFE4EC)]
                            : [Colors.grey.shade200, Colors.grey.shade100],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFFFFC1C1),
                        child: const Icon(Icons.bloodtype, color: Colors.white),
                      ),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.opacity, size: 16, color: Colors.red),
                            const SizedBox(width: 6),
                            Text("فصيلة الدم: $bloodType"),
                          ]),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.calendar_today, size: 14),
                            const SizedBox(width: 6),
                            Text("آخر تبرع: $lastDonation"),
                          ]),
                        ],
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAvailable ? const Color(0xFFE91E63) : Colors.grey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isAvailable && donorId.isNotEmpty
                            ? () async {
                          final confirmed = await _showConfirmationDialog(context);
                          if (confirmed == true) {
                            await context.read<DonorsListCubit>().markAsDonated(donorId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("تم تسجيل التبرع بنجاح 💖"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                            : null,
                        child: Text(isAvailable ? "تسجيل تبرع" : "غير متاح", style: const TextStyle(color: Colors.white)),
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
    );
  }
}
