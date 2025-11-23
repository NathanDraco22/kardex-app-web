import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'write_anon_devolution_state.dart';

class WriteAnonDevolutionCubit extends Cubit<WriteAnonDevolutionState> {
  WriteAnonDevolutionCubit({required this.devolutionsRepository}) : super(WriteAnonDevolutionInitial());

  final DevolutionsRepository devolutionsRepository;

  Future<void> createNewDevolution(CreateDevolution createDevolution) async {
    emit(WriteAnonDevolutionInProgress());
    try {
      final devolution = await devolutionsRepository.createDevolution(createDevolution);
      emit(WriteAnonDevolutionSuccess(devolution));
      emit(WriteAnonDevolutionInitial());
    } catch (error) {
      emit(WriteAnonDevolutionError(error.toString()));
    }
  }
}
