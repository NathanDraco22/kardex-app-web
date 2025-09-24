import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/user/user_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'write_user_state.dart';

class WriteUserCubit extends Cubit<WriteUserState> {
  WriteUserCubit({required this.usersRepository}) : super(WriteUserInitial());

  final UsersRepository usersRepository;

  Future<void> createNewUser(CreateUser createUser) async {
    emit(WriteUserInProgress());
    try {
      final user = await usersRepository.createUser(createUser);
      emit(WriteUserSuccess(user));
      emit(WriteUserInitial());
    } catch (error) {
      emit(WriteUserError(error.toString()));
    }
  }

  Future<void> updateUser(String userId, UpdateUser updateUser) async {
    emit(WriteUserInProgress());
    try {
      final user = await usersRepository.updateUserById(userId, updateUser);
      emit(UpdateUserSuccess(user!));
      emit(WriteUserInitial());
    } catch (error) {
      emit(WriteUserError(error.toString()));
    }
  }

  Future<void> deleteUser(String userId) async {
    emit(WriteUserInProgress());
    try {
      final user = await usersRepository.deleteUserById(userId);
      emit(DeleteUserSuccess(user!));
      emit(WriteUserInitial());
    } catch (error) {
      emit(WriteUserError(error.toString()));
    }
  }
}
