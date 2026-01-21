import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/adjust_exit/adjust_exit_model.dart';
import 'package:kardex_app_front/src/domain/repositories/adjust_exits_repository.dart';

abstract class WriteAdjustExitState {}

class WriteAdjustExitInitial extends WriteAdjustExitState {}

class WriteAdjustExitLoading extends WriteAdjustExitState {}

class WriteAdjustExitSuccess extends WriteAdjustExitState {
  final AdjustExitInDb adjustExit;
  WriteAdjustExitSuccess(this.adjustExit);
}

class WriteAdjustExitFailure extends WriteAdjustExitState {
  final String message;
  WriteAdjustExitFailure(this.message);
}

class WriteAdjustExitCubit extends Cubit<WriteAdjustExitState> {
  final AdjustExitsRepository repository;

  WriteAdjustExitCubit({required this.repository}) : super(WriteAdjustExitInitial());

  Future<void> createAdjustExit(CreateAdjustExit body) async {
    emit(WriteAdjustExitLoading());
    try {
      final res = await repository.createAdjustExit(body);
      emit(WriteAdjustExitSuccess(res));
    } catch (e) {
      emit(WriteAdjustExitFailure(e.toString()));
    }
  }
}
