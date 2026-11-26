import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/core/access_manager.dart';
import 'package:kardex_app_front/widgets/gates/gate_filter.dart';
import 'package:material_ui/material_ui.dart';

/// Filtro de capacidades operativas basado en el rol del usuario autenticado.
class RoleCapabilityGateFilter extends GateFilter {
  const RoleCapabilityGateFilter({
    required this.capability,
    this.fallback,
    this.accessManager,
    this.authCubit,
  });

  final RoleCapability capability;
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
    return manager.hasCapability(authState.session.user, capability);
  }

  @override
  Iterable<Stream<Object?>> watchStreams(BuildContext context) {
    final auth = _resolveAuthCubit();
    return auth != null ? [auth.stream] : const [];
  }

  @override
  Widget? buildFallback(BuildContext context) => fallback;
}
