import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'doner_state.dart';

class DonorCubit extends Cubit<DonorState> {
  DonorCubit() : super(DonorLoading());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> loadDonorData() async {
    emit(DonorLoading());

    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(DonorError('المستخدم غير مسجل الدخول'));
        return;
      }

      final userId = user.uid;

      // جلب آخر تبرع باستخدام query متوافقة مع الـ index
      final donationsQuery = await _firestore
          .collection('donations')
          .where('donorId', isEqualTo: userId)
          .orderBy('date', descending: true) // لازم يكون نفس الترتيب الموجود في index
          .limit(1)
          .get();

      Map<String, dynamic>? lastDonation;
      if (donationsQuery.docs.isNotEmpty) {
        lastDonation = donationsQuery.docs.first.data();
      }

      emit(DonorLoaded(lastDonation: lastDonation));
    } catch (e) {
      emit(DonorError('حدث خطأ أثناء تحميل البيانات: $e'));
    }
  }
}
