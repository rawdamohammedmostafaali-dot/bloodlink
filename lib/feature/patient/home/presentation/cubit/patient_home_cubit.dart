import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ضيفي ده عشان نجيب الـ UID تلقائي
import 'patient_home_state.dart';

class PatientCubit extends Cubit<PatientHomeState> {
  PatientCubit() : super(PatientLoading());

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> loadPatientData() async {
    emit(PatientLoading());

    try {
      final uid = _auth.currentUser?.uid;


      if (uid == null) {
        emit(const PatientError("لم يتم العثور على مستخدم"));
        return;
      }
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data();
      final querySnapshot = await _firestore
          .collection('blood_requests')
          .where('patientId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      Map<String, dynamic>? lastRequest;
      if (querySnapshot.docs.isNotEmpty) {
        lastRequest = querySnapshot.docs.first.data();
      }
      emit(PatientLoaded(userData: userData, lastRequest: lastRequest));

    } catch (e) {
      emit(PatientError("حدث خطأ أثناء تحميل البيانات: $e"));
    }
  }
}