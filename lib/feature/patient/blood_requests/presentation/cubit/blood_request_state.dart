import 'package:equatable/equatable.dart';

abstract class RequestBloodState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RequestBloodLoading extends RequestBloodState {}

class RequestBloodUpdated extends RequestBloodState {
  final List<String> governorates;
  final List<String> hospitals;
  final String? selectedGovernorate;
  final String? selectedHospital;
  final String? bloodType;
  final double amount;
  final bool isLoading;

  RequestBloodUpdated({
    this.governorates = const [],
    this.hospitals = const [],
    this.selectedGovernorate,
    this.selectedHospital,
    this.bloodType,
    this.amount = 100,
    this.isLoading = false,
  });

  bool get isFormValid =>
      bloodType != null &&
          amount >= 100 &&
          amount <= 500 &&
          selectedGovernorate != null &&
          selectedHospital != null;

  RequestBloodUpdated copyWith({
    List<String>? governorates,
    List<String>? hospitals,
    String? selectedGovernorate,
    String? selectedHospital,
    String? bloodType,
    double? amount,
    bool? isLoading,
  }) {
    return RequestBloodUpdated(
      governorates: governorates ?? this.governorates,
      hospitals: hospitals ?? this.hospitals,
      selectedGovernorate: selectedGovernorate ?? this.selectedGovernorate,
      selectedHospital: selectedHospital ?? this.selectedHospital,
      bloodType: bloodType ?? this.bloodType,
      amount: amount ?? this.amount,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    governorates,
    hospitals,
    selectedGovernorate,
    selectedHospital,
    bloodType,
    amount,
    isLoading
  ];
}

class RequestBloodSentSuccess extends RequestBloodState {}

class RequestBloodError extends RequestBloodState {
  final String error;
  RequestBloodError(this.error);

  @override
  List<Object?> get props => [error];
}
