import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doner_donations_state.dart';

class DonorDonationsCubit extends Cubit<DonorDonationsState> {
  DonorDonationsCubit() : super(DonorDonationsLoading());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchDonations({String donorId = 'XyGzTM1qxlUQNRdEl9QR0fu8uai2'}) async {
    emit(DonorDonationsLoading());

    try {
      final querySnapshot = await _firestore
          .collection('donations')
          .where('donorId', isEqualTo: donorId)
          .orderBy('date', descending: true) // لو Firebase طلب index هيظهر رابط
          .limit(50)
          .get();

      final donations = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      emit(DonorDonationsLoaded(donations: donations));
    } catch (e) {
      emit(DonorDonationsError(message: "حدث خطأ أثناء تحميل التبرعات: $e"));
    }
  }
}
