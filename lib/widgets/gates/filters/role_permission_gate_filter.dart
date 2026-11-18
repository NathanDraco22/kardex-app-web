import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/core/access_manager.dart';
import 'package:kardex_app_front/widgets/gates/gate_filter.dart';
import 'package:material_ui/material_ui.dart';

enum PermissionMode { whitelist, blacklist }

/// Filtro de permisos basado en el rol del usuario autenticado.
class RolePermissionGateFilter extends GateFilter {
  const RolePermissionGateFilter({
    required this.permissions,
    this.mode = PermissionMode.whitelist,
    this.fallback,
    this.accessManager,
    this.authCubit,
  });

  final List<Enum> permissions;
  final PermissionMode mode;
  final Widget? fallback;
  final AccessManager? accessManager;
  final AuthCubit? authCubit;

  AuthCubit? _resolveAuthCubit() {
    if (authCubit != null) return authCubit;
    return getIt.isRegistered<AuthCubit>() ? getIt<AuthCubit>() : null;
  }

  @override
  bool isAllowed(BuildContext context) {
    final auth = _resolveAuthCubit();
    if (auth == null) return false;

    final authState = auth.state;
    if (authState is! Authenticated) return false;

    final manager = accessManager ?? AccessManager();
    final user = authState.session.user;

    return switch (mode) {
      PermissionMode.whitelist => permissions.any(
        (p) => manager.hasAccessTo(user, p.name),
      ),
      PermissionMode.blacklist => permissions.every(
        (p) => !manager.hasAccessTo(user, p.name),
      ),
    };
  }

  @override
  Iterable<Stream<Object?>> watchStreams(BuildContext context) {
    final auth = _resolveAuthCubit();
    return auth != null ? [auth.stream] : const [];
  }

  @override
  Widget? buildFallback(BuildContext context) => fallback;
}
