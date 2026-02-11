import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class StaffHomeState extends Equatable {
  const StaffHomeState();

  @override
  List<Object?> get props => [];
}

class StaffHomeInitial extends StaffHomeState {}

class StaffHomeLoading extends StaffHomeState {}

class StaffHomeLoaded extends StaffHomeState {
  final int donorsCount;
  final int requestsCount;
  final List<QueryDocumentSnapshot> bloodRequests;

  const StaffHomeLoaded({
    required this.donorsCount,
    required this.requestsCount,
    required this.bloodRequests,
  });

  @override
  List<Object?> get props => [donorsCount, requestsCount, bloodRequests];

  get newRequestsCount => null;

  get upcomingDonations => null;
}

class StaffHomeError extends StaffHomeState {
  final String error;
  const StaffHomeError(this.error);

  @override
  List<Object?> get props => [error];
}
