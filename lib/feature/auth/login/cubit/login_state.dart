abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String role;
  AuthSuccess({required this.role});
}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}
