import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'patient_home_state.dart';

class PatientCubit extends Cubit<PatientHomeState> {
  PatientCubit() : super(PatientLoading());

  final _firestore = FirebaseFirestore.instance;
  Future<void> loadPatientData() async {
    emit(PatientLoading());

    try {
      final uid = "PUT_PATIENT_UID_HERE";
      final querySnapshot = await _firestore
          .collection('blood_requests')
          .where('patientId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final lastRequest = querySnapshot.docs.first.data();
        emit(PatientLoaded(lastRequest: lastRequest));
      } else {
        emit(const PatientLoaded(lastRequest: null));
      }
    } catch (e) {
      emit(PatientError("حدث خطأ أثناء تحميل البيانات: $e"));
    }
  }
}
