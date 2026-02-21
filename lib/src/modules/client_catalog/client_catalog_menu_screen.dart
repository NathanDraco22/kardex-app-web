import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/const_modules.dart';

class ClientCatalogMenuScreen extends StatelessWidget {
  const ClientCatalogMenuScreen({super.key});

  static const accessName = Modules.clients;

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
      appBar: AppBar(title: const Text("Catalogo de Clientes")),
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
            leading: const Icon(FluentIcons.person_12_filled),
            title: const Text("Lista de Clientes"),
            onTap: () {
              context.pushNamed("client-list");
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(
            height: 0.0,
          ),
          ListTile(
            leading: const Icon(Icons.group_work_rounded),
            title: const Text("Grupos de Clientes"),
            onTap: () {
              context.pushNamed("client-groups");
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(
            height: 0.0,
          ),
        ],
      ),
    );
  }
}
