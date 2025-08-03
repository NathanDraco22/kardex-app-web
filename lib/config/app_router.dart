import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/modules/client_catalog/view/client_catalog_screen.dart';
import 'package:kardex_app_front/src/modules/home/view/home_screen.dart';
import 'package:kardex_app_front/src/modules/product_catalog/view/product_catalog_menu_screen.dart';
import 'package:kardex_app_front/src/modules/settings/view/branches/branches_screen.dart';
import 'package:kardex_app_front/src/modules/settings/view/price_to_product/price_to_product_screen.dart';
import 'package:kardex_app_front/src/modules/settings/view/settings_screen.dart';
import 'package:kardex_app_front/src/modules/suppliers_catalog/view/suppliers_catalog_screen.dart';

class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      GoRoute(
        path: '/product-catalog',
        name: 'product-catalog',
        builder: (context, state) => const ProductCatalogMenuScreen(),
        routes: [
          GoRoute(
            path: "product-price",
            name: "product-price",
            builder: (context, state) => const PriceToProductScreen(),
          ),
          GoRoute(
            path: "branches",
            name: "branches",
            builder: (context, state) => const BranchesScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/client-catalog',
        name: 'client-catalog',
        builder: (context, state) => const ClientCatalogScreen(),
      ),

      GoRoute(
        path: '/suppliers-catalog',
        name: 'suppliers-catalog',
        builder: (context, state) => const SuppliersCatalogScreen(),
      ),

      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
