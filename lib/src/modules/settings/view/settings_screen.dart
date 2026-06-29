import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/modules/settings/view/local_printer_settings_dialog.dart';
import 'package:kardex_app_front/widgets/shortcut_addable_list_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static final accessName = Modules.settings.name;

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
      appBar: AppBar(
        title: const Text("Configuraciones"),
      ),
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
          ShortcutAddableListTile(
            routeName: RouteNames.users,
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Usuarios"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.pushNamed("users");
              },
            ),
          ),
          const Divider(height: 0.0),

          ShortcutAddableListTile(
            routeName: RouteNames.branches,
            child: ListTile(
              leading: const Icon(Icons.other_houses),
              title: const Text("Ramas/Sucursales"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.pushNamed("branches");
              },
            ),
          ),
          const Divider(height: 0.0),
          const Divider(height: 0.0),

          ShortcutAddableListTile(
            routeName: RouteNames.integrations,
            child: ListTile(
              leading: const Icon(Icons.integration_instructions),
              title: const Text("Integraciones"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.pushNamed("integrations");
              },
            ),
          ),
          const Divider(height: 0.0),

          ListTile(
            leading: const Icon(Icons.print),
            title: const Text("Configuración de Impresora Local"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showLocalPrinterSettingsDialog(context);
            },
          ),
          const Divider(height: 0.0),
        ],
      ),
    );
  }
}
