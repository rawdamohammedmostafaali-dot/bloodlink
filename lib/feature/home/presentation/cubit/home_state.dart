import 'package:meta/meta.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String bloodType;
  final DateTime? lastDonationDate;
  final String role;
  final Map<String, dynamic> userData;

  HomeLoaded({
    required this.bloodType,
    this.lastDonationDate,
    required this.role,
    required this.userData,
  });
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
