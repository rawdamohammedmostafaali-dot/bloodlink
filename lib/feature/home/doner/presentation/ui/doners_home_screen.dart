/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../patient/blood_requests/presentation/ui/request_blood_screen.dart';
import '../../../../patient/donation_history/doner_donation_screen.dart';
import '../../../../support/screens/support_screen.dart';
import '../../../../../widgets/home_slider.dart';
import '../cubit/doner_cubit.dart';
import '../cubit/doner_state.dart';

class DonorHomeScreen extends StatelessWidget {
  const DonorHomeScreen({super.key});

  Color getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DonorCubit()..loadDonorData(),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<DonorCubit, DonorState>(
            builder: (context, state) {
              if (state is DonorLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.red),
                );
              }

              if (state is DonorError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                );
              }

              if (state is DonorLoaded) {
                final lastDonation = state.lastDonation;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const HomeSlider(),
                      const SizedBox(height: 16),

                      /// آخر تبرع
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: lastDonation == null
                            ? const Center(
                          child: Text(
                            "لا توجد تبرعات سابقة",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              "آخر تبرع",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text("فصيلة الدم: ${lastDonation['bloodType']}"),
                            Text("الكمية: ${lastDonation['amount']} ml"),
                            Text("المستشفى: ${lastDonation['hospital']}"),
                            Text("المحافظة: ${lastDonation['governorate']}"),
                            const SizedBox(height: 4),
                            Text(
                              "الحالة: ${lastDonation['status'] ?? 'pending'}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: getStatusColor(
                                  lastDonation['status'] ?? 'pending',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RequestBloodScreen()),
                          );
                        },
                        child: const Text("🩸 سجل تبرع جديد"),
                      ),

                      const SizedBox(height: 12),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                const DonorDonationsScreen()),
                          );
                        },
                        child: const Text("📜 تبرعاتك السابقة"),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          HomeButton(
                            icon: Icons.history,
                            text: "تبرعاتك",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                    const DonorDonationsScreen()),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          HomeButton(
                            icon: Icons.support_agent,
                            text: "الدعم",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                    const SupportScreen(isAdmin: false)),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const HomeButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: const Color(0xFFFFC1C1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(
                text,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/