import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'doner_dashboard_state.dart';
class DonorDashboardCubit extends Cubit<DonorDashboardState> {
  DonorDashboardCubit() : super(DonorDashboardInitial());
  Future<void> loadAvailableRequests() async {
    emit(DonorDashboardLoading());

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('blood_request')
          .where('status', isEqualTo: 'pending')
         .get();

      final requests = snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      emit(DonorDashboardLoaded(requests));
    } catch (e) {
      print(e.toString());
      emit(DonorDashboardError("حصل خطأ في تحميل الطلبات"));
    }
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance
          .collection('blood_request')
          .doc(requestId)
          .update({
        'status': 'accepted',
        'donorId': uid,
      });
      loadAvailableRequests();
    } catch (e) {
      emit(DonorDashboardError("فشل قبول الطلب"));
    }
  }
}