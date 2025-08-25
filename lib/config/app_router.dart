import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/modules/client_catalog/view/client_catalog_screen.dart';
import 'package:kardex_app_front/src/modules/home/view/home_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/current_inventory/current_inventory_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/history_entry/history_entry_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/history_exit/history_exit_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_entry/view/inventory_entry_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_exit/view/inventory_exit_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_menu_screen.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_category/view/product_category_screen.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/view/product_list_screen.dart';
import 'package:kardex_app_front/src/modules/product_catalog/view/product_catalog_menu_screen.dart';
import 'package:kardex_app_front/src/modules/settings/view/branches/branches_screen.dart';
import 'package:kardex_app_front/src/modules/settings/view/price_to_product/price_to_product_screen.dart';
import 'package:kardex_app_front/src/modules/settings/view/settings_screen.dart';
import 'package:kardex_app_front/src/modules/settings/view/units/units_screen.dart';
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
            path: "product-category",
            name: "product-category",
            builder: (context, state) => const ProductCategoryScreen(),
          ),
          GoRoute(
            path: "product-list",
            name: "product-list",
            builder: (context, state) => const ProductListScreen(),
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
        path: '/inventory',
        name: 'inventory',
        builder: (context, state) => const InventoryMenuScreen(),
        routes: [
          GoRoute(
            path: "current-inventory",
            name: "current-inventory",
            builder: (context, state) => const CurrentInventoryScreen(),
          ),
          GoRoute(
            path: "inventory-entry",
            name: "inventory-entry",
            builder: (context, state) => const InventoryEntryScreen(),
          ),
          GoRoute(
            path: "inventory-exit",
            name: "inventory-exit",
            builder: (context, state) => const InventoryExitScreen(),
          ),
          GoRoute(
            path: "history-entry",
            name: "history-entry",
            builder: (context, state) => const HistoryEntryScreen(),
          ),
          GoRoute(
            path: "history-exit",
            name: "history-exit",
            builder: (context, state) => const HistoryExitScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: "product-price",
            name: "product-price",
            builder: (context, state) => const PriceToProductScreen(),
          ),

          GoRoute(
            path: "units",
            name: "units",
            builder: (context, state) => const UnitsScreen(),
          ),
          GoRoute(
            path: "branches",
            name: "branches",
            builder: (context, state) => const BranchesScreen(),
          ),
        ],
      ),
    ],
  );
}
