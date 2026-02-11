class RequestBloodUpdated {
  final String? bloodType;
  final double amount;
  final String? selectedGovernorate;
  final String? selectedHospital;
  final List<String> governorates;
  final List<String> hospitals;
  final bool isLoading;

  RequestBloodUpdated({
    this.bloodType,
    this.amount = 250,
    this.selectedGovernorate,
    this.selectedHospital,
    this.governorates = const [],
    this.hospitals = const [],
    this.isLoading = false,
  });
  bool get isFormValid =>
      bloodType != null && selectedGovernorate != null && selectedHospital != null;

  RequestBloodUpdated copyWith({
    String? bloodType,
    double? amount,
    String? selectedGovernorate,
    String? selectedHospital,
    List<String>? governorates,
    List<String>? hospitals,
    bool? isLoading,
  }) {
    return RequestBloodUpdated(
      bloodType: bloodType ?? this.bloodType,
      amount: amount ?? this.amount,
      selectedGovernorate: selectedGovernorate ?? this.selectedGovernorate,
      selectedHospital: selectedHospital ?? this.selectedHospital,
      governorates: governorates ?? this.governorates,
      hospitals: hospitals ?? this.hospitals,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
