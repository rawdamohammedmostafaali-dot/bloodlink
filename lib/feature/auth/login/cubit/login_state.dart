abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String role; // patient أو donor
  AuthSuccess(this.role);
}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}
