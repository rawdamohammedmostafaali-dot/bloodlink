import 'package:flutter_bloc/flutter_bloc.dart';
import 'blood_request_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestBloodCubit extends Cubit<RequestBloodState> {
  RequestBloodCubit() : super(RequestBloodUpdated(governorates: [], hospitals: []));
  final List<Map<String, dynamic>> governorates = [
    {"name": "القاهرة", "hospitals": ["مستشفى الدم الرئيسي", "مستشفى النيل التخصصي", "مركز الدم السادس من أكتوبر"]},
    {"name": "الجيزة", "hospitals": ["مستشفى الجيزة العام", "مركز الدم الجيزة", "مستشفى الملك فيصل"]},
    {"name": "الإسكندرية", "hospitals": ["مستشفى سموحة", "مستشفى الإسكندرية العام", "مركز الدم الإسكندرية"]},
    {"name": "الدقهلية", "hospitals": ["مستشفى المنصورة العام", "مستشفى دم المنصورة"]},
    {"name": "البحيرة", "hospitals": ["مستشفى دمنهور المركزي", "مستشفى أبو حمص"]},
    {"name": "المنوفية", "hospitals": ["مستشفى شبين الكوم العام", "مركز الدم المنوفية"]},
    {"name": "الغربية", "hospitals": ["مستشفى طنطا العام", "مركز الدم الغربية"]},
    {"name": "القليوبية", "hospitals": ["مستشفى بنها العام", "مركز الدم القليوبية"]},
    {"name": "الشرقية", "hospitals": ["مستشفى الزقازيق العام", "مركز الدم الشرقية"]},
    {"name": "السويس", "hospitals": ["مستشفى السويس العام", "مركز الدم السويس"]},
    {"name": "الإسماعيلية", "hospitals": ["مستشفى الإسماعيلية العام", "مركز الدم الإسماعيلية"]},
    {"name": "بني سويف", "hospitals": ["مستشفى بني سويف العام", "مركز الدم بني سويف"]},
    {"name": "الفيوم", "hospitals": ["مستشفى الفيوم العام", "مركز الدم الفيوم"]},
    {"name": "المنيا", "hospitals": ["مستشفى المنيا العام", "مركز الدم المنيا"]},
    {"name": "أسيوط", "hospitals": ["مستشفى أسيوط العام", "مركز الدم أسيوط"]},
    {"name": "سوهاج", "hospitals": ["مستشفى سوهاج العام", "مركز الدم سوهاج"]},
    {"name": "قنا", "hospitals": ["مستشفى قنا العام", "مركز الدم قنا"]},
    {"name": "الأقصر", "hospitals": ["مستشفى الأقصر العام", "مركز الدم الأقصر"]},
    {"name": "أسوان", "hospitals": ["مستشفى أسوان العام", "مركز الدم أسوان"]},
    {"name": "البحر الأحمر", "hospitals": ["مستشفى الغردقة العام", "مركز الدم البحر الأحمر"]},
    {"name": "الوادي الجديد", "hospitals": ["مستشفى الخارجة العام", "مركز الدم الوادي الجديد"]},
    {"name": "شمال سيناء", "hospitals": ["مستشفى العريش العام", "مركز الدم شمال سيناء"]},
    {"name": "جنوب سيناء", "hospitals": ["مستشفى شرم الشيخ", "مركز الدم جنوب سيناء"]},
    {"name": "مطروح", "hospitals": ["مستشفى مرسى مطروح", "مركز الدم مطروح"]}
  ];

  void loadGovernorates() {
    emit(RequestBloodUpdated(
      governorates: governorates.map((g) => g['name'] as String).toList(),
      hospitals: [],
    ));
  }

  void selectGovernorate(String governorateName) {
    final hospitalsList = governorates
        .firstWhere((g) => g['name'] == governorateName)['hospitals'] as List<String>;

    emit((state as RequestBloodUpdated).copyWith(
      selectedGovernorate: governorateName,
      selectedHospital: null,
      hospitals: hospitalsList,
    ));
  }

  void selectHospital(String hospitalName) {
    emit((state as RequestBloodUpdated).copyWith(selectedHospital: hospitalName));
  }

  void selectBloodType(String type) {
    emit((state as RequestBloodUpdated).copyWith(bloodType: type));
  }

  void setAmount(double value) {
    emit((state as RequestBloodUpdated).copyWith(amount: value));
  }

  Future<void> sendRequest(String uid) async {
    try {
      emit((state as RequestBloodUpdated).copyWith(isLoading: true));
      await FirebaseFirestore.instance.collection('blood_requests').add({
        "userId": uid,
        "bloodType": (state as RequestBloodUpdated).bloodType,
        "amount": (state as RequestBloodUpdated).amount,
        "governorate": (state as RequestBloodUpdated).selectedGovernorate,
        "hospital": (state as RequestBloodUpdated).selectedHospital,
        "timestamp": FieldValue.serverTimestamp(),
      });

      emit(RequestBloodSentSuccess());
    } catch (e) {
      emit(RequestBloodError(e.toString()));
    }
  }
}
