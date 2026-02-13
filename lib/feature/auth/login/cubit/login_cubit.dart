import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> login({
    required String email,
    required String password, required  role,
  }) async {
    emit(AuthLoading());

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        emit(AuthError(message: "المستخدم غير موجود في قاعدة البيانات"));
        return;
      }

      String role = userDoc.get('role');

      emit(AuthSuccess(role: role));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
