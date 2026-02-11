import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String role,
    required String bloodType,
  }) async {
    if (password != confirmPassword) {
      emit(RegisterFailure(message: "كلمات المرور غير متطابقة"));
      return;
    }

    emit(RegisterLoading());

    try {
      // تسجيل المستخدم في Firebase Auth
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // حفظ بيانات المستخدم في Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'bloodType': bloodType,
        'createdAt': FieldValue.serverTimestamp(),
      });

      emit(RegisterSuccess());
    } on FirebaseAuthException catch (e) {
      emit(RegisterFailure(message: e.message ?? "حدث خطأ ما"));
    } catch (e) {
      emit(RegisterFailure(message: e.toString()));
    }
  }
}
