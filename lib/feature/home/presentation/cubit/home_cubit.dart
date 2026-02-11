import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // تحميل بيانات المستخدم
  Future<void> loadUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(HomeError("المستخدم غير مسجل"));
      return;
    }

    emit(HomeLoading());

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        emit(HomeError("لا توجد بيانات للمستخدم"));
        return;
      }

      final data = doc.data()!;
      final bloodType = data['bloodType'] ?? 'غير محدد';
      DateTime? lastDonationDate;
      if (data['lastDonationDate'] != null) {
        lastDonationDate = (data['lastDonationDate'] as Timestamp).toDate();
      }
      final role = data['role'] ?? 'patient';

      emit(HomeLoaded(
        bloodType: bloodType,
        lastDonationDate: lastDonationDate,
        role: role,
        userData: data,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
