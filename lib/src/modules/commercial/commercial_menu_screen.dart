import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommercialMenuScreen extends StatelessWidget {
  const CommercialMenuScreen({super.key});

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
      appBar: AppBar(title: const Text("Menu Comercio")),
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
              FluentIcons.person_money_20_filled,
              size: 32,
              color: Colors.green.shade600,
            ),
            title: const Text("Facturacion a Clientes"),
            onTap: () {
              context.pushNamed("client-invoice");
            },
          ),
          const Divider(height: 0.0),

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
              FluentIcons.history_28_filled,
              size: 32,
              color: Colors.teal.shade600,
            ),
            title: const Text("Historial de Facturacion a Clientes"),
            onTap: () {
              context.pushNamed("invoice-history");
            },
          ),
          const Divider(height: 0.0),

          ListTile(
            leading: Icon(
              FluentIcons.money_calculator_20_filled,
              size: 32,
              color: Colors.blue.shade600,
            ),
            title: const Text("Configuracion de Precios de Productos"),
            onTap: () {
              context.pushNamed("product-price-setting");
            },
          ),
          const Divider(height: 0.0),
        ],
      ),
    );
  }
}
