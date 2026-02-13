import 'package:bloodlink/feature/patient/dashboard/cubit/patient_dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientDashboardCubit extends Cubit<PatientDashboardState> {
  PatientDashboardCubit() : super(PatientDashboardInitial());

  Future<void> loadRequests() async {
    emit(PatientDashboardLoading());

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('blood_requests')
          .where('patientId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      final requests = snapshot.docs
          .map((doc) => doc.data())
          .toList();

      emit(PatientDashboardLoaded(requests));
    } catch (e) {
      emit(PatientDashboardError("حصل خطأ"));
    }
  }
}
