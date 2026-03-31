import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/admin_reports_menu.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/daily_summary/daily_summary_screen.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/executive_summary/executive_summary_screen.dart';
import 'package:kardex_app_front/admin_panel/admin_panel_screen.dart';
import 'package:kardex_app_front/src/modules/activation/activation_screen.dart';
import 'package:kardex_app_front/src/modules/shortcuts/shortcuts_menu_screen.dart';
import 'package:kardex_app_front/src/modules/advanced_tools/advanced_tools_screen.dart';
import 'package:kardex_app_front/src/modules/advanced_tools/product_stats/product_stats_screen.dart';
import 'package:kardex_app_front/src/modules/advanced_tools/sale_projection/sale_projection_screen.dart';
import 'package:kardex_app_front/src/modules/client_catalog/client_catalog_menu_screen.dart';
import 'package:kardex_app_front/src/modules/client_catalog/client_groups/client_groups_screen.dart';
import 'package:kardex_app_front/src/modules/client_catalog/client_list/view/client_catalog_screen.dart';
import 'package:kardex_app_front/src/modules/client_catalog/cllient_map/client_map_screen.dart';
import 'package:kardex_app_front/src/modules/client_catalog/initial_balance/view/initial_balance_screen.dart';

import 'package:kardex_app_front/src/modules/commercial/anon_devolution/anon_devolution_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/anon_invoices/anon_invoices_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/client_devolution/client_devolution_screen.dart';

import 'package:kardex_app_front/src/modules/commercial/current_proforma/current_proforma_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/client_invoices_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/commercial_menu_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/current_devolutions/current_devolutions_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/current_orders_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_anon_invoinces/daily_anon_invoices_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_client_invoices/daily_client_invoices_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_product_in_orders/daily_product_in_orders_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_product_sales/daily_product_sales_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_receipt/daily_receipt_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/devolution_history/devolution_history_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/invoice_history/invoice_history_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/pending_invoice_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/product_price_setting/product_price_setting.dart';

