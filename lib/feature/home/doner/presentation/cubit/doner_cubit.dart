import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doner_state.dart';
class DonorCubit extends Cubit<DonorState> {
  DonorCubit() : super(DonorInitial());
  Future<void> loadDonorData() async {
    emit(DonorLoading());
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('donations')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        emit(DonorLoaded(snapshot.docs.first.data()));
      } else {
        emit(const DonorLoaded(null));
      }
    } catch (e) {
      emit(DonorError("فشل تحميل البيانات: ${e.toString()}"));
    }
  }
}
class DonorsCubit extends Cubit<DonorsState> {
  DonorsCubit() : super(DonorsInitial());

  Future<void> fetchDonors() async {
    emit(DonorsLoading());
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('donors')
          .orderBy('createdAt', descending: true)
          .get();
      emit(DonorsLoaded(snapshot.docs));
    } catch (e) {
      emit(const DonorsError("حدث خطأ في تحميل البيانات"));
    }
  }

  Future<void> addDonor({required String name, required String phone, required String bloodType}) async {
    try {
      await FirebaseFirestore.instance.collection('donors').add({
        'name': name,
        'phone': phone,
        'bloodType': bloodType,
        'available': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      fetchDonors();
    } catch (e) {
      emit(const DonorsError("فشل في إضافة المتبرع"));
    }
  }

  Future<void> markAsDonated(String donorId) async {
    try {
      await FirebaseFirestore.instance.collection('donors').doc(donorId).update({
        'available': false,
        'lastDonationDate': FieldValue.serverTimestamp(),
      });
      fetchDonors();
    } catch (e) {
      emit(const DonorsError("فشل في تحديث الحالة"));
    }
  }
}