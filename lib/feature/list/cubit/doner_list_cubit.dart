import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doner_list_state.dart';

class DonorsListCubit extends Cubit<DonorsState> {
  DonorsListCubit() : super(DonorsInitial());

  final CollectionReference _donorsCollection =
  FirebaseFirestore.instance.collection('donors');
  Future<void> fetchDonors() async {
    emit(DonorsLoading());
    try {
      final snapshot = await _donorsCollection
          .orderBy('createdAt', descending: true)
          .get();

      final donors = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      emit(DonorsLoaded(donors));
    } catch (e) {
      emit(DonorsError("حدث خطأ أثناء تحميل المتبرعين"));
    }
  }
  Future<void> addDonor({
    required String name,
    required String phone,
    required String bloodType,
  }) async {
    try {
      await _donorsCollection.add({
        'name': name.trim(),
        'phone': phone.trim(),
        'bloodType': bloodType,
        'available': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      fetchDonors();
    } catch (e) {
      emit(DonorsError("حدث خطأ أثناء إضافة المتبرع"));
    }
  }
  Future<void> markAsDonated(String donorId) async {
    try {
      await _donorsCollection.doc(donorId).update({
        'available': false,
        'lastDonationDate': FieldValue.serverTimestamp(),
      });

      fetchDonors();
    } catch (e) {
      emit(DonorsError("حدث خطأ أثناء تسجيل التبرع"));
    }
  }
}
