import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/const_modules.dart';
import 'package:kardex_app_front/src/core/access_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/global_stock_search_modal.dart';
import 'package:kardex_app_front/widgets/menu_app_bar.dart';

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
    return const Scaffold(
      appBar: MenuAppBar(
        title: "Comercio",
      ),
      body: _Body(),
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
          if (accessManager.hasCurrentAccess(context, CommercialSubModules.createInvoice))
            ListTile(
              leading: Icon(
                FluentIcons.building_retail_money_24_filled,
                size: 32,
                color: Colors.green.shade600,
              ),
              title: const Text("Facturacion de productos"),
              onTap: () {
                context.pushNamed("anon-invoice");
              },
            ),

          const Divider(height: 0.0),

          if (accessManager.hasCurrentAccess(context, CommercialSubModules.createInvoice))
            ListTile(
              leading: Icon(
                Icons.date_range,
                size: 32,
                color: Colors.amber.shade600,
              ),
              title: const Text("Ventas diarias"),
              onTap: () {
                context.pushNamed("daily-invoice");
              },
            ),

          const Divider(height: 0.0),

          if (accessManager.hasCurrentAccess(context, CommercialSubModules.createInvoice))
            ListTile(
              leading: Icon(
                Icons.file_open_rounded,
                size: 32,
                color: Colors.blueGrey.shade600,
              ),
              title: const Text("Devolucion de productos"),
              onTap: () {
                context.pushNamed("anon-devolution");
              },
            ),

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

          const Divider(
            height: 4.0,
            thickness: 2,
          ),

          if (accessManager.hasCurrentAccess(context, CommercialSubModules.createInvoice))
            ListTile(
              leading: const Icon(
                Icons.sync,
                size: 32,
                color: Colors.teal,
              ),
              title: const Text("Movimientos de un Producto"),
              onTap: () {
                context.pushNamed("commercial-product-movements");
              },
            ),

          const Divider(height: 0.0),

          if (accessManager.hasCurrentAccess(context, CommercialSubModules.createInvoice))
            ListTile(
              leading: const Icon(Icons.search, color: Colors.purple),
              title: const Text("Consulta de Existencias Globales"),
              onTap: () => showGlobalStockSearchModal(context),
            ),

          const Divider(height: 0.0),

          if (accessManager.hasCurrentAccess(context, CommercialSubModules.createInvoice))
            ListTile(
              leading: Icon(
                Icons.content_paste_search_rounded,
                size: 32,
                color: Colors.green.shade600,
              ),
              title: const Text("Historial de Facturas"),
              onTap: () {
                context.pushNamed("invoice-history");
              },
            ),

          const Divider(height: 0.0),

          if (accessManager.hasCurrentAccess(context, CommercialSubModules.createInvoice))
            ListTile(
              leading: Icon(
                FluentIcons.building_retail_money_24_filled,
                size: 32,
                color: Colors.orange.shade600,
              ),
              title: const Text("Ventas diarias por Producto"),
              onTap: () {
                context.pushNamed("daily-product-sales");
              },
            ),

          const Divider(height: 0.0),

          if (accessManager.hasCurrentAccess(context, CommercialSubModules.createInvoice))
            ListTile(
              leading: Icon(
                Icons.calendar_month,
                size: 32,
                color: Colors.orange.shade800,
              ),
              title: const Text("Ventas Diarias Globales"),
              onTap: () {
                context.pushNamed("daily-client-invoices");
              },
            ),

          const Divider(height: 0.0),

          if (accessManager.hasCurrentAccess(context, CommercialSubModules.createInvoice))
            ListTile(
              leading: Icon(
                Icons.list,
                size: 32,
                color: Colors.orange.shade600,
              ),
              title: const Text("Productos en Ordenes de Compra"),
              onTap: () {
                context.pushNamed("daily-product-in-orders");
              },
            ),

          const Divider(height: 0.0),

          const Divider(
            height: 4.0,
            thickness: 2,
          ),

          if (accessManager.hasCurrentAccess(context, CommercialSubModules.orders))
            ListTile(
              leading: Icon(
                FluentIcons.clipboard_search_24_filled,
                size: 32,
                color: Colors.blue.shade600,
              ),
              title: const Text("Cotizaciones"),
              onTap: () => context.pushNamed("proforma-history"),
            ),

          const Divider(height: 0.0),

          if (accessManager.hasCurrentAccess(context, CommercialSubModules.createOrder))
            ListTile(
              leading: Icon(
                FluentIcons.document_text_24_filled,
                size: 32,
                color: Colors.blue.shade600,
              ),
              title: const Text("Crear Cotización"),
              onTap: () => context.pushNamed("proforma"),
            ),

          const Divider(height: 0.0),
          const Divider(
            height: 4.0,
            thickness: 2,
          ),

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

          if (accessManager.hasCurrentAccess(context, CommercialSubModules.pendingInvoices))
            ListTile(
              leading: Icon(
                Icons.content_paste_search_rounded,
                size: 32,
                color: Colors.teal.shade600,
              ),
              title: const Text("Historial de Recibos"),
              onTap: () {
                context.pushNamed("receipt-history");
              },
            ),
          const Divider(height: 0.0),

          const Divider(
            height: 4.0,
            thickness: 2,
          ),

          if (accessManager.hasCurrentAccess(context, CommercialSubModules.processDevolution))
            ListTile(
              leading: Icon(
                Icons.file_open_rounded,

                size: 32,
                color: Colors.orange.shade600,
              ),
              title: const Text("Devoluciones"),
              onTap: () {
                context.pushNamed("current-devolution");
              },
            ),
          const Divider(height: 0.0),

          if (accessManager.hasCurrentAccess(context, CommercialSubModules.createDevolution))
            ListTile(
              leading: Icon(
                Icons.file_open_rounded,
                size: 32,
                color: Colors.blue.shade600,
              ),
              title: const Text("Crear Devolucion de Productos a Clientes"),
              onTap: () {
                context.pushNamed("client-devolution");
              },
            ),

          const Divider(height: 0.0),

          if (accessManager.hasCurrentAccess(context, CommercialSubModules.createDevolution))
            ListTile(
              leading: Icon(
                Icons.content_paste_search_rounded,
                size: 32,
                color: Colors.orange.shade600,
              ),
              title: const Text("Historial de Devoluciones"),
              onTap: () {
                context.pushNamed("devolution-history");
              },
            ),

          const Divider(height: 0.0),

          const Divider(
            height: 4.0,
            thickness: 2,
          ),

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

          const Divider(
            height: 4.0,
            thickness: 2,
          ),

          ListTile(
            leading: const Icon(
              Icons.timer_sharp,
              color: Colors.amber,
            ),
            title: const Text("Bitacora de Vencimientos"),
            onTap: () => context.pushNamed("expiration-logs"),
          ),
          const Divider(height: 0.0),
        ],
      ),
    );
  }
}
