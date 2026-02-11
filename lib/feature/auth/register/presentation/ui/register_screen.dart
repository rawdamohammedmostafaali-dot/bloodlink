import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../login/presentation/ui/login_screen.dart';
import '../../cubit/register_cubit.dart';
import '../../cubit/register_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String role = "donor";
  String? bloodType;
  final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  Widget build(BuildContext context) {
    const buttonGradient = LinearGradient(
      colors: [Color(0xffff4b6e), Color(0xffff758f)],
    );

    return BlocProvider(
      create: (_) => RegisterCubit(),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffffc1cc), Color(0xffffe0e6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: BlocConsumer<RegisterCubit, RegisterState>(
              listener: (context, state) {
                if (state is RegisterFailure) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.message)));
                }
                if (state is RegisterSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          "إنشاء حساب",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _field(nameController, "الاسم"),
                            _field(emailController, "الإيميل"),
                            _field(phoneController, "الموبايل"),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: bloodType,
                              decoration: InputDecoration(
                                labelText: "فصيلة الدم",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              items: bloodTypes
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (val) => setState(() => bloodType = val),
                            ),
                            const SizedBox(height: 16),
                            _password(passwordController, "كلمة المرور"),
                            _password(confirmPasswordController, "تأكيد كلمة المرور"),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Radio(
                                  value: "donor",
                                  groupValue: role,
                                  onChanged: (v) => setState(() => role = v!),
                                ),
                                const Text("متبرع"),
                                Radio(
                                  value: "patient",
                                  groupValue: role,
                                  onChanged: (v) => setState(() => role = v!),
                                ),
                                const Text("مريض"),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: buttonGradient,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: state is RegisterLoading
                                    ? null
                                    : () {
                                  if (bloodType == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("اختاري فصيلة الدم")),
                                    );
                                    return;
                                  }
                                  context.read<RegisterCubit>().register(
                                    name: nameController.text.trim(),
                                    email: emailController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    password: passwordController.text.trim(),
                                    confirmPassword:
                                    confirmPasswordController.text.trim(),
                                    role: role,
                                    bloodType: bloodType!,
                                  );
                                },
                                child: state is RegisterLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                  "إنشاء حساب",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }

  Widget _password(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }
}
