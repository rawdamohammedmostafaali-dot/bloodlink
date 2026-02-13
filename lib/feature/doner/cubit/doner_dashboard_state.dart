abstract class DonorDashboardState {}

class DonorDashboardInitial extends DonorDashboardState {}

class DonorDashboardLoading extends DonorDashboardState {}

class DonorDashboardLoaded extends DonorDashboardState {
  final List<Map<String, dynamic>> requests;
  DonorDashboardLoaded(this.requests);
}

class DonorDashboardError extends DonorDashboardState {
  final String message;
  DonorDashboardError(this.message);
}
