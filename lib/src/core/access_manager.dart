import 'package:flutter/widgets.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/user/user_model.dart';

class AccessManager {
  static final AccessManager _instance = AccessManager._internal();
  factory AccessManager() => _instance;
  AccessManager._internal();

  bool hasAccessTo(UserInDbWithRole user, String permissionName) {
    bool hasAccess = false;
    hasAccess = user.userRole.access.contains(permissionName);
    hasAccess = hasAccess || user.userRole.access.contains("all");
    return hasAccess;
  }

  bool hasCurrentAccess(BuildContext context, String permissionName) {
    final authState = getIt<AuthCubit>().state;
    if (authState is! Authenticated) return false;
    final user = authState.session.user;
    return hasAccessTo(user, permissionName);
  }
}
