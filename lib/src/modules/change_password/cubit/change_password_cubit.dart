import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this.authRepository) : super(ChangePasswordInitial());

  final AuthRepository authRepository;

  Future<void> changePassword(ChangePasswordBody data) async {
    emit(ChangePasswordInProgress());
    try {
      await authRepository.changePassword(data);
      emit(ChangePasswordSuccess());
    } catch (error) {
      emit(ChangePasswordError(message: error.toString()));
    }
  }
}
