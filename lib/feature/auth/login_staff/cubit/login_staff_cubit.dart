import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class StaffState {}
class StaffInitial extends StaffState {}
class StaffLoading extends StaffState {}
class StaffSuccess extends StaffState {
  final String staffName;
  StaffSuccess(this.staffName);
}
class StaffError extends StaffState {
  final String message;
  StaffError(this.message);
}

class StaffCubit extends Cubit<StaffState> {
  StaffCubit() : super(StaffInitial());

  Future<void> login(String pin) async {
    if (pin.isEmpty) {
      emit(StaffError("ادخلي PIN"));
      return;
    }
    emit(StaffLoading());
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('pin', isEqualTo: pin)
          .where('role', isEqualTo: 'staff')
          .get();

      if (snapshot.docs.isEmpty) {
        emit(StaffError("PIN غير صحيح"));
      } else {
        final staffName = snapshot.docs.first['name'] ?? "الموظف";
        emit(StaffSuccess(staffName));
      }
    } catch (e) {
      emit(StaffError("حدث خطأ، حاول مرة أخرى"));
    }
  }
}
