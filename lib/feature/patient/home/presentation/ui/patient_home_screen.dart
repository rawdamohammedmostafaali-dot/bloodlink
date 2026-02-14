import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/patient_home_cubit.dart';
import '../cubit/patient_home_state.dart';
import '../../../blood_requests/presentation/ui/request_blood_screen.dart';
import '../../../../support/screens/patient_blood_request_screen.dart';
import '../../../../support/screens/support_screen.dart';
import '../../../../../widgets/home_slider.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
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
  Widget _buildInfoRow(IconData icon, String title, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 20, color: Colors.redAccent),
          const SizedBox(width: 10),
          Text(
            "$title:",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? Colors.black87,
                fontWeight: valueColor != null ? FontWeight.bold : FontWeight
                    .normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      PatientCubit()
        ..loadPatientData(),
      child: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          title: const Text("قطرة دم", style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.red,
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.red.shade50,
                Colors.white,
                Colors.grey.shade100,
              ],
            ),
          ),
          child: BlocBuilder<PatientCubit, PatientHomeState>(
            builder: (context, state) {
              if (state is PatientLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.red));
              } else if (state is PatientError) {
                return Center(child: Text(state.message));
              } else if (state is PatientLoaded) {
                final lastRequest = state.lastRequest;
                final userData = state.userData;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05),
                                blurRadius: 15)
                          ],
                        ),
                        child: const HomeSlider(),
                      ),

                      const SizedBox(height: 25),

                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white),
                          boxShadow: [
                            BoxShadow(color: Colors.red.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.red.shade100, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.red.shade50,
                                child: const Icon(
                                    Icons.person, size: 38, color: Colors.red),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  " ${userData?['name'] ?? 'أهلاً بك'}",
                                  style: const TextStyle(fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.bloodtype, size: 16,
                                        color: Colors.red),
                                    const SizedBox(width: 4),
                                    Text(
                                      "فصيلة دمك: ${userData?['bloodType'] ??
                                          'غير محددة'}",
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),
                      if (lastRequest != null) ...[
                        const Padding(
                          padding: EdgeInsets.only(right: 8, bottom: 10),
                          child: Text(
                            "آخر طلب دم لك",
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04),
                                  blurRadius: 20)
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                  Icons.bloodtype_outlined, "الفصيلة المطلوبة",
                                  lastRequest['bloodType'] ?? '-'),
                              _buildInfoRow(Icons.water_drop_outlined, "الكمية",
                                  "${lastRequest['amount'] ?? '-'} ml"),
                              _buildInfoRow(Icons.apartment_rounded, "المستشفى",
                                  lastRequest['hospital'] ?? '-'),
                              _buildInfoRow(
                                  Icons.location_on_outlined, "المحافظة",
                                  lastRequest['governorate'] ?? '-'),
                              const Divider(height: 25, thickness: 0.5),
                              _buildInfoRow(
                                Icons.stars_rounded,
                                "حالة الطلب الآن",
                                lastRequest['status'] ?? '-',
                                valueColor: getStatusColor(
                                    lastRequest['status'] ?? ''),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.red.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 5))
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RequestBloodScreen()),
                            );
                          },
                          icon: const Icon(
                              Icons.add_circle_outline, color: Colors.white),
                          label: const Text("إنشاء طلب دم جديد",
                              style: TextStyle(fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink.shade900,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),
                      const Padding(
                        padding: EdgeInsets.only(right: 8, bottom: 12),
                        child: Text(
                          "الخدمات",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          _HomeButton(
                            icon: Icons.history_edu_rounded,
                            text: "سجل الطلبات",
                            color1: Colors.red.shade900,
                            color2: Colors.pink.shade900,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (
                                    _) => const PatientBloodRequestsScreen()),
                              );
                            },
                          ),
                          const SizedBox(width: 15),
                          _HomeButton(
                            icon: Icons.question_answer_rounded,
                            text: "الدعم الفني",
                            color1: Colors.red.shade900,
                            color2: Colors.pink.shade900,
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
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              }
              return const Center(child: Text("لا توجد بيانات حالياً"));
            },
          ),
        ),
      ),
    );
  }
}
class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color1;
  final Color color2;
  final VoidCallback onTap;

  const _HomeButton({
    required this.icon,
    required this.text,
    required this.color1,
    required this.color2,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color1, color2], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: color2.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 8),
              Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
