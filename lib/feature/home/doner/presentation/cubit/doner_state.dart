part of 'doner_cubit.dart';

abstract class DonorState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DonorLoading extends DonorState {}

class DonorLoaded extends DonorState {
  final Map<String, dynamic>? lastDonation;

  DonorLoaded({this.lastDonation});

  @override
  List<Object?> get props => [lastDonation];
}

class DonorError extends DonorState {
  final String message;

  DonorError(this.message);

  @override
  List<Object?> get props => [message];
}
