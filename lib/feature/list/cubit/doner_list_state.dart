import 'package:equatable/equatable.dart';

abstract class DonorsState extends Equatable {
  const DonorsState();

  @override
  List<Object?> get props => [];
}

class DonorsInitial extends DonorsState {}

class DonorsLoading extends DonorsState {}

class DonorsLoaded extends DonorsState {
  final List<Map<String, dynamic>> donors;

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
