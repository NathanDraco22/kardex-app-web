import 'package:flutter/widgets.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

enum RoleCapability {
  allowInvoicing,
  allowCreditInvoicing,
  showClientCreditDetails,
}

class AccessManager {
  static final AccessManager _instance = AccessManager._internal();
  factory AccessManager() => _instance;
  AccessManager._internal();

  bool hasAccessTo(UserInDbWithRole user, String permissionName) {
    if (user.id == 'root') return true;
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

  bool hasCapability(UserInDbWithRole user, RoleCapability capability) {
    if (user.id == 'root') return true;
    if (user.userRole.access.contains('all')) return true;

    return switch (capability) {
      RoleCapability.allowInvoicing => user.userRole.capabilities.allowInvoicing,
      RoleCapability.allowCreditInvoicing =>
        user.userRole.capabilities.allowCreditInvoicing,
      RoleCapability.showClientCreditDetails =>
        user.userRole.capabilities.showClientCreditDetails,
    };
  }

  bool hasCurrentCapability(
    RoleCapability capability, {
    AuthCubit? authCubit,
  }) {
    final resolvedCubit =
        authCubit ?? (getIt.isRegistered<AuthCubit>() ? getIt<AuthCubit>() : null);
    if (resolvedCubit == null) return false;
    final authState = resolvedCubit.state;
    if (authState is! Authenticated) return false;
    return hasCapability(authState.session.user, capability);
  }
}
