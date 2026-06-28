import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/user_role/modules.dart';
import 'package:kardex_app_front/src/modules/inventory/adjust_exit/adjust_exit_screen.dart';
import 'package:kardex_app_front/src/domain/models/adjust_exit/adjust_exit_model.dart';
import 'package:kardex_app_front/src/tools/icon_widgets.dart';
import 'package:kardex_app_front/widgets/gates/expiration_date_gate.dart';
import 'package:kardex_app_front/widgets/menu_app_bar.dart';

import 'package:kardex_app_front/widgets/dialogs/search_products/custom_product_commercial_search_delegate.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/widgets/shortcut_addable_list_tile.dart';

class InventoryMenuScreen extends StatelessWidget {
  const InventoryMenuScreen({super.key});

  static final accessName = Modules.inventory.name;

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MenuAppBar(title: "Inventario"),
      body: _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: [
          ShortcutAddableListTile(
            routeName: RouteNames.currentInventory,
            child: ListTile(
              leading: IconWidgets.currentInventoryIcon,
              title: const Text("Inventario Actual"),
              onTap: () => context.pushNamed("current-inventory"),
            ),
          ),
          const Divider(height: 0.0),

          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blueAccent),
            title: const Text("Consulta Rápida de Producto"),
            onTap: () => showProductInfoSearchDelegate(context),
          ),

          const Divider(height: 0.0),

          ShortcutAddableListTile(
            routeName: RouteNames.globalStockSearch,
            child: ListTile(
              leading: const Icon(Icons.search, color: Colors.purple),
              title: const Text("Consulta de Existencias Globales"),
              onTap: () => context.pushNamed("global-stock-search"),
            ),
          ),

          const Divider(height: 0.0),

          ShortcutAddableListTile(
            routeName: RouteNames.productMovements,
            child: ListTile(
              leading: const Icon(
                Icons.sync,
                color: Colors.teal,
              ),
              title: const Text("Movimientos de un Producto"),
              onTap: () => context.pushNamed("product-movements"),
            ),
          ),
          const Divider(height: 0.0),

          ShortcutAddableListTile(
            routeName: RouteNames.productEntryHistory,
            child: ListTile(
              leading: const Icon(
                Icons.call_received,
                color: Colors.orange,
              ),
              title: const Text("Historial de Entradas por Producto"),
              onTap: () => context.pushNamed("product-entry-history"),
            ),
          ),
          const Divider(height: 0.0),

          ShortcutAddableListTile(
            routeName: RouteNames.productPriceCatalog,
            child: ListTile(
              leading: const Icon(
                Icons.monetization_on,
                color: Colors.green,
              ),
              title: const Text("Catalogo de Precios"),
              onTap: () => context.pushNamed("product-price-catalog"),
            ),
          ),
          const Divider(height: 0.0),

          ExpirationDateGate(
            child: ShortcutAddableListTile(
              routeName: RouteNames.expirationLogs,
              child: ListTile(
                leading: const Icon(
                  Icons.timer_sharp,
                  color: Colors.amber,
                ),
                title: const Text("Bitacora de Vencimientos"),
                onTap: () => context.pushNamed("expiration-logs"),
              ),
            ),
          ),
          const Divider(height: 0.0),

          const Divider(
            height: 4.0,
            thickness: 2,
          ),

          ShortcutAddableListTile(
            routeName: RouteNames.inventoryEntry,
            child: ListTile(
              leading: IconWidgets.entryInventoryIcon,
              title: const Text("Entrada de Inventario"),
              onTap: () => context.pushNamed("inventory-entry"),
            ),
          ),
          const Divider(height: 0.0),
          ShortcutAddableListTile(
            routeName: RouteNames.inventoryExit,
            child: ListTile(
              leading: IconWidgets.exitInventoryIcon,
              title: const Text("Salida de Inventario"),
              onTap: () => context.pushNamed("inventory-exit"),
            ),
          ),

          const Divider(height: 0.0),

          ShortcutAddableListTile(
            routeName: RouteNames.historyEntry,
            child: ListTile(
              leading: const Icon(
                FluentIcons.history_28_filled,
                color: Colors.blue,
              ),
              title: const Text("Historial de Entradas"),
              onTap: () => context.pushNamed("history-entry"),
            ),
          ),
          const Divider(height: 0.0),
          ShortcutAddableListTile(
            routeName: RouteNames.historyExit,
            child: ListTile(
              leading: const Icon(
                FluentIcons.history_28_filled,
                color: Colors.red,
              ),
              title: const Text("Historial de salidas"),
              onTap: () => context.pushNamed("history-exit"),
            ),
          ),
          const Divider(height: 0.0),
          const Divider(
            height: 4.0,
            thickness: 2,
          ),

          ShortcutAddableListTile(
            routeName: RouteNames.currentTranfers,
            child: ListTile(
              leading: const Icon(
                Icons.swap_vertical_circle_outlined,
                color: Colors.teal,
                size: 28,
              ),
              title: const Text("Transferencias"),
              onTap: () => context.pushNamed("current-tranfers"),
            ),
          ),

          const Divider(height: 0.0),

          ShortcutAddableListTile(
            routeName: RouteNames.createTransfer,
            child: ListTile(
              leading: const Icon(
                Icons.swap_vert_circle_outlined,
                size: 28,
                color: Colors.red,
              ),
              title: const Text("Crear Transferencia"),
              onTap: () => context.pushNamed("create-transfer"),
            ),
          ),

          const Divider(height: 0.0),

          const Divider(
            height: 4.0,
            thickness: 2,
          ),

          ShortcutAddableListTile(
            routeName: RouteNames.adjustEntry,
            child: ListTile(
              leading: IconWidgets.entryInventoryIcon,
              title: const Text("Entrada por Ajuste"),
              onTap: () => context.pushNamed("adjust-entry"),
            ),
          ),
          const Divider(height: 0.0),

          ShortcutAddableListTile(
            routeName: RouteNames.historyAdjustEntry,
            child: ListTile(
              leading: const Icon(
                FluentIcons.history_28_filled,
                color: Colors.blue,
              ),
              title: const Text("Historial de Entradas por Ajuste"),
              onTap: () => context.pushNamed("history-adjust-entry"),
            ),
          ),

          const Divider(height: 0.0),

          ListTile(
            leading: IconWidgets.exitInventoryIcon,
            title: const Text("Salida por Ajuste"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdjustExitScreen(
                  type: AdjustExitType.adjust,
                ),
              ),
            ),
          ),

          const Divider(height: 0.0),

          ShortcutAddableListTile(
            routeName: RouteNames.historyAdjustExit,
            child: ListTile(
              leading: const Icon(
                FluentIcons.history_28_filled,
                color: Colors.red,
              ),
              title: const Text("Historial de Salidas por Ajuste"),
              onTap: () => context.pushNamed("history-adjust-exit"),
            ),
          ),

          const Divider(height: 0.0),

          ListTile(
            leading: IconWidgets.exitInventoryIcon,
            title: const Text("Mermas"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdjustExitScreen(
                  type: AdjustExitType.loss,
                ),
              ),
            ),
          ),

          const Divider(height: 0.0),
        ],
      ),
    );
  }
}
