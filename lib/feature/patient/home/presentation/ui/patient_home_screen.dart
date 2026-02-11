import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cubit/patient_home_cubit.dart';
import '../cubit/patient_home_state.dart';
import '../../../blood_requests/presentation/ui/request_blood_screen.dart';
import '../../../../support/screens/patient_blood_request_screen.dart';
import '../../../../support/screens/support_screen.dart';
import '../../../../../widgets/home_slider.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

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

  Widget _buildRow(String title, String value) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        const Text("-", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Expanded(
          child: Text("$title: $value", textAlign: TextAlign.right),
        ),
      ],
    );
  }

  Widget _buildRowStatus(String title, String status) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        const Text("-", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            "$title: $status",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: getStatusColor(status),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return BlocProvider(
      create: (_) => PatientCubit()..loadPatientData(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("قطرة دم"),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        body: BlocBuilder<PatientCubit, PatientHomeState>(
          builder: (context, state) {
            if (state is PatientLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PatientError) {
              return Center(child: Text(state.message));
            } else if (state is PatientLoaded) {
              final lastRequest = state.lastRequest;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const HomeSlider(),
                    const SizedBox(height: 16),
                    if (lastRequest != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade50, Colors.red.shade100],
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "آخر طلب دم:",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _buildRow("فصيلة الدم",
                                lastRequest['bloodType'] ?? '-'),
                            const SizedBox(height: 8),
                            _buildRow(
                                "الكمية", "${lastRequest['amount'] ?? '-'} ml"),
                            const SizedBox(height: 8),
                            _buildRow("المستشفى",
                                lastRequest['hospital'] ?? '-'),
                            const SizedBox(height: 8),
                            _buildRow("المحافظة",
                                lastRequest['governorate'] ?? '-'),
                            const SizedBox(height: 8),
                            _buildRowStatus(
                                "الحالة", lastRequest['status'] ?? '-'),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RequestBloodScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          "🩸 اطلب دم",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "الخدمات",
                        style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _HomeButton(
                          icon: Icons.history,
                          text: "طلباتك السابقة",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                  const PatientBloodRequestsScreen()),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _HomeButton(
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

            return const Center(child: Text("لا يوجد بيانات حالياً"));
          },
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _HomeButton(
      {required this.icon, required this.text, required this.onTap});

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
              colors: [Colors.red.shade400, Colors.red.shade200],
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(text,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
