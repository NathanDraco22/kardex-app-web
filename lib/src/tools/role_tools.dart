import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/user/user_model.dart';

class RoleTools {
  static (bool, UserInDb?) isSeller(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) {
      return (false, null);
    }
    return (authState.session.user.role == "Vendedor", authState.session.user);
  }
}
