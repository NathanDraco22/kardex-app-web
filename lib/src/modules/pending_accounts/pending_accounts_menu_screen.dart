import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
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
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          ShortcutAddableListTile(
            routeName: RouteNames.pendingInvoices,
            child: MenuOptionCard(
              icon: FluentIcons.document_endnote_24_filled,
              accentColor: Colors.amber.shade700,
              title: "Facturas por Cobrar",
              subtitle: "Créditos pendientes y abonos parciales",
              onTap: () => context.pushNamed("pending-invoices"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.pendingClientTransactions,
            child: MenuOptionCard(
              icon: FluentIcons.history_24_filled,
              accentColor: Colors.blue.shade600,
              title: "Transacciones con Saldo Pendiente",
              subtitle: "Gestión de sesiones de crédito y clientes deudores",
              onTap: () => context.pushNamed("pending-client-transactions"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.unpaidClients,
            child: MenuOptionCard(
              icon: FluentIcons.calendar_error_24_filled,
              accentColor: Colors.red.shade500,
              title: "Días de Impago",
              subtitle: "Antigüedad de saldos y alertas de morosidad",
              onTap: () => context.pushNamed("unpaid-clients"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.invoicePayments,
            child: MenuOptionCard(
              icon: FluentIcons.receipt_sparkles_24_filled,
              accentColor: Colors.teal.shade600,
              title: "Abonos por Factura",
              subtitle: "Historial y registro de pagos por factura",
              onTap: () => context.pushNamed("abonos-por-factura"),
            ),
          ),
        ],
      ),
    );
  }
}
