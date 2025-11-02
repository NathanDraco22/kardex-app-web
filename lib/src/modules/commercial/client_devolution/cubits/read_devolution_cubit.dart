import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'read_devolution_state.dart';

class ReadDevolutionCubit extends Cubit<ReadDevolutionState> {
  ReadDevolutionCubit() : super(ReadDevolutionInitial());
}
