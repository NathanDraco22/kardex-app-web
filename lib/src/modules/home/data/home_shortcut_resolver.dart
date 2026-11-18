import 'package:material_ui/material_ui.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/constants/shortcut_registry.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/core/access_manager.dart';
import 'package:kardex_app_front/src/modules/home/data/home_modules_registry.dart';

class HomeShortcutRouteInfo {
  const HomeShortcutRouteInfo({
    required this.category,
    required this.item,
  });

  final HomeModuleCategory category;
  final HomeSubmoduleItem item;
}

/// Resuelve metadata y acceso de los accesos directos del Home.
class HomeShortcutResolver {
  HomeShortcutResolver._(this._routeInfo, this._accessibleRoutes);

  factory HomeShortcutResolver.build(BuildContext context) {
    final branch = getIt<AuthCubit>().currentBranch;
    final isCommerce = branch?.isCommerce ?? true;
    final categories = getHomeModuleCategories(context, branch, true);
    final accessManager = AccessManager();

    final routeInfo = <String, HomeShortcutRouteInfo>{};
    final accessibleRoutes = <String>{};

    for (final category in categories) {
      final categoryAllowed =
          category.permissions.isEmpty ||
          category.permissions.any(
            (permission) => accessManager.hasCurrentAccess(context, permission.name),
          );
      final categoryAvailable = !category.isCommerceOnly || isCommerce;

      for (final item in category.submodules) {
        final routeName = item.routeName;
        if (routeName == null) continue;

        routeInfo[routeName] = HomeShortcutRouteInfo(
          category: category,
          item: item,
        );

        final itemAllowed = item.gates.every(
          (filter) => filter.isAllowed(context),
        );

        if (categoryAllowed && categoryAvailable && itemAllowed) {
          accessibleRoutes.add(routeName);
        }
      }
    }

    return HomeShortcutResolver._(routeInfo, accessibleRoutes);
  }

  final Map<String, HomeShortcutRouteInfo> _routeInfo;
  final Set<String> _accessibleRoutes;

  /// Solo las rutas presentes y accesibles en el registry del Home son válidas.
  bool canAccess(String routeName) {
    return _accessibleRoutes.contains(routeName);
  }

  String titleFor(String routeName) {
    return _routeInfo[routeName]?.item.title ?? ShortcutRouteRegistry.routes[routeName]?.title ?? routeName;
  }

  IconData iconFor(String routeName) {
    return _routeInfo[routeName]?.item.icon ?? ShortcutRouteRegistry.routes[routeName]?.icon ?? Icons.link;
  }

  Color? colorFor(String routeName) {
    final info = _routeInfo[routeName];
    return ShortcutRouteRegistry.routes[routeName]?.color ?? info?.item.accentColor ?? info?.category.accentColor;
  }
}
