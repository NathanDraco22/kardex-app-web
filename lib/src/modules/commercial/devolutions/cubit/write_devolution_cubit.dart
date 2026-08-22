import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'write_devolution_state.dart';

class WriteDevolutionCubit extends Cubit<WriteDevolutionState> {
  WriteDevolutionCubit({required this.devolutionsRepository}) : super(WriteDevolutionInitial());

  final DevolutionsRepository devolutionsRepository;

  Future<void> createNewDevolution(CreateDevolution createDevolution) async {
    emit(WriteDevolutionInProgress());
    try {
      final devolution = await devolutionsRepository.createDevolution(createDevolution);
      emit(WriteDevolutionSuccess(devolution));
      emit(WriteDevolutionInitial());
    } catch (error) {
      emit(WriteDevolutionError(error.toString()));
    }
  }
}
