import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch_model.dart';
import 'package:kardex_app_front/src/domain/models/user/user_model.dart';
import 'package:kardex_app_front/src/domain/models/user_role/user_role_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/constant.dart';

part 'read_user_state.dart';

class ReadUserCubit extends Cubit<ReadUserState> {
  ReadUserCubit({
    required this.usersRepository,
    required this.userRolesRepository,
    required this.branchesRepository,
  }) : super(ReadUserInitial());

  final UsersRepository usersRepository;
  final UserRolesRepository userRolesRepository;
  final BranchesRepository branchesRepository;

  bool isLastPage = false;
  List<UserInDbWithRole> _usersCache = [];

  Future<void> loadPaginatedUsers() async {
    emit(ReadUserLoading());
    try {
      final users = await usersRepository.getPaginatedUsers(_usersCache.length);
      final userRoles = await userRolesRepository.getAllUserRoles();
      final branches = await branchesRepository.getAllBranches();
      if (users.length < paginationItems) isLastPage = true;
      _usersCache = [..._usersCache, ...users];
      if (isClosed) return;
      emit(ReadUserSuccess(_usersCache, userRoles, branches));
    } catch (error) {
      if (isClosed) return;
      emit(ReadUserError(error.toString()));
    }
  }

  Future<void> getNextPagedUsers() async {
    final currentState = state;
    if (currentState is! ReadUserSuccess) return;
    if (isLastPage) return;
    try {
      final users = await usersRepository.getPaginatedUsers(_usersCache.length);
      if (users.length < paginationItems) isLastPage = true;
      _usersCache = [..._usersCache, ...users];
      if (isClosed) return;
      emit(
        ReadUserSuccess(
          _usersCache,
          currentState.roles,
          currentState.branches,
        ),
      );
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> putUserFirst(UserInDbWithRole user) async {
    final currentState = state as ReadUserSuccess;
    _usersCache = [user, ..._usersCache];
    final freshList = _usersCache;
    if (currentState is HighlightedUser) {
      emit(
        HighlightedUser(
          freshList,
          currentState.roles,
          currentState.branches,
          newUsers: [user, ...currentState.newUsers],
          updatedUsers: currentState.updatedUsers,
        ),
      );
      return;
    }
    emit(
      HighlightedUser(
        freshList,
        currentState.roles,
        currentState.branches,
        newUsers: [user],
      ),
    );
  }

  Future<void> markUserUpdated(UserInDbWithRole user) async {
    final currentState = state as ReadUserSuccess;
    final userIndex = _usersCache.indexWhere((element) => element.id == user.id);
    if (userIndex != -1) {
      _usersCache[userIndex] = user;
    }
    final freshList = _usersCache;

    if (currentState is HighlightedUser) {
      emit(
        HighlightedUser(
          freshList,
          currentState.roles,
          currentState.branches,
          newUsers: currentState.newUsers,
          updatedUsers: [user, ...currentState.updatedUsers],
        ),
      );
      return;
    }
    emit(
      HighlightedUser(
        freshList,
        currentState.roles,
        currentState.branches,
        updatedUsers: [user],
      ),
    );
  }

  Future<void> removeUser(UserInDb user) async {
    final currentState = state as ReadUserSuccess;
    _usersCache.removeWhere((element) => element.id == user.id);
    final freshList = _usersCache;
    emit(
      ReadUserSuccess(
        freshList,
        currentState.roles,
        currentState.branches,
      ),
    );
  }
}
