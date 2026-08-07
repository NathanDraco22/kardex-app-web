import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/widgets/shortcut_addable_list_tile.dart';

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
          ShortcutAddableListTile(
            routeName: RouteNames.pendingInvoices,
            child: ListTile(
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
          ),
          const Divider(height: 0.0),
          ShortcutAddableListTile(
            routeName: RouteNames.pendingClientTransactions,
            child: ListTile(
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
          ),
          const Divider(height: 0.0),
          ShortcutAddableListTile(
            routeName: RouteNames.unpaidClients,
            child: ListTile(
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
          ),
          const Divider(height: 0.0),
          ShortcutAddableListTile(
            routeName: RouteNames.invoicePayments,
            child: ListTile(
              leading: Icon(
                FluentIcons.receipt_sparkles_24_filled,
                size: 32,
                color: Colors.teal.shade600,
              ),
              title: const Text("Abonos por Factura"),
              onTap: () {
                context.pushNamed("abonos-por-factura");
              },
            ),
          ),
        ],
      ),
    );
  }
}
