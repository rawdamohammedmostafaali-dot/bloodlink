import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_staff_state.dart';

class AddStaffCubit extends Cubit<AddStaffState> {
  AddStaffCubit() : super(AddStaffInitial());

  Future<void> addStaff({
    required String name,
    required String pin,
  }) async {
    if (name.isEmpty || pin.isEmpty) {
      emit(AddStaffError("ادخلي الاسم و PIN"));
      return;
    }

    emit(AddStaffLoading());

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('pin', isEqualTo: pin)
          .get();

      if (snapshot.docs.isNotEmpty) {
        emit(AddStaffError("هذا PIN مستخدم بالفعل"));
        return;
      }

      await FirebaseFirestore.instance.collection('users').add({
        "name": name,
        "pin": pin,
        "role": "staff",
      });

      emit(AddStaffSuccess());
    } catch (e) {
      emit(AddStaffError("حدث خطأ، حاول مرة أخرى"));
    }
  }
}
