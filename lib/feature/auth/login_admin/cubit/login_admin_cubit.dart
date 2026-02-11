import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_admin_state.dart';

class AdminLoginCubit extends Cubit<AdminLoginState> {
  AdminLoginCubit() : super(AdminLoginInitial());

  Future<void> loginAdmin(String email, String password) async {
    emit(AdminLoginLoading());

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password.trim());

      final uid = userCredential.user!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists || doc['role'] != 'admin') {
        await FirebaseAuth.instance.signOut();
        emit(AdminLoginError("غير مصرح لك بالدخول كمدير"));
        return;
      }
      emit(AdminLoginSuccess());
    } on FirebaseAuthException catch (e) {
      emit(AdminLoginError(e.message ?? "حدث خطأ أثناء تسجيل الدخول"));
    } catch (e) {
      emit(AdminLoginError("حدث خطأ غير متوقع"));
    }
  }
}
