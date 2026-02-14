import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'list_state.dart';

class PatientsCubit extends Cubit<PatientsState> {
  PatientsCubit() : super(PatientsInitial());

  get governorates => null;
  void fetchPatients() async {
    try {
      emit(PatientsLoading());
      var snapshot = await FirebaseFirestore.instance
          .collection('blood_request')
          .get();
      List<Map<String, dynamic>> patients = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;

        return data;
      }).toList();

      emit(PatientsLoaded(patients));
    } catch (e) {
      emit(PatientsError("فشل في جلب البيانات: ${e.toString()}"));
    }
  }

  void filterPatients({required String bloodType, required String governorate}) {}

  Future<void> markAsDonated(patientId) async {}
}