import 'package:kardex_app_front/src/modules/commercial/proforma/proforma_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/product_movements/view/commercial_product_movements_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/receipt_history/receipt_history_screen.dart';
import 'package:kardex_app_front/src/modules/finance/client_accounts/view/client_account_screen.dart';
import 'package:kardex_app_front/src/modules/finance/client_movements/view/client_movements_screen.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/modules/finance/detail_invoice_history/invoice_history_screen.dart';
import 'package:kardex_app_front/src/modules/finance/finances_menu_screen.dart';
import 'package:kardex_app_front/src/modules/finance/paid_invoices/paid_invoices_screen.dart';
import 'package:kardex_app_front/src/modules/finance/branch_daily_summary/branch_daily_summary_screen.dart';
import 'package:kardex_app_front/src/modules/finance/branch_executive_summary/branch_executive_summary_screen.dart';
import 'package:kardex_app_front/src/modules/home/view/home_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/adjust_entry/adjust_entry_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/create_transfer/create_transfer_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/current_inventory/current_inventory_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/current_tranfers/current_tranfers_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/expiration_logs/expiration_logs_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/history_entry/history_entry_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/history_exit/history_exit_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_entry/view/inventory_entry_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_exit/view/inventory_exit_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_menu_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/adjust_entry/history/adjust_entry_history_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/adjust_exit/history/adjust_exit_history_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/product_price_catalog/product_price_catalog_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/product_inventory_catalog/product_inventory_catalog_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/product_movements/view/product_movements_screen.dart';
import 'package:kardex_app_front/src/modules/login/login_screen.dart';
import 'package:kardex_app_front/src/modules/multi_branch_home/multibranch_home_screen.dart';
import 'package:kardex_app_front/src/modules/pending_accounts/pending_client_transactions/credit_session_transactions_screen.dart';
import 'package:kardex_app_front/src/modules/pending_accounts/pending_accounts_menu_screen.dart';
import 'package:kardex_app_front/src/modules/pending_accounts/pending_client_transactions/pending_client_transactions_menu_screen.dart';
import 'package:kardex_app_front/src/modules/pending_accounts/unpaid_clients/unpaid_clients_screen.dart';
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
import 'package:kardex_app_front/src/modules/settings/view/integrations/integrations_screen.dart';

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
        path: '/shortcuts',
        name: 'shortcuts',
        builder: (context, state) => const ShortcutsMenuScreen(),
      ),

      GoRoute(
        path: '/admin-panel',
        name: 'admin-panel',
        builder: (context, state) => const AdminPanelScreen(),
        routes: [
          GoRoute(
            path: "admin-reports",
            name: "admin-reports",
            builder: (context, state) => const AdminReportsMenuScreen(),
            routes: [
              GoRoute(
                path: "daily-summary",
                name: "daily-summary",
                builder: (context, state) => const DailySummaryScreen(),
              ),
              GoRoute(
                path: "executive-summary",
                name: "executive-summary",
                builder: (context, state) => const ExecutiveSummaryScreen(),
              ),
            ],
          ),
        ],
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
        builder: (context, state) => const ClientCatalogMenuScreen(),
        routes: [
          GoRoute(
            path: "client-list",
            name: "client-list",
            builder: (context, state) => const ClientCatalogScreen(),
          ),
          GoRoute(
            path: "initial-balance",
            name: "initial-balance",
            builder: (context, state) => const InitialBalanceScreen(),
          ),
          GoRoute(
            path: "client-map",
            name: "client-map",
            builder: (context, state) => const ClientMapScreen(),
          ),
          GoRoute(
            path: "client-groups",
            name: "client-groups",
            builder: (context, state) => const ClientGroupsScreen(),
          ),
        ],
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
            path: "daily-client-invoices",
            name: "daily-client-invoices",
            builder: (context, state) => const DailyClientInvoicesScreen(),
          ),

          GoRoute(
            path: "daily-product-sales",
            name: "daily-product-sales",
            builder: (context, state) => const DailyProductSalesScreen(),
          ),

          GoRoute(
            path: "daily-product-in-orders",
            name: "daily-product-in-orders",
            builder: (context, state) => const DailyProductInOrdersScreen(),
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
          GoRoute(
            path: "proforma-history",
            name: "proforma-history",
            builder: (context, state) => const CurrentProformaScreen(),
          ),
          GoRoute(
            path: "proforma",
            name: "proforma",
            builder: (context, state) => const ProformaScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/pending-accounts',
        name: 'pending-accounts',
        builder: (context, state) => const PendingAccountsMenuScreen(),
        routes: [
          GoRoute(
            path: "pending-invoices",
            name: "pending-invoices",
            builder: (context, state) => const PendingInvoiceScreen(),
          ),
          GoRoute(
            path: "pending-client-transactions",
            name: "pending-client-transactions",
            builder: (context, state) => const PendingClientTransactionsMenuScreen(),
            routes: [
              GoRoute(
                path: "credit-session-transactions",
                name: "credit-session-transactions",
                builder: (context, state) {
                  final client = state.extra as ClientInDb;
                  return CreditSessionTransactionsScreen(client: client);
                },
              ),
            ],
          ),
          GoRoute(
            path: "unpaid-clients",
            name: "unpaid-clients",
            builder: (context, state) => const UnpaidClientsScreen(),
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
            path: "current-tranfers",
            name: "current-tranfers",
            builder: (context, state) => const CurrentTranfersScreen(),
          ),
          GoRoute(
            path: "create-transfer",
            name: "create-transfer",
            builder: (context, state) => const CreateTransferScreen(),
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
          GoRoute(
            path: "adjust-entry",
            name: "adjust-entry",
            builder: (context, state) => const AdjustEntryScreen(),
          ),
          GoRoute(
            path: "history-adjust-entry",
            name: "history-adjust-entry",
            builder: (context, state) => const AdjustEntryHistoryScreen(),
          ),
          GoRoute(
            path: "history-adjust-exit",
            name: "history-adjust-exit",
            builder: (context, state) => const AdjustExitHistoryScreen(),
          ),
          GoRoute(
            path: "product-price-catalog",
            name: "product-price-catalog",
            builder: (context, state) => const ProductPriceCatalogScreen(),
          ),
          GoRoute(
            path: "product-inventory-catalog",
            name: "product-inventory-catalog",
            builder: (context, state) => const ProductInventoryCatalogScreen(),
          ),
        ],
      ),

      GoRoute(
        path: "/advanced-tools",
        name: "advanced-tools",
        builder: (context, state) => const AdvancedToolsScreen(),
        routes: [
          GoRoute(
            path: "product-stats",
            name: "product-stats",
            builder: (context, state) => const ProductStatsScreen(),
          ),
          GoRoute(
            path: "sale-projection",
            name: "sale-projection",
            builder: (context, state) => const SaleProjectionScreen(),
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
            path: "detail-invoice-history",
            name: "detail-invoice-history",
            builder: (context, state) => const DetailInvoiceHistoryScreen(),
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
          GoRoute(
            path: "branch-daily-summary",
            name: "branch-daily-summary",
            builder: (context, state) => const BranchDailySummaryScreen(),
          ),
          GoRoute(
            path: "branch-executive-summary",
            name: "branch-executive-summary",
            builder: (context, state) => const BranchExecutiveSummaryScreen(),
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
          GoRoute(
            path: "integrations",
            name: "integrations",
            builder: (context, state) => const IntegrationsScreen(),
          ),
        ],
      ),
    ],
  );
}
