import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/models/user/user_model.dart';

class SessionTool {
  static UserInDbWithRole? getUserFrom(BuildContext context) {
    final authCubit = BlocProvider.of<AuthCubit>(context);
    final state = authCubit.state;

    if (state is! Authenticated) return null;

    return state.session.user;
  }

  static BranchInDb? getBranchFrom(BuildContext context) {
    final authCubit = BlocProvider.of<AuthCubit>(context);
    final state = authCubit.state;

    if (state is! Authenticated) return null;

    return state.branch;
  }

  static (UserInDbWithRole, BranchInDb) getFullUserFrom(BuildContext context) {
    final currentBranch = SessionTool.getBranchFrom(context);
    final currentUser = SessionTool.getUserFrom(context);

    if (currentBranch == null || currentUser == null) {
      throw Exception("Branch or user not found in Anon Menu Screen");
    }

    return (currentUser, currentBranch);
  }
}
