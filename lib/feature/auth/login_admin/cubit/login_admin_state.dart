import 'package:meta/meta.dart';

@immutable
abstract class AdminLoginState {}

class AdminLoginInitial extends AdminLoginState {}

class AdminLoginLoading extends AdminLoginState {}

class AdminLoginSuccess extends AdminLoginState {}

class AdminLoginError extends AdminLoginState {
  final String message;
  AdminLoginError(this.message);
}
