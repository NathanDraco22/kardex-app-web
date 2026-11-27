import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/widgets/gates/gate_filter.dart';
import 'package:material_ui/material_ui.dart';

/// Filtro reactivo para el control de fechas de vencimiento.
///
/// Requiere que el `servin` autenticado tenga habilitado
/// `isUsingExpirationDate` y que `AppSettingsCubit.policy.useExpirationDates` sea
/// verdadero.
class ExpirationDateGateFilter extends GateFilter {
  const ExpirationDateGateFilter({
    this.fallback,
    this.authCubit,
    this.appSettingsCubit,
  });

  final Widget? fallback;
  final AuthCubit? authCubit;
  final AppSettingsCubit? appSettingsCubit;

  AuthCubit? _resolveAuthCubit() {
    if (authCubit != null) return authCubit;
    return getIt.isRegistered<AuthCubit>() ? getIt<AuthCubit>() : null;
  }

  AppSettingsCubit? _resolveAppSettingsCubit() {
    if (appSettingsCubit != null) return appSettingsCubit;
    return getIt.isRegistered<AppSettingsCubit>()
        ? getIt<AppSettingsCubit>()
        : null;
  }

  @override
  bool isAllowed(BuildContext context) {
    final authState = _resolveAuthCubit()?.state;
    if (authState is! Authenticated) return false;
    if (!authState.servin.isUsingExpirationDate) return false;

    return _resolveAppSettingsCubit()?.policy.useExpirationDates ?? false;
  }

  @override
  Iterable<Stream<Object?>> watchStreams(BuildContext context) {
    final auth = _resolveAuthCubit();
    final settings = _resolveAppSettingsCubit();
    return [
      if (auth != null) auth.stream,
      if (settings != null) settings.stream,
    ];
  }

  @override
  Widget? buildFallback(BuildContext context) => fallback;
}
