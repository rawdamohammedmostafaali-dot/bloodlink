import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit() : super(AdminInitial());
  Future<void> getAdminStats() async {
    emit(AdminLoading());
    try {
      final staffQuery = await FirebaseFirestore.instance.collection('staff').get();
      final donorsQuery = await FirebaseFirestore.instance.collection('donors').get();

      emit(AdminLoaded(
        staffCount: staffQuery.docs.length,
        donorsCount: donorsQuery.docs.length,
      ));
    } catch (e) {
      emit(const AdminError("فشل في تحميل بيانات لوحة التحكم"));
    }
  }
}
