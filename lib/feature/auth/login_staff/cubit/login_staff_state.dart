abstract class StaffState {}
class StaffInitial extends StaffState {}
class StaffLoading extends StaffState {}
class StaffSuccess extends StaffState {
  final String staffName;
  StaffSuccess(this.staffName);
}
class StaffError extends StaffState {
  final String message;
  StaffError(this.message);
}
