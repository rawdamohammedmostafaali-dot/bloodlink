import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../widgets/home_slider.dart';
import '../../../../patient/blood_requests/presentation/ui/request_blood_screen.dart';
import '../../../../patient/donation_history/doner_donation_screen.dart';
import '../../../../support/screens/support_screen.dart';
import '../cubit/doner_cubit.dart';

class DonorHomeScreen extends StatelessWidget {
  const DonorHomeScreen({super.key});
  Color getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade600;
      case 'completed':
        return Colors.blue.shade600;
      case 'rejected':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DonorCubit()..loadDonorData(),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFF5F5),
                    Color(0xFFFFE5E5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: BlocBuilder<DonorCubit, DonorState>(
                      builder: (context, state) {
                        if (state is DonorLoading) {
                          return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFE53935),
                              ));
                        } else if (state is DonorError) {
                          return Center(
                              child: Text(state.message,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)));
                        } else if (state is DonorLoaded) {
                          final lastDonation = state.lastDonation;
                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const HomeSlider(),
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF0F0),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: lastDonation != null
                                        ? Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        const Text("آخر تبرع:",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight:
                                                FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        Text(
                                            "فصيلة الدم: ${lastDonation['bloodType']}"),
                                        Text(
                                            "الكمية: ${lastDonation['amount']} ml"),
                                        Text(
                                            "المستشفى: ${lastDonation['hospital']}"),
                                        Text(
                                            "المحافظة: ${lastDonation['governorate']}"),
                                        const SizedBox(height: 4),
                                        Text(
                                          "الحالة: ${lastDonation['status'] ?? 'قيد الانتظار'}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: getStatusColor(
                                                lastDonation['status'] ??
                                                    'pending'),
                                          ),
                                        ),
                                      ],
                                    )
                                        : const Center(
                                      child: Text(
                                        "لا توجد تبرعات سابقة حتى الآن",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                          const RequestBloodScreen()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor:
                                    const Color(0xFFFFC1C1),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12)),
                                  ),
                                  child: const Text("🩸 سجل تبرع جديد",
                                      style: TextStyle(fontSize: 16,color: Colors.black87)),
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
                                  style: ElevatedButton.styleFrom(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor:
                                    const Color(0xFFFFD1D1),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12)),
                                  ),
                                  child: const Text("📜 تبرعاتك السابقة",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black87)),
                                ),
                                const SizedBox(height: 24),

                                Text(
                                  "الخدمات",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    HomeButton(
                                      icon: Icons.history,
                                      text: "تبرعاتك السابقة",
                                      startColor:Colors.pink,
                                      endColor: const Color(0xFFFFC1C1),
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
                                      startColor:  Colors.pink,
                                      endColor: const Color(0xFFFFC1C1),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                              const SupportScreen(
                                                  isAdmin: false)),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 80),
                              ],
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                  Container(
                    height: 60,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFE0E0), Color(0xFFFFC1C1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: const Center(
                        child: Text(
                          "🔔 الإشعارات",
                          style: TextStyle(
                              color: Colors.pink,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color startColor;
  final Color endColor;

  const HomeButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    required this.startColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
