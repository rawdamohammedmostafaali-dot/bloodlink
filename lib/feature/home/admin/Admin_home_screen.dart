import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../../list/presentation/ui/donors_list_screen.dart';
import '../../list/presentation/ui/patient_list_screen.dart';
import '../../list/presentation/ui/staff_list_screen.dart';
import '../../staff/presentation/ui/add_staff_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("قطرة دم", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.red.shade700,
        ),
        body: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            if (state is AdminLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFE5E5), Color(0xFFFF7F7F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton(
                        context,
                        title: "إضافة موظف",
                        icon: Icons.person_add,
                        color: Colors.red.shade400,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddStaffScreen())),
                      ),
                      const SizedBox(height: 20),
                      _buildButton(
                        context,
                        title: "قائمة الموظفين",
                        icon: Icons.list_alt,
                        color: Colors.pink.shade400,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffListScreen())),
                      ),
                      const SizedBox(height: 20),
                      _buildButton(
                        context,
                        title: "قائمة المتبرعين",
                        icon: Icons.volunteer_activism,
                        color: Colors.red.shade300,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DonorsListScreen())),
                      ),
                      const SizedBox(height: 20),
                      _buildButton(
                        context,
                        title: "قائمة المرضى",
                        icon: Icons.local_hospital,
                        color: Colors.pink.shade300,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientsListScreen())),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 28, color: Colors.black87),
      label: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 60),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 6,
      ),
    );
  }
}
