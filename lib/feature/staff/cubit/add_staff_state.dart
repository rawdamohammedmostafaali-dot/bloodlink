abstract class AddStaffState {}

class AddStaffInitial extends AddStaffState {}

class AddStaffLoading extends AddStaffState {}

class AddStaffSuccess extends AddStaffState {}

class AddStaffError extends AddStaffState {
  final String message;
  AddStaffError(this.message);
}
