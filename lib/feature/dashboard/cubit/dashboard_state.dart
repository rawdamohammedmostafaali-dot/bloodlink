abstract class DashboardState {}

class Dashboard_doner_Loading extends DashboardState {}

class Dashboard_doner_Loaded extends DashboardState {
  final int donorsCount;
  final int patientsCount;

  Dashboard_doner_Loaded(this.donorsCount, this.patientsCount);
}

class Dashboard_doner_Error extends DashboardState {
  final String message;
  Dashboard_doner_Error(this.message);
}
