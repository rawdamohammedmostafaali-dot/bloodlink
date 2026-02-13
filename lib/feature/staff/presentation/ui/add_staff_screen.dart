import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/add_staff_cubit.dart';
import '../../cubit/add_staff_state.dart';

class AddStaffScreen extends StatefulWidget {
  AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final nameController = TextEditingController();

  final pinController = TextEditingController();

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.red),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddStaffCubit(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xfff44336), Color(0xffff7961)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: BlocConsumer<AddStaffCubit, AddStaffState>(
              listener: (context, state) {
                if (state is AddStaffSuccess) {
                  nameController.clear();
                  pinController.clear();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("تم إضافة الموظف بنجاح"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final cubit = context.read<AddStaffCubit>();

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.red.shade50,
                              child: const Icon(
                                Icons.person_add_alt_1,
                                size: 45,
                                color: Colors.red,
                              ),
                            ),

                            const SizedBox(height: 20),

                            const Text(
                              "إضافة موظف جديد",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "أدخل بيانات الموظف",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),

                            const SizedBox(height: 28),

                            TextField(
                              controller: nameController,
                              decoration: inputDecoration(
                                "اسم الموظف",
                                Icons.person,
                              ),
                            ),

                            const SizedBox(height: 18),

                            TextField(
                              controller: pinController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              decoration: inputDecoration(
                                "PIN السري",
                                Icons.lock,
                              ),
                            ),

                            const SizedBox(height: 20),

                            if (state is AddStaffError)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error,
                                        color: Colors.red),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        state.message,
                                        style: const TextStyle(
                                            color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 26),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: state is AddStaffLoading
                                    ? null
                                    : () {
                                  cubit.addStaff(
                                    name: nameController.text,
                                    pin: pinController.text,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: state is AddStaffLoading
                                    ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Text(
                                  "إضافة الموظف",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
