import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'updated_state.dart';

class UpdatedCubit extends Cubit<UpdatedState> {
  UpdatedCubit() : super(UpdatedInitial());
}
