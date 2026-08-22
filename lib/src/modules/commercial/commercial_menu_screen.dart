import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/gates/role_permission_gate.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial/search_product_commercial_delegate.dart';
import 'package:kardex_app_front/widgets/gates/expiration_date_gate.dart';
import 'package:kardex_app_front/widgets/menu_app_bar.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/widgets/shortcut_addable_list_tile.dart';

class CommercialMenuScreen extends StatelessWidget {
  const CommercialMenuScreen({super.key});

  static final accessName = Modules.commercial.name;

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
      resizeToAvoidBottomInset: false,
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
    return Center(
      child: ListView(
        children: [
          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.saleTerminal,
              child: ListTile(
                leading: Icon(
                  FluentIcons.cart_24_filled,
                  size: 32,
                  color: Colors.teal.shade600,
                ),
                title: const Text("Terminal de Venta"),
                onTap: () {
                  context.pushNamed("sale-terminal");
                },
              ),
            ),
          ),

          const Divider(height: 0.0),

          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.anonInvoice,
              child: ListTile(
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
            ),
          ),

          const Divider(height: 0.0),

          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.dailyInvoice,
              child: ListTile(
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
            ),
          ),

          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.clientInvoice,
              child: ListTile(
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
            ),
          ),

          const Divider(height: 0.0),

          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.clientInvoiceWholesale,
              child: ListTile(
                leading: Icon(
                  FluentIcons.person_money_20_filled,
                  size: 32,
                  color: Colors.blue.shade600,
                ),
                title: const Text("Facturacion a Clientes (Mayorista)"),
                onTap: () {
                  context.pushNamed("client-invoice-wholesale");
                },
              ),
            ),
          ),

          const Divider(height: 0.0),

          const Divider(
            height: 4.0,
            thickness: 2,
          ),

          ExpirationDateGate(
            child: ShortcutAddableListTile(
              routeName: RouteNames.expirationLogs,
              child: ListTile(
                leading: const Icon(
                  Icons.timer_sharp,
                  color: Colors.amber,
                ),
                title: const Text("Bitacora de Vencimientos"),
                onTap: () => context.pushNamed("expiration-logs"),
              ),
            ),
          ),
          const Divider(height: 0.0),

          // RolePermissionGate(
          //   permissions: [CommercialSubModules.createInvoice],
          //   child: ShortcutAddableListTile(
          //     routeName: RouteNames.commercialProductMovements,
          //     child: ListTile(
          //       leading: const Icon(
          //         Icons.sync,
          //         size: 32,
          //         color: Colors.teal,
          //       ),
          //       title: const Text("Movimientos de un Producto"),
          //       onTap: () {
          //         context.pushNamed("commercial-product-movements");
          //       },
          //     ),
          //   ),
          // ),

          // const Divider(height: 0.0),
          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.blueAccent),
              title: const Text("Consulta Rápida de Producto"),
              onTap: () => showProductInfoSearchDelegate(context),
            ),
          ),

          const Divider(height: 0.0),

          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.globalStockSearch,
              child: ListTile(
                leading: const Icon(Icons.search, color: Colors.purple),
                title: const Text("Consulta de Existencias Globales"),
                onTap: () => context.pushNamed("global-stock-search"),
              ),
            ),
          ),

          const Divider(height: 0.0),

          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.invoiceHistory,
              child: ListTile(
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
            ),
          ),

          const Divider(height: 0.0),

          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.invoicesByProduct,
              child: ListTile(
                leading: Icon(
                  Icons.find_in_page_rounded,
                  size: 32,
                  color: Colors.green.shade800,
                ),
                title: const Text("Buscar facturas por producto"),
                onTap: () {
                  context.pushNamed("invoices-by-product");
                },
              ),
            ),
          ),

          const Divider(height: 0.0),

          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.dailyProductSales,
              child: ListTile(
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
            ),
          ),

          const Divider(height: 0.0),

          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.dailyClientInvoices,
              child: ListTile(
                leading: Icon(
                  Icons.calendar_month,
                  size: 32,
                  color: Colors.orange.shade800,
                ),
                title: const Text("Ventas por factura"),
                onTap: () {
                  context.pushNamed("daily-client-invoices");
                },
              ),
            ),
          ),

          const Divider(height: 0.0),

          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.dailyProductInOrders,
              child: ListTile(
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
            ),
          ),

          const Divider(height: 0.0),

          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.productDemandVsStock,
              child: ListTile(
                leading: Icon(
                  Icons.analytics_outlined,
                  size: 32,
                  color: Colors.blue.shade800,
                ),
                title: const Text("Cotizaciones vs Existencias"),
                onTap: () {
                  context.pushNamed("product-demand-vs-stock");
                },
              ),
            ),
          ),
          const Divider(height: 0.0),

          const Divider(
            height: 4.0,
            thickness: 2,
          ),

          RolePermissionGate(
            permissions: [CommercialSubModules.orders],
            child: ShortcutAddableListTile(
              routeName: RouteNames.proformaHistory,
              child: ListTile(
                leading: Icon(
                  FluentIcons.clipboard_search_24_filled,
                  size: 32,
                  color: Colors.blue.shade600,
                ),
                title: const Text("Cotizaciones"),
                onTap: () => context.pushNamed("proforma-history"),
              ),
            ),
          ),

          const Divider(height: 0.0),

          RolePermissionGate(
            permissions: [CommercialSubModules.createOrder],
            child: ShortcutAddableListTile(
              routeName: RouteNames.proforma,
              child: ListTile(
                leading: Icon(
                  FluentIcons.document_text_24_filled,
                  size: 32,
                  color: Colors.blue.shade600,
                ),
                title: const Text("Crear Cotización"),
                onTap: () => context.pushNamed("proforma"),
              ),
            ),
          ),

          const Divider(height: 0.0),

          RolePermissionGate(
            permissions: [CommercialSubModules.createOrder],
            child: ShortcutAddableListTile(
              routeName: RouteNames.proformaWholesale,
              child: ListTile(
                leading: Icon(
                  FluentIcons.document_text_24_filled,
                  size: 32,
                  color: Colors.blue.shade800,
                ),
                title: const Text("Crear Cotización (Mayorista)"),
                onTap: () => context.pushNamed("proforma-wholesale"),
              ),
            ),
          ),

          const Divider(height: 0.0),

          RolePermissionGate(
            permissions: [CommercialSubModules.orders],
            child: ShortcutAddableListTile(
              routeName: RouteNames.quotationOrderSearch,
              child: ListTile(
                leading: Icon(
                  Icons.manage_search,
                  size: 32,
                  color: Colors.indigo.shade600,
                ),
                title: const Text("Buscador de Cotizaciones/Órdenes"),
                onTap: () {
                  context.pushNamed("quotation-order-search");
                },
              ),
            ),
          ),

          const Divider(height: 0.0),
          const Divider(
            height: 4.0,
            thickness: 2,
          ),

          RolePermissionGate(
            permissions: [CommercialSubModules.orders],
            child: ShortcutAddableListTile(
              routeName: RouteNames.currentOrders,
              child: ListTile(
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
            ),
          ),
          const Divider(height: 0.0),

          RolePermissionGate(
            permissions: [CommercialSubModules.createOrder],
            child: ShortcutAddableListTile(
              routeName: RouteNames.saleOrder,
              child: ListTile(
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
            ),
          ),

          const Divider(height: 0.0),

          RolePermissionGate(
            permissions: [CommercialSubModules.createOrder],
            child: ShortcutAddableListTile(
              routeName: RouteNames.saleOrderWholesale,
              child: ListTile(
                leading: Icon(
                  FluentIcons.receipt_add_24_filled,
                  size: 32,
                  color: Colors.blue.shade600,
                ),
                title: const Text("Crear Orden de Compra (Mayorista)"),
                onTap: () {
                  context.pushNamed("sale-order-wholesale");
                },
              ),
            ),
          ),

          const Divider(height: 0.0),

          RolePermissionGate(
            permissions: [CommercialSubModules.pendingInvoices],
            child: ShortcutAddableListTile(
              routeName: RouteNames.receiptHistory,
              child: ListTile(
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
            ),
          ),
          const Divider(height: 0.0),

          const Divider(
            height: 4.0,
            thickness: 2,
          ),

          RolePermissionGate(
            permissions: [CommercialSubModules.processDevolution],
            child: ShortcutAddableListTile(
              routeName: RouteNames.currentDevolution,
              child: ListTile(
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
            ),
          ),

          const Divider(height: 0.0),

          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.devolutions,
              child: ListTile(
                leading: Icon(
                  Icons.file_open_rounded,
                  size: 32,
                  color: Colors.blueGrey.shade600,
                ),
                title: const Text("Crear Devolucion de productos"),
                onTap: () {
                  context.pushNamed("devolutions");
                },
              ),
            ),
          ),

          const Divider(height: 0.0),

          RolePermissionGate(
            permissions: [CommercialSubModules.createDevolution],
            child: ShortcutAddableListTile(
              routeName: RouteNames.clientDevolution,
              child: ListTile(
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
            ),
          ),
          const Divider(height: 0.0),

          RolePermissionGate(
            permissions: [CommercialSubModules.createDevolution],
            child: ShortcutAddableListTile(
              routeName: RouteNames.devolutionHistory,
              child: ListTile(
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
            ),
          ),

          const Divider(height: 0.0),
        ],
      ),
    );
  }
}
