import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../home/doner/presentation/cubit/doner_cubit.dart';
import '../../home/doner/presentation/cubit/doner_state.dart';

class AddDonorScreen extends StatelessWidget {
  const AddDonorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DonorsCubit()..fetchDonors(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("إدارة المتبرعين"),
          backgroundColor: Colors.red,
          actions: [
            Builder(builder: (context) {
              return IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddDonorBottomSheet(context),
              );
            }),
          ],
        ),
        body: const DonorsListWidget(),
      ),
    );
  }

  void _showAddDonorBottomSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String bloodType = "A+";
    final donorsCubit = context.read<DonorsCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // صح
      ),
      builder: (_) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("إضافة متبرع جديد", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  TextFormField(controller: nameController, decoration: const InputDecoration(labelText: "الاسم"), validator: (v) => v!.isEmpty ? "مطلوب" : null),
                  TextFormField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "الهاتف"), validator: (v) => v!.isEmpty ? "مطلوب" : null),
                  DropdownButtonFormField<String>(
                    value: bloodType,
                    items: ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => bloodType = v!),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await donorsCubit.addDonor(name: nameController.text, phone: phoneController.text, bloodType: bloodType);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("حفظ البيانات"),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

class DonorsListWidget extends StatelessWidget {
  const DonorsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DonorsCubit, DonorsState>(
      builder: (context, state) {
        if (state is DonorsLoading) return const Center(child: CircularProgressIndicator());
        if (state is DonorsError) return Center(child: Text(state.message));
        if (state is DonorsLoaded) {
          if (state.donors.isEmpty) return const Center(child: Text("لا يوجد متبرعين حالياً"));

          return ListView.builder(
            itemCount: state.donors.length,
            itemBuilder: (context, index) {
              final doc = state.donors[index];
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.person, color: Colors.white)),
                  title: Text(data['name'] ?? 'بدون اسم'),
                  subtitle: Text("فصيلة: ${data['bloodType']} | هاتف: ${data['phone']}"),
                  trailing: (data['available'] ?? true)
                      ? ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => context.read<DonorsCubit>().markAsDonated(doc.id),
                    child: const Text("تم التبرع", style: TextStyle(color: Colors.white)),
                  )
                      : const Icon(Icons.check_circle, color: Colors.green),
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}