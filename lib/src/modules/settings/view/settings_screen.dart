import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          ListTile(
            leading: const Icon(Icons.price_change_outlined),
            title: const Text("Precios para Productos"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.pushNamed("product-price");
            },
          ),
          const Divider(height: 0.0),
          ListTile(
            leading: const Icon(Icons.tag),
            title: const Text("Unidades"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.pushNamed("units");
            },
          ),
          const Divider(height: 0.0),

          ListTile(
            leading: const Icon(Icons.other_houses),
            title: const Text("Ramas/Sucursales"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.pushNamed("branches");
            },
          ),
          const Divider(height: 0.0),
        ],
      ),
    );
  }
}
