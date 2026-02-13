import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'list_state.dart';

class DonorsCubit extends Cubit<DonorsState> {
  DonorsCubit() : super(DonorsInitial());

  List<Map<String, dynamic>> _allDonors = [];

  Future<void> fetchDonors() async {
    emit(DonorsLoading());
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('donors').get();

      _allDonors = snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();

      emit(DonorsLoaded(_allDonors, _allDonors));
    } catch (e) {
      emit(DonorsError("خطأ في تحميل المتبرعين"));
    }
    Future<void> deleteDonor(String id) async {
      await FirebaseFirestore.instance.collection('donors').doc(id).delete();
      fetchDonors();
    }

  }

  void search(String query) {
    final filtered = _allDonors.where((donor) {
      final name = donor['name'].toString().toLowerCase();
      final blood = donor['bloodType'].toString().toLowerCase();
      return name.contains(query.toLowerCase()) ||
          blood.contains(query.toLowerCase());
    }).toList();

    emit(DonorsLoaded(_allDonors, filtered));
  }
}


class PatientsCubit extends Cubit<PatientsState> {
  PatientsCubit() : super(PatientsInitial());

  Future<void> fetchPatients() async {
    emit(PatientsLoading());

    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('patients').get();

      final patients = snapshot.docs
          .map((doc) => doc.data())
          .toList();

      emit(PatientsLoaded(patients));
    } catch (e) {
      emit(PatientsError("حدث خطأ أثناء تحميل المرضى"));
    }
  }
}

