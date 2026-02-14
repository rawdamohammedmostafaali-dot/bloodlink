import 'package:flutter_bloc/flutter_bloc.dart';
import 'list_state.dart';

class PatientsCubit extends Cubit<PatientsState> {
  PatientsCubit() : super(PatientsInitial());
  List<String> governorates = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'أسوان',
    'المنصورة',
  ];

  List<Map<String, dynamic>> allPatients = [];
  Future<void> fetchPatients() async {
    emit(PatientsLoading());
    try {
      allPatients = [
        {
          'id': '1',
          'hospital': 'مستشفى النيل',
          'bloodType': 'A+',
          'governorate': 'القاهرة',
          'amount': 500,
          'fulfilled': false,
        },
        {
          'id': '2',
          'hospital': 'مستشفى الجيزة',
          'bloodType': 'O-',
          'governorate': 'الجيزة',
          'amount': 300,
          'fulfilled': false,
        },
      ];

      emit(PatientsLoaded(allPatients));
    } catch (e) {
      emit(PatientsError('حدث خطأ أثناء جلب المرضى'));
    }
  }
  void filterPatients({String? bloodType, String? governorate}) {
    List<Map<String, dynamic>> filtered = allPatients;

    if (bloodType != null && bloodType.isNotEmpty) {
      filtered = filtered.where((p) => p['bloodType'] == bloodType).toList();
    }
    if (governorate != null && governorate.isNotEmpty) {
      filtered = filtered.where((p) => p['governorate'] == governorate).toList();
    }

    emit(PatientsLoaded(filtered));
  }
  Future<void> markAsDonated(String patientId) async {
    int index = allPatients.indexWhere((p) => p['id'] == patientId);
    if (index != -1) {
      allPatients[index]['fulfilled'] = true;
      filterPatients();
    }
  }
}
