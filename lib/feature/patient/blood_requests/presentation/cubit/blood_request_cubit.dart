import 'package:flutter_bloc/flutter_bloc.dart';
import 'blood_request_state.dart';

class RequestBloodCubit extends Cubit<RequestBloodState> {
  RequestBloodCubit() : super(RequestBloodLoading());

  /// خريطة المحافظات مع المستشفيات
  final Map<String, List<String>> governoratesHospitals = {
    'القاهرة': ['القصر العيني', 'دار الفؤاد', 'مستشفى الهلال', 'مستشفى النيل', 'الدمرداش', 'الشروق'],
    'الجيزة': ['6 أكتوبر', 'الهرم', 'الشيخ زايد', 'الجيزة العام', 'الحوامدية'],
    'الإسكندرية': ['شرق الإسكندرية', 'كليوباترا', 'الجامعي', 'العامرية', 'برج العرب'],
    'القليوبية': ['القليوبية العام', 'بنها', 'شبرا الخيمة'],
    'الشرقية': ['الزقازيق العام', 'بلبيس', 'العاشر من رمضان', 'أبوحماد'],
    'الدقهلية': ['المنصورة العام', 'دكرنس', 'طلخا'],
    'المنوفية': ['شبين الكوم', 'السادات', 'منوف'],
    'البحيرة': ['دمنهور', 'رشيد', 'كفر الدوار'],
    'الغربية': ['طنطا العام', 'المحلة الكبرى', 'كفر الزيات'],
    'كفر الشيخ': ['كفر الشيخ العام', 'برج البرلس'],
    'الفيوم': ['الفيوم العام', 'سنورس'],
    'بني سويف': ['بني سويف العام', 'اهناسيا'],
    'المنيا': ['المنيا العام', 'مغاغة'],
    'أسيوط': ['أسيوط الجامعي', 'أسيوط العام'],
    'سوهاج': ['سوهاج العام', 'أخميم', 'جرجا'],
    'قنا': ['قنا العام', 'نجع حمادي'],
    'الأقصر': ['الأقصر العام', 'إسنا'],
    'أسوان': ['أسوان العام', 'كوم أمبو'],
    'بورسعيد': ['بورسعيد العام'],
    'دمياط': ['دمياط العام', 'رأس البر'],
    'الإسماعيلية': ['الإسماعيلية العام', 'بورسعيد'],
    'شمال سيناء': ['العريش', 'رفح'],
    'جنوب سيناء': ['شرم الشيخ', 'دهب'],
    'الوادي الجديد': ['الخارجة', 'باريس'],
    'مطروح': ['مرسى مطروح', 'الحمام'],
    'البحر الأحمر': ['الغردقة', 'مرسى علم']
  };

  /// تحميل المحافظات
  void loadGovernorates() async {
    await Future.delayed(const Duration(milliseconds: 300));
    emit(RequestBloodUpdated(governorates: governoratesHospitals.keys.toList()));
  }

  /// اختيار فصيلة الدم
  void selectBloodType(String type) {
    final currentState = state as RequestBloodUpdated;
    emit(currentState.copyWith(bloodType: type));
  }

  /// تعديل كمية الدم
  void setAmount(double value) {
    final currentState = state as RequestBloodUpdated;
    emit(currentState.copyWith(amount: value));
  }

  /// اختيار المحافظة
  void selectGovernorate(String gov) {
    final currentState = state as RequestBloodUpdated;
    emit(currentState.copyWith(
      selectedGovernorate: gov,
      selectedHospital: null,
      hospitals: [],
    ));
  }

  /// تحميل المستشفيات حسب المحافظة
  void loadHospitals(String governorate) async {
    final currentState = state as RequestBloodUpdated;
    await Future.delayed(const Duration(milliseconds: 200));

    List<String> hospitals = governoratesHospitals[governorate] ?? ['مستشفى عام'];

    emit(currentState.copyWith(
      hospitals: hospitals,
      selectedHospital: null,
    ));
  }

  /// اختيار المستشفى
  void selectHospital(String hospital) {
    final currentState = state as RequestBloodUpdated;
    emit(currentState.copyWith(selectedHospital: hospital));
  }

  /// إرسال الطلب
  void sendRequest(String uid) async {
    var currentState = state as RequestBloodUpdated;
    emit(currentState.copyWith(isLoading: true));

    try {
      await Future.delayed(const Duration(seconds: 1)); // محاكاة إرسال الطلب
      emit(RequestBloodSentSuccess());
    } catch (e) {
      emit(RequestBloodError(e.toString()));
    }
  }
}
