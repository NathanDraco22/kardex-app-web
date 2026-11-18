import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/widgets/gates/gate_filter.dart';
import 'package:material_ui/material_ui.dart';

/// Filtro que restringe el acceso exclusivamente al usuario `root`.
class RootUserGateFilter extends GateFilter {
  const RootUserGateFilter({
    this.fallback,
    this.authCubit,
  });

  final Widget? fallback;
  final AuthCubit? authCubit;

  AuthCubit? _resolveAuthCubit() {
    if (authCubit != null) return authCubit;
    return getIt.isRegistered<AuthCubit>() ? getIt<AuthCubit>() : null;
  }

  @override
  bool isAllowed(BuildContext context) {
    final user = _resolveAuthCubit()?.user;
    return user != null && user.id == 'root';
  }

  @override
  Iterable<Stream<Object?>> watchStreams(BuildContext context) {
    final auth = _resolveAuthCubit();
    return auth != null ? [auth.stream] : const [];
  }

  @override
  Widget? buildFallback(BuildContext context) => fallback;
}
