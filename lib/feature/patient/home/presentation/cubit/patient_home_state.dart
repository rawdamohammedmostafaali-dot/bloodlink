import 'package:equatable/equatable.dart';

abstract class PatientHomeState extends Equatable {
  const PatientHomeState();

  @override
  List<Object?> get props => [];
}

class PatientLoading extends PatientHomeState {}

class PatientError extends PatientHomeState {
  final String message;
  const PatientError(this.message);

  @override
  List<Object?> get props => [message];
}

class PatientLoaded extends PatientHomeState {
  final Map<String, dynamic>? lastRequest;
  final Map<String, dynamic>? userData;

  const PatientLoaded({this.lastRequest, this.userData});

  @override
  List<Object?> get props => [lastRequest, userData];
}
