import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/widgets/gates/gate_filter.dart';
import 'package:material_ui/material_ui.dart';

/// Filtro reactivo que verifica si el módulo de órdenes está habilitado.
class OrdersGateFilter extends GateFilter {
  const OrdersGateFilter({
    this.fallback,
    this.appSettingsCubit,
  });

  final Widget? fallback;
  final AppSettingsCubit? appSettingsCubit;

  AppSettingsCubit? _resolveAppSettingsCubit() {
    if (appSettingsCubit != null) return appSettingsCubit;
    return getIt.isRegistered<AppSettingsCubit>()
        ? getIt<AppSettingsCubit>()
        : null;
  }

  @override
  bool isAllowed(BuildContext context) {
    return _resolveAppSettingsCubit()?.useOrders ?? false;
  }

  @override
  Iterable<Stream<Object?>> watchStreams(BuildContext context) {
    final settings = _resolveAppSettingsCubit();
    return settings != null ? [settings.stream] : const [];
  }

  @override
  Widget? buildFallback(BuildContext context) => fallback;
}
