import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/tools/icon_widgets.dart';

class InventoryMenuScreen extends StatelessWidget {
  const InventoryMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventario")),
      body: const _Body(),
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
        ],
      ),
    );
  }
}
