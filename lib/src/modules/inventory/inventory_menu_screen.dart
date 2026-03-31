import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/const_modules.dart';
import 'package:kardex_app_front/src/modules/inventory/adjust_exit/adjust_exit_screen.dart';
import 'package:kardex_app_front/src/domain/models/adjust_exit/adjust_exit_model.dart';
import 'package:kardex_app_front/src/tools/icon_widgets.dart';
import 'package:kardex_app_front/widgets/menu_app_bar.dart';

import 'package:kardex_app_front/widgets/dialogs/global_stock_search_modal.dart';

class InventoryMenuScreen extends StatelessWidget {
  const InventoryMenuScreen({super.key});

  static const accessName = Modules.inventory;

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
          ListTile(
            leading: IconWidgets.currentInventoryIcon,
            title: const Text("Inventario Actual"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed("current-inventory"),
          ),
          const Divider(height: 0.0),

          ListTile(
            leading: const Icon(Icons.search, color: Colors.purple),
            title: const Text("Consulta de Existencias Globales"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showGlobalStockSearchModal(context),
          ),

          const Divider(height: 0.0),

          ListTile(
            leading: const Icon(
              Icons.sync,
              color: Colors.teal,
            ),
            title: const Text("Movimientos de un Producto"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed("product-movements"),
          ),
          const Divider(height: 0.0),

          ListTile(
            leading: const Icon(
              Icons.monetization_on,
              color: Colors.green,
            ),
            title: const Text("Precios de productos"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed("product-price-catalog"),
          ),
          const Divider(height: 0.0),

          ListTile(
            leading: const Icon(
              Icons.inventory,
              color: Colors.blueGrey,
            ),
            title: const Text("Catálogo de Inventario"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed("product-inventory-catalog"),
          ),
          const Divider(height: 0.0),

          ListTile(
            leading: const Icon(
              Icons.timer_sharp,
              color: Colors.amber,
            ),
            title: const Text("Bitacora de Vencimientos"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed("expiration-logs"),
          ),
          const Divider(height: 0.0),

          const Divider(
            height: 4.0,
            thickness: 2,
          ),

          ListTile(
            leading: IconWidgets.entryInventoryIcon,
            title: const Text("Entrada de Inventario"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed("inventory-entry"),
          ),
          const Divider(height: 0.0),
          ListTile(
            leading: IconWidgets.exitInventoryIcon,
            title: const Text("Salida de Inventario"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed("inventory-exit"),
          ),

          const Divider(height: 0.0),

          ListTile(
            leading: const Icon(
              FluentIcons.history_28_filled,
              color: Colors.blue,
            ),
            title: const Text("Historial de Entradas"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed("history-entry"),
          ),
          const Divider(height: 0.0),
          ListTile(
            leading: const Icon(
              FluentIcons.history_28_filled,
              color: Colors.red,
            ),
            title: const Text("Historial de salidas"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed("history-exit"),
          ),
          const Divider(height: 0.0),
          const Divider(
            height: 4.0,
            thickness: 2,
          ),

          ListTile(
            leading: const Icon(
              Icons.swap_vertical_circle_outlined,
              color: Colors.teal,
              size: 28,
            ),
            title: const Text("Transferencias"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed("current-tranfers"),
          ),

          const Divider(height: 0.0),

          ListTile(
            leading: const Icon(
              Icons.swap_vert_circle_outlined,
              size: 28,
              color: Colors.red,
            ),
            title: const Text("Crear Transferencia"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed("create-transfer"),
          ),

          const Divider(height: 0.0),

          const Divider(
            height: 4.0,
            thickness: 2,
          ),

          ListTile(
            leading: IconWidgets.entryInventoryIcon,
            title: const Text("Entrada por Ajuste"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed("adjust-entry"),
          ),
          const Divider(height: 0.0),

          ListTile(
            leading: const Icon(
              FluentIcons.history_28_filled,
              color: Colors.blue,
            ),
            title: const Text("Historial de Entradas por Ajuste"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed("history-adjust-entry"),
          ),

          const Divider(height: 0.0),

          ListTile(
            leading: IconWidgets.exitInventoryIcon,
            title: const Text("Salida por Ajuste"),
            trailing: const Icon(Icons.chevron_right),
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

          ListTile(
            leading: const Icon(
              FluentIcons.history_28_filled,
              color: Colors.red,
            ),
            title: const Text("Historial de Salidas por Ajuste"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed("history-adjust-exit"),
          ),

          const Divider(height: 0.0),

          ListTile(
            leading: IconWidgets.exitInventoryIcon,
            title: const Text("Mermas"),
            trailing: const Icon(Icons.chevron_right),
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
