import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PendingAccountsMenuScreen extends StatelessWidget {
  const PendingAccountsMenuScreen({super.key});

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
        title: const Text("Cuentas por Cobrar"),
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
            leading: Icon(
              FluentIcons.document_endnote_24_filled,
              size: 32,
              color: Colors.amber.shade600,
            ),
            title: const Text("Facturas por Cobrar"),
            onTap: () {
              context.pushNamed("pending-invoices");
            },
          ),
          const Divider(height: 0.0),
          ListTile(
            leading: Icon(
              FluentIcons.history_24_filled,
              size: 32,
              color: Colors.blue.shade600,
            ),
            title: const Text("Transacciones con Saldo Pendiente"),
            onTap: () {
              context.pushNamed("pending-client-transactions");
            },
          ),
          const Divider(height: 0.0),
          ListTile(
            leading: Icon(
              FluentIcons.calendar_error_24_filled,
              size: 32,
              color: Colors.red.shade400,
            ),
            title: const Text("Días de Impago"),
            onTap: () {
              context.pushNamed("unpaid-clients");
            },
          ),
        ],
      ),
    );
  }
}
