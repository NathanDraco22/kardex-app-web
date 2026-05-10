import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/const_modules.dart';

import 'package:kardex_app_front/src/tools/icon_widgets.dart';
import 'package:kardex_app_front/widgets/gates/expiration_date_gate.dart';
import 'package:kardex_app_front/widgets/menu_app_bar.dart';

import 'package:kardex_app_front/widgets/dialogs/global_stock_search_modal.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/custom_product_commercial_search_delegate.dart';

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
            leading: const Icon(FluentIcons.cube_12_filled),
            title: const Text("Lista Global de Productos"),
            onTap: () {
              context.pushNamed("product-list");
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(
            height: 0.0,
          ),

          ListTile(
            leading: const Icon(Icons.tag),
            title: const Text("Unidades de Medida de Productos"),
            onTap: () {
              context.pushNamed("units");
            },
          ),
          const Divider(height: 0.0),
          ListTile(
            leading: const Icon(Icons.category_rounded),
            title: const Text("Lista de Categorias de Productos"),
            onTap: () {
              context.pushNamed("product-category");
            },
          ),

          const Divider(
            height: 4.0,
            thickness: 2,
          ),

          ListTile(
            leading: IconWidgets.currentInventoryIcon,
            title: const Text("Inventario Actual"),
            onTap: () => context.pushNamed("current-inventory"),
          ),
          const Divider(height: 0.0),

          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blueAccent),
            title: const Text("Consulta Rápida de Producto"),
            onTap: () => showProductInfoSearchDelegate(context),
          ),

          const Divider(height: 0.0),

          ListTile(
            leading: const Icon(Icons.search, color: Colors.purple),
            title: const Text("Consulta de Existencias Globales"),
            onTap: () => showGlobalStockSearchModal(context),
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

          ExpirationDateGate(
            child: ListTile(
              leading: const Icon(
                Icons.timer_sharp,
                color: Colors.amber,
              ),
              title: const Text("Bitacora de Vencimientos"),
              onTap: () => context.pushNamed("expiration-logs"),
            ),
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
            onTap: () => context.pushNamed("create-transfer"),
          ),

          const Divider(height: 0.0),
        ],
      ),
    );
  }
}
