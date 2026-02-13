import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'doner_state.dart';

class DonerCubit extends Cubit<DonerState> {
  DonerCubit() : super(DonerInitial());
}
