import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_active_users_state.dart';

class ReadActiveUsersCubit extends Cubit<ReadActiveUsersState> {
  ReadActiveUsersCubit({required this.usersRepository}) : super(ReadActiveUsersInitial());

  final UsersRepository usersRepository;

  Future<void> loadActiveUsers() async {
    emit(ReadActiveUsersLoading());
    try {
      final users = await usersRepository.getAllActiveUsers();
      emit(ReadActiveUsersSuccess(users));
    } catch (error) {
      emit(ReadActiveUsersError(error.toString()));
    }
  }
}
