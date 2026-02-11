import 'package:equatable/equatable.dart';

abstract class DonorDonationsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DonorDonationsLoading extends DonorDonationsState {}

class DonorDonationsLoaded extends DonorDonationsState {
  final List<Map<String, dynamic>> donations;

  DonorDonationsLoaded({required this.donations});

  @override
  List<Object?> get props => [donations];
}

class DonorDonationsError extends DonorDonationsState {
  final String message;

  DonorDonationsError({required this.message});

  @override
  List<Object?> get props => [message];
}
