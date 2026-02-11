import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/doner_donations_cubit.dart';
import 'cubit/doner_donations_state.dart';

class DonorDonationsScreen extends StatelessWidget {
  const DonorDonationsScreen({super.key});

  // دالة لتحديد Gradient حسب الحالة
  LinearGradient getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const LinearGradient(colors: [Colors.green, Colors.greenAccent]);
      case 'pending':
        return const LinearGradient(colors: [Colors.orange, Colors.deepOrangeAccent]);
      case 'completed':
        return const LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]);
      case 'rejected':
        return const LinearGradient(colors: [Colors.red, Colors.redAccent]);
      default:
        return LinearGradient(
          colors: [Colors.grey, const Color(0xFFe0e0e0)], // تصحيح shade300
        );
    }
  }

  // أيقونة حسب الحالة
  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_top;
      case 'completed':
        return Icons.done_all;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  // دالة لتنسيق التاريخ
  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DonorDonationsCubit()..fetchDonations(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("تبرعاتك السابقة"),
          backgroundColor: Colors.red,
        ),
        body: BlocBuilder<DonorDonationsCubit, DonorDonationsState>(
          builder: (context, state) {
            if (state is DonorDonationsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DonorDonationsError) {
              return Center(child: Text(state.message));
            } else if (state is DonorDonationsLoaded) {
              final donations = state.donations;

              if (donations.isEmpty) {
                return const Center(child: Text("لا توجد تبرعات سابقة"));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<DonorDonationsCubit>().fetchDonations();
                },
                color: Colors.redAccent,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    final data = donations[index];
                    final status = data['status'] ?? '';
                    final gradient = getStatusGradient(status);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: gradient,
                        boxShadow: [
                          BoxShadow(
                            color: gradient.colors.first.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Icon(getStatusIcon(status), color: Colors.white, size: 32),
                        title: Text(
                          "${data['bloodType'] ?? '-'} - ${data['amount'] ?? 0} ml",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "المستشفى: ${data['hospital'] ?? '-'}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              "المحافظة: ${data['governorate'] ?? '-'}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            if (data['date'] != null)
                              Text(
                                "التاريخ: ${formatDate(data['date'].toDate())}",
                                style: const TextStyle(color: Colors.white),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            return Container();
          },
        ),
      ),
    );
  }
}
