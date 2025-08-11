import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            leading: const Icon(Icons.download_rounded),
            title: const Text("Entrada de Inventario"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed("inventory-entry"),
          ),
          const Divider(height: 0.0),
          ListTile(
            leading: const Icon(Icons.upload_rounded),
            title: const Text("Salida de Inventario"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed("inventory-exit"),
          ),
        ],
      ),
    );
  }
}
