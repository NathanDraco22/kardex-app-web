import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FinancesMenuScreen extends StatelessWidget {
  const FinancesMenuScreen({super.key});

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
      appBar: AppBar(title: const Text("Finanzas")),
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
            leading: const Icon(
              FluentIcons.notepad_person_24_filled,
              color: Colors.blue,
            ),
            title: const Text("Estado de cuenta de Clientes"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed("client-accounts"),
          ),
          const Divider(height: 0.0),
          ListTile(
            leading: const Icon(
              FluentIcons.receipt_money_24_filled,
              color: Colors.green,
            ),
            title: const Text("Facturas Liquidadas"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed("paid-invoices"),
          ),
          const Divider(height: 0.0),
        ],
      ),
    );
  }
}
