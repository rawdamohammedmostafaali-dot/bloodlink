import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/list_cubit.dart';
import '../../cubit/list_state.dart';

class DonorsListScreen extends StatelessWidget {
  const DonorsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DonorsCubit()..fetchDonors(),
      child: Scaffold(
        appBar: AppBar(title: const Text("قائمة المتبرعين")),
        body: BlocBuilder<DonorsCubit, DonorsState>(
          builder: (context, state) {
            if (state is DonorsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DonorsError) {
              return Center(child: Text(state.message));
            }

            if (state is DonorsLoaded) {
              if (state.donors.isEmpty) {
                return const Center(child: Text("لا يوجد متبرعين"));
              }

              return ListView.builder(
                itemCount: state.donors.length,
                itemBuilder: (context, index) {
                  final donor = state.donors[index];
                  return ListTile(
                    leading: const Icon(Icons.volunteer_activism),
                    title: Text(donor['name'] ?? 'بدون اسم'),
                    subtitle: Text(
                        "فصيلة الدم: ${donor['bloodType'] ?? '-'}"),
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
