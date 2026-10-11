import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/modules/settings/view/local_printer_settings_dialog.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
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
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          ShortcutAddableListTile(
            routeName: RouteNames.users,
            child: MenuOptionCard(
              icon: Icons.person,
              accentColor: Colors.blue.shade600,
              title: "Usuarios",
              subtitle: "Cuentas de usuario, roles y permisos",
              onTap: () => context.pushNamed("users"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.branches,
            child: MenuOptionCard(
              icon: Icons.other_houses,
              accentColor: Colors.teal.shade600,
              title: "Ramas / Sucursales",
              subtitle: "Gestión de sedes, almacenes y parámetros",
              onTap: () => context.pushNamed("branches"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.integrations,
            child: MenuOptionCard(
              icon: Icons.integration_instructions,
              accentColor: Colors.indigo.shade600,
              title: "Integraciones",
              subtitle: "Servicios periféricos y conexiones",
              onTap: () => context.pushNamed("integrations"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.apiKeys,
            child: MenuOptionCard(
              icon: Icons.key,
              accentColor: Colors.amber.shade700,
              title: "Llaves de API (Neptuno)",
              subtitle: "Credenciales de comunicación y sincronización",
              onTap: () => context.pushNamed(RouteNames.apiKeys),
            ),
          ),
          MenuOptionCard(
            icon: Icons.print,
            accentColor: Colors.blueGrey.shade700,
            title: "Configuración de Impresora Local",
            subtitle: "Configuración de tickets e impresión térmica",
            onTap: () => showLocalPrinterSettingsDialog(context),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.appSettings,
            child: MenuOptionCard(
              icon: Icons.tune_rounded,
              accentColor: Colors.deepPurple.shade600,
              title: "Configuraciones del Sistema",
              subtitle:
                  "Margen de ganancia, vencimientos, órdenes y reglas globales",
              onTap: () => context.pushNamed("app-settings"),
            ),
          ),
        ],
      ),
    );
  }
}
