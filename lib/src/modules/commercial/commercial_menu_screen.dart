import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/const_modules.dart';
import 'package:kardex_app_front/src/core/access_manager.dart';

class CommercialMenuScreen extends StatelessWidget {
  const CommercialMenuScreen({super.key});

  static const accessName = Modules.commercial;

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
    final accessManager = AccessManager();
    return Center(
      child: ListView(
        children: [
          if (accessManager.hasCurrentAccess(context, CommercialSubModules.orders))
            ListTile(
              leading: Icon(
                FluentIcons.receipt_bag_24_filled,
                size: 32,
                color: Colors.orange.shade600,
              ),
              title: const Text("Ordenes de Compra"),
              onTap: () {
                context.pushNamed("current-orders");
              },
            ),
          const Divider(height: 0.0),
          if (accessManager.hasCurrentAccess(context, CommercialSubModules.createOrder))
            ListTile(
              leading: Icon(
                FluentIcons.receipt_add_24_filled,
                size: 32,
                color: Colors.lightBlue.shade600,
              ),
              title: const Text("Crear Orden de Compra"),
              onTap: () {
                context.pushNamed("sale-order");
              },
            ),
          const Divider(height: 0.0),
          if (accessManager.hasCurrentAccess(context, CommercialSubModules.createInvoice))
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

          if (accessManager.hasCurrentAccess(context, CommercialSubModules.pendingInvoices))
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

          if (accessManager.hasCurrentAccess(context, CommercialSubModules.invoiceHistory))
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

          if (accessManager.hasCurrentAccess(context, CommercialSubModules.priceSetting))
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
