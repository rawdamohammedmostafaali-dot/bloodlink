import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'staff_home_state.dart';

class StaffHomeCubit extends Cubit<StaffHomeState> {
  StaffHomeCubit() : super(StaffHomeInitial()) {
    fetchData();
  }
  final donorsRef = FirebaseFirestore.instance.collection('donors');
  final requestsRef = FirebaseFirestore.instance.collection('blood_requests');
  void fetchData() async {
    emit(StaffHomeLoading());
    try {
      final donorsSnapshot = await donorsRef.get();
      final requestsSnapshot = await requestsRef.get();
      final bloodRequestsSnapshot = requestsSnapshot.docs;

      emit(StaffHomeLoaded(
        donorsCount: donorsSnapshot.docs.length,
        requestsCount: requestsSnapshot.docs.length,
        bloodRequests: bloodRequestsSnapshot,
      ));
    } catch (e) {
      emit(const StaffHomeError("حدث خطأ أثناء تحميل البيانات"));
    }
  }
  Future<void> updateRequestStatus(String docId, String status) async {
    await requestsRef.doc(docId).update({'status': status});
    fetchData();
  }
}
