import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> login({
    required String email,
    required String password, required String role,
  }) async {
    emit(AuthLoading());

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!doc.exists) {
        emit(AuthError(message: "المستخدم غير موجود"));
        return;
      }

      final role = doc.data()?['role'];
      if (role == null) {
        emit(AuthError(message: "الدور غير معرف للمستخدم"));
        return;
      }

      if (role != 'patient' && role != 'donor') {
        emit(AuthError(message: "ليس لديك صلاحية الدخول هنا"));
        return;
      }

      emit(AuthSuccess(role));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: e.message ?? "حدث خطأ أثناء تسجيل الدخول"));
    } catch (e) {
      emit(AuthError(message: "حدث خطأ غير متوقع"));
    }
  }
}
