import 'package:equatable/equatable.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}
class AdminLoaded extends AdminState {
  final int staffCount;
  final int donorsCount;

  const AdminLoaded({required this.staffCount, required this.donorsCount});

  @override
  List<Object?> get props => [staffCount, donorsCount];
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}