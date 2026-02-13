abstract class PatientDashboardState {}

class PatientDashboardInitial extends PatientDashboardState {}

class PatientDashboardLoading extends PatientDashboardState {}

class PatientDashboardLoaded extends PatientDashboardState {
  final List<Map<String, dynamic>> requests;
  PatientDashboardLoaded(this.requests);
}

class PatientDashboardError extends PatientDashboardState {
  final String message;
  PatientDashboardError(this.message);
}
