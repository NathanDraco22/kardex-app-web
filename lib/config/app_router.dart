import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/admin_panel/admin_panel_screen.dart';
import 'package:kardex_app_front/src/modules/activation/activation_screen.dart';
import 'package:kardex_app_front/src/modules/client_catalog/view/client_catalog_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/anon_devolution/anon_devolution_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/anon_invoices/anon_invoices_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/client_devolution/client_devolution_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/client_invoices_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/commercial_menu_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/current_devolutions/current_devolutions_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/current_orders_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_anon_invoinces/daily_anon_invoices_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_receipt/daily_receipt_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/devolution_history/devolution_history_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/invoice_history/invoice_history_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/pending_invoice_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/product_price_setting/product_price_setting.dart';
import 'package:kardex_app_front/src/modules/commercial/product_movements/view/commercial_product_movements_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/receipt_history/receipt_history_screen.dart';
import 'package:kardex_app_front/src/modules/finance/client_accounts/view/client_account_screen.dart';
import 'package:kardex_app_front/src/modules/finance/client_movements/view/client_movements_screen.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/modules/finance/finances_menu_screen.dart';
import 'package:kardex_app_front/src/modules/finance/paid_invoices/paid_invoices_screen.dart';
import 'package:kardex_app_front/src/modules/home/view/home_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/current_inventory/current_inventory_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/expiration_logs/expiration_logs_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/history_entry/history_entry_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/history_exit/history_exit_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_entry/view/inventory_entry_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_exit/view/inventory_exit_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_menu_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/product_movements/view/product_movements_screen.dart';
import 'package:kardex_app_front/src/modules/login/login_screen.dart';
import 'package:kardex_app_front/src/modules/multi_branch_home/multibranch_home_screen.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_category/view/product_category_screen.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/view/product_list_screen.dart';
import 'package:kardex_app_front/src/modules/product_catalog/view/product_catalog_menu_screen.dart';
import 'package:kardex_app_front/src/modules/settings/view/branches/branches_screen.dart';
import 'package:kardex_app_front/src/modules/settings/view/price_to_product/price_to_product_screen.dart';
import 'package:kardex_app_front/src/modules/settings/view/settings_screen.dart';
import 'package:kardex_app_front/src/modules/product_catalog/units/units_screen.dart';
import 'package:kardex_app_front/src/modules/settings/view/users/users_screen.dart';
import 'package:kardex_app_front/src/modules/splash/splash_screen.dart';
import 'package:kardex_app_front/src/modules/suppliers_catalog/view/suppliers_catalog_screen.dart';

class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: "/activation",
        name: "activation",
        builder: (context, state) => const ActivationScreen(),
      ),

      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      GoRoute(
        path: '/multibranch-home',
        name: 'multibranch-home',
        builder: (context, state) => const MultibranchHomeScreen(),
      ),

      GoRoute(
        path: '/admin-panel',
        name: 'admin-panel',
        builder: (context, state) => const AdminPanelScreen(),
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
          GoRoute(
            path: "units",
            name: "units",
            builder: (context, state) => const UnitsScreen(),
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
        path: '/commercial',
        name: 'commercial',
        builder: (context, state) => const CommercialMenuScreen(),
        routes: [
          GoRoute(
            path: "anon-invoice",
            name: "anon-invoice",
            builder: (context, state) => const AnonInvoicesScreen(),
          ),

          GoRoute(
            path: "anon-devolution",
            name: "anon-devolution",
            builder: (context, state) => const AnonDevolutionScreen(),
          ),

          GoRoute(
            path: "daily-invoice",
            name: "daily-invoice",
            builder: (context, state) => const DailyAnonInvoicesScreen(),
          ),

          GoRoute(
            path: "invoice-history",
            name: "invoice-history",
            builder: (context, state) => const InvoiceHistoryScreen(),
          ),

          GoRoute(
            path: "current-orders",
            name: "current-orders",
            builder: (context, state) => const CurrentOrdersScreen(),
          ),

          GoRoute(
            path: "sale-order",
            name: "sale-order",
            builder: (context, state) => const ClientInvoiceScreen(
              isOrder: true,
            ),
          ),

          GoRoute(
            path: "client-invoice",
            name: "client-invoice",
            builder: (context, state) => const ClientInvoiceScreen(),
          ),
          GoRoute(
            path: "pending-invoices",
            name: "pending-invoices",
            builder: (context, state) => const PendingInvoiceScreen(),
          ),
          GoRoute(
            path: "daily-receipt-history",
            name: "daily-receipt-history",
            builder: (context, state) => const DailyReceiptScreen(),
          ),

          GoRoute(
            path: "receipt-history",
            name: "receipt-history",
            builder: (context, state) => const ReceiptHistoryScreen(),
          ),

          GoRoute(
            path: "current-devolution",
            name: "current-devolution",
            builder: (context, state) => const CurrentDevolutionsScreen(),
          ),

          GoRoute(
            path: "client-devolution",
            name: "client-devolution",
            builder: (context, state) => const ClientDevolutionScreen(),
          ),

          GoRoute(
            path: "devolution-history",
            name: "devolution-history",
            builder: (context, state) => const DevolutionHistoryScreen(),
          ),

          GoRoute(
            path: "product-price-setting",
            name: "product-price-setting",
            builder: (context, state) => const ProductPriceSettingScreen(),
          ),
          GoRoute(
            path: "product-movements",
            name: "commercial-product-movements",
            builder: (context, state) => const CommercialProductMovementsScreen(),
          ),
        ],
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
          GoRoute(
            path: "product-movements",
            name: "product-movements",
            builder: (context, state) => const ProductMovementsScreen(),
          ),
          GoRoute(
            path: "expiration-logs",
            name: "expiration-logs",
            builder: (context, state) => const ExpirationLogsScreen(),
          ),
        ],
      ),

      GoRoute(
        path: "/finances",
        name: "finances",
        builder: (context, state) => const FinancesMenuScreen(),
        routes: [
          GoRoute(
            path: "client-accounts",
            name: "client-accounts",
            builder: (context, state) => const ClientAccountScreen(),
          ),
          GoRoute(
            path: "paid-invoices",
            name: "paid-invoices",
            builder: (context, state) => const PaidInvoicesScreen(),
          ),
          GoRoute(
            path: "client-movements",
            name: "client-movements",
            builder: (context, state) {
              final client = state.extra as ClientInDb?;
              return ClientMovementsScreen(initialClient: client);
            },
          ),
        ],
      ),

      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: "users",
            name: "users",
            builder: (context, state) => const UsersScreen(),
          ),
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
    ],
  );
}
