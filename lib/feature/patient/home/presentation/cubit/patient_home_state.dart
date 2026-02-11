import 'package:equatable/equatable.dart';

abstract class PatientHomeState extends Equatable {
  const PatientHomeState();

  @override
  List<Object?> get props => [];
}

// حالة تحميل البيانات
class PatientLoading extends PatientHomeState {}

// حالة وجود خطأ
class PatientError extends PatientHomeState {
  final String message;
  const PatientError(this.message);

  @override
  List<Object?> get props => [message];
}

// حالة البيانات جاهزة
class PatientLoaded extends PatientHomeState {
  final Map<String, dynamic>? lastRequest;

  const PatientLoaded({this.lastRequest});

  @override
  List<Object?> get props => [lastRequest ?? {}];
}
