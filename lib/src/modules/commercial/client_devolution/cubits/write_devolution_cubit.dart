import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

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

  Future<void> confirmDevolution(String devolutionId) async {
    emit(WriteDevolutionInProgress());
    try {
      final devolution = await devolutionsRepository.confirmDevolutionById(devolutionId);
      emit(WriteDevolutionSuccess(devolution!));
      emit(WriteDevolutionInitial());
    } catch (error) {
      emit(WriteDevolutionError(error.toString()));
    }
  }

  Future<void> confirmAnonDevolution(String devolutionId) async {
    emit(WriteDevolutionInProgress());
    try {
      final devolution = await devolutionsRepository.confirmAnonDevolutionById(devolutionId);
      emit(WriteDevolutionSuccess(devolution!));
      emit(WriteDevolutionInitial());
    } catch (error) {
      emit(WriteDevolutionError(error.toString()));
    }
  }

  Future<void> cancelDevolution(String devolutionId) async {
    emit(WriteDevolutionInProgress());
    try {
      final devolution = await devolutionsRepository.cancelDevolutionById(devolutionId);
      emit(WriteDevolutionSuccess(devolution!));
      emit(WriteDevolutionInitial());
    } catch (error) {
      emit(WriteDevolutionError(error.toString()));
    }
  }

  Future<void> deleteDevolution(String devolutionId) async {
    emit(WriteDevolutionInProgress());
    try {
      final devolution = await devolutionsRepository.deleteDevolutionById(devolutionId);
      emit(DeleteDevolutionSuccess(devolution!));
      emit(WriteDevolutionInitial());
    } catch (error) {
      emit(WriteDevolutionError(error.toString()));
    }
  }
}
