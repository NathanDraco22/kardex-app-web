import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/src/modules/inventory/adjust_exit/adjust_exit_screen.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_app_front/widgets/gates/expiration_date_gate.dart';
import 'package:kardex_app_front/widgets/menu_app_bar.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial/search_product_commercial_delegate.dart';
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
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const MenuSectionDivider(
            title: "Existencias y Consultas",
            isFirst: true,
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.currentInventory,
            child: MenuOptionCard(
              icon: FluentIcons.archive_24_filled,
              accentColor: Colors.teal.shade600,
              title: "Inventario Actual",
              subtitle: "Existencias en tiempo real por sucursal",
              onTap: () => context.pushNamed("current-inventory"),
            ),
          ),
          MenuOptionCard(
            icon: Icons.info_outline,
            accentColor: Colors.blueAccent,
            title: "Consulta Rápida de Producto",
            subtitle: "Búsqueda ágil de existencias y precios",
            onTap: () => showProductInfoSearchDelegate(context),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.globalStockSearch,
            child: MenuOptionCard(
              icon: Icons.search,
              accentColor: Colors.purple.shade600,
              title: "Consulta de Existencias Globales",
              subtitle: "Stock consolidado en todas las bodegas",
              onTap: () => context.pushNamed("global-stock-search"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.productMovements,
            child: MenuOptionCard(
              icon: Icons.sync,
              accentColor: Colors.teal.shade600,
              title: "Movimientos de un Producto",
              subtitle: "Kárdex físico y auditoría de inventario",
              onTap: () => context.pushNamed("product-movements"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.productEntryHistory,
            child: MenuOptionCard(
              icon: Icons.call_received,
              accentColor: Colors.orange.shade700,
              title: "Historial de Entradas por Producto",
              subtitle: "Detalle cronológico de abastecimiento",
              onTap: () => context.pushNamed("product-entry-history"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.productPriceCatalog,
            child: MenuOptionCard(
              icon: Icons.monetization_on,
              accentColor: Colors.green.shade600,
              title: "Catálogo de Precios",
              subtitle: "Tarifas mayoristas, minoristas y costos",
              onTap: () => context.pushNamed("product-price-catalog"),
            ),
          ),
          ExpirationDateGate(
            child: ShortcutAddableListTile(
              routeName: RouteNames.expirationLogs,
              child: MenuOptionCard(
                icon: Icons.timer_sharp,
                accentColor: Colors.amber.shade700,
                title: "Bitácora de Vencimientos",
                subtitle: "Lotes próximos a caducar y alertas",
                onTap: () => context.pushNamed("expiration-logs"),
              ),
            ),
          ),

          const MenuSectionDivider(title: "Entradas y Salidas de Mercancía"),

          ShortcutAddableListTile(
            routeName: RouteNames.inventoryEntry,
            child: MenuOptionCard(
              icon: FluentIcons.arrow_download_24_filled,
              accentColor: Colors.blue.shade600,
              title: "Entrada de Inventario",
              subtitle: "Recepción y abastecimiento de mercancía",
              onTap: () => context.pushNamed("inventory-entry"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.inventoryExit,
            child: MenuOptionCard(
              icon: FluentIcons.arrow_upload_24_filled,
              accentColor: Colors.red.shade600,
              title: "Salida de Inventario",
              subtitle: "Descarga formal de existencias",
              onTap: () => context.pushNamed("inventory-exit"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.historyEntry,
            child: MenuOptionCard(
              icon: FluentIcons.history_24_filled,
              accentColor: Colors.blue.shade600,
              title: "Historial de Entradas",
              subtitle: "Auditoría de ingresos completados",
              onTap: () => context.pushNamed("history-entry"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.historyExit,
            child: MenuOptionCard(
              icon: FluentIcons.history_24_filled,
              accentColor: Colors.red.shade600,
              title: "Historial de Salidas",
              subtitle: "Auditoría de egresos procesados",
              onTap: () => context.pushNamed("history-exit"),
            ),
          ),

          const MenuSectionDivider(title: "Transferencias entre Sucursales"),

          ShortcutAddableListTile(
            routeName: RouteNames.currentTranfers,
            child: MenuOptionCard(
              icon: Icons.swap_vertical_circle_outlined,
              accentColor: Colors.teal.shade600,
              title: "Transferencias",
              subtitle: "Envíos en tránsito entre almacenes",
              onTap: () => context.pushNamed("current-tranfers"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.createTransfer,
            child: MenuOptionCard(
              icon: Icons.swap_vert_circle_outlined,
              accentColor: Colors.indigo.shade600,
              title: "Crear Transferencia",
              subtitle: "Traslado intersucursal de mercancía",
              onTap: () => context.pushNamed("create-transfer"),
            ),
          ),

          const MenuSectionDivider(title: "Ajustes y Mermas"),

          ShortcutAddableListTile(
            routeName: RouteNames.adjustEntry,
            child: MenuOptionCard(
              icon: Icons.add_circle_outline_rounded,
              accentColor: Colors.blue.shade600,
              title: "Entrada por Ajuste",
              subtitle: "Regularización positiva de inventario",
              onTap: () => context.pushNamed("adjust-entry"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.historyAdjustEntry,
            child: MenuOptionCard(
              icon: FluentIcons.history_24_filled,
              accentColor: Colors.blue.shade600,
              title: "Historial de Entradas por Ajuste",
              subtitle: "Auditoría de ajustes de entrada",
              onTap: () => context.pushNamed("history-adjust-entry"),
            ),
          ),
          MenuOptionCard(
            icon: Icons.remove_circle_outline_rounded,
            accentColor: Colors.red.shade600,
            title: "Salida por Ajuste",
            subtitle: "Corrección negativa por conteo físico",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdjustExitScreen(
                  type: AdjustExitType.adjust,
                ),
              ),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.historyAdjustExit,
            child: MenuOptionCard(
              icon: FluentIcons.history_24_filled,
              accentColor: Colors.red.shade600,
              title: "Historial de Salidas por Ajuste",
              subtitle: "Auditoría de correcciones de salida",
              onTap: () => context.pushNamed("history-adjust-exit"),
            ),
          ),
          MenuOptionCard(
            icon: Icons.delete_sweep_rounded,
            accentColor: Colors.red.shade700,
            title: "Mermas",
            subtitle: "Registro de productos dañados o pérdida",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdjustExitScreen(
                  type: AdjustExitType.loss,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
