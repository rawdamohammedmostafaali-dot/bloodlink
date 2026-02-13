abstract class DonorsState {}

class DonorsInitial extends DonorsState {}

class DonorsLoading extends DonorsState {}

class DonorsLoaded extends DonorsState {
  final List<Map<String, dynamic>> donors;
  final List<Map<String, dynamic>> filteredDonors;

  DonorsLoaded(this.donors, this.filteredDonors);
}

class DonorsError extends DonorsState {
  final String message;
  DonorsError(this.message);
}
abstract class PatientsState {}

class PatientsInitial extends PatientsState {}

class PatientsLoading extends PatientsState {}

class PatientsLoaded extends PatientsState {
  final List<Map<String, dynamic>> patients;
  PatientsLoaded(this.patients);
}

class PatientsError extends PatientsState {
  final String message;
  PatientsError(this.message);
}

