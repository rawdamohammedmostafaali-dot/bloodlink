import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class DonorState extends Equatable {
  const DonorState();
  @override
  List<Object?> get props => [];
}

class DonorInitial extends DonorState {}
class DonorLoading extends DonorState {}

class DonorLoaded extends DonorState {
  final Map<String, dynamic>? lastDonation;

  const DonorLoaded(this.lastDonation);

  @override
  List<Object?> get props => [lastDonation];
}

class DonorError extends DonorState {
  final String message;
  const DonorError(this.message);
  @override
  List<Object?> get props => [message];
}
abstract class DonorsState extends Equatable {
  const DonorsState();
  @override
  List<Object?> get props => [];
}

class DonorsInitial extends DonorsState {}
class DonorsLoading extends DonorsState {}

class DonorsLoaded extends DonorsState {
  final List<QueryDocumentSnapshot> donors;
  const DonorsLoaded(this.donors);
  @override
  List<Object?> get props => [donors];
}

class DonorsError extends DonorsState {
  final String message;
  const DonorsError(this.message);
  @override
  List<Object?> get props => [message];
}