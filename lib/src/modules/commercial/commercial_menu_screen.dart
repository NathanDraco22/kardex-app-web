import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_app_front/widgets/gates/role_permission_gate.dart';
import 'package:kardex_app_front/widgets/gates/expiration_date_gate.dart';
import 'package:kardex_app_front/widgets/gates/orders_gate.dart';
import 'package:kardex_app_front/widgets/gates/quotations_gate.dart';
import 'package:kardex_app_front/widgets/menu_app_bar.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial/search_product_commercial_delegate.dart';
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
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const MenuSectionDivider(
            title: "Punto de Venta y Facturación",
            isFirst: true,
          ),
          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.saleTerminal,
              child: MenuOptionCard(
                icon: FluentIcons.cart_24_filled,
                accentColor: Colors.teal.shade600,
                title: "Terminal de Venta",
                subtitle: "Punto de venta ágil para mostrador",
                onTap: () => context.pushNamed("sale-terminal"),
              ),
            ),
          ),
          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.anonInvoice,
              child: MenuOptionCard(
                icon: FluentIcons.building_retail_money_24_filled,
                accentColor: Colors.green.shade600,
                title: "Facturación de productos",
                subtitle: "Venta rápida sin cliente registrado",
                onTap: () => context.pushNamed("anon-invoice"),
              ),
            ),
          ),
          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.userOperationsResults,
              child: MenuOptionCard(
                icon: Icons.badge_outlined,
                accentColor: Colors.teal.shade700,
                title: "Arqueo y Resultados por Usuario",
                subtitle: "Corte de caja y auditoría por cajero",
                onTap: () => context.pushNamed("user-operations-results"),
              ),
            ),
          ),
          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.dailyInvoice,
              child: MenuOptionCard(
                icon: Icons.date_range,
                accentColor: Colors.amber.shade700,
                title: "Ventas diarias",
                subtitle: "Facturas emitidas durante la jornada",
                onTap: () => context.pushNamed("daily-invoice"),
              ),
            ),
          ),
          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.clientInvoice,
              child: MenuOptionCard(
                icon: FluentIcons.person_money_20_filled,
                accentColor: Colors.green.shade600,
                title: "Facturación a Clientes",
                subtitle: "Emisión formal de facturas con cliente",
                onTap: () => context.pushNamed("client-invoice"),
              ),
            ),
          ),
          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.clientInvoiceWholesale,
              child: MenuOptionCard(
                icon: FluentIcons.person_money_20_filled,
                accentColor: Colors.blue.shade600,
                title: "Facturación a Clientes (Mayorista)",
                subtitle: "Ventas al por mayor con listas de precio",
                onTap: () => context.pushNamed("client-invoice-wholesale"),
              ),
            ),
          ),

          const MenuSectionDivider(title: "Consultas y Existencias"),

          ExpirationDateGate(
            child: ShortcutAddableListTile(
              routeName: RouteNames.expirationLogs,
              child: MenuOptionCard(
                icon: Icons.timer_sharp,
                accentColor: Colors.amber.shade700,
                title: "Bitácora de Vencimientos",
                subtitle: "Control preventivo de fechas de caducidad",
                onTap: () => context.pushNamed("expiration-logs"),
              ),
            ),
          ),
          // RolePermissionGate(
          //   permissions: [CommercialSubModules.createInvoice],
          //   child: ShortcutAddableListTile(
          //     routeName: RouteNames.commercialProductMovements,
          //     child: MenuOptionCard(
          //       icon: Icons.sync,
          //       accentColor: Colors.teal.shade600,
          //       title: "Movimientos de un Producto",
          //       subtitle: "Trazabilidad de entradas, salidas y ventas",
          //       onTap: () => context.pushNamed("commercial-product-movements"),
          //     ),
          //   ),
          // ),
          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: MenuOptionCard(
              icon: Icons.info_outline,
              accentColor: Colors.blueAccent,
              title: "Consulta Rápida de Producto",
              subtitle: "Búsqueda instantánea con existencias y precios",
              onTap: () => showProductInfoSearchDelegate(context),
            ),
          ),
          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.globalStockSearch,
              child: MenuOptionCard(
                icon: Icons.search,
                accentColor: Colors.purple.shade600,
                title: "Consulta de Existencias Globales",
                subtitle: "Stock consolidado en todas las sucursales",
                onTap: () => context.pushNamed("global-stock-search"),
              ),
            ),
          ),
          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.invoiceHistory,
              child: MenuOptionCard(
                icon: Icons.content_paste_search_rounded,
                accentColor: Colors.green.shade600,
                title: "Historial de Facturas",
                subtitle: "Búsqueda y consulta de comprobantes fiscales",
                onTap: () => context.pushNamed("invoice-history"),
              ),
            ),
          ),
          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.invoicesByProduct,
              child: MenuOptionCard(
                icon: Icons.find_in_page_rounded,
                accentColor: Colors.green.shade800,
                title: "Buscar facturas por producto",
                subtitle: "Facturas asociadas a un artículo específico",
                onTap: () => context.pushNamed("invoices-by-product"),
              ),
            ),
          ),
          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.dailyProductSales,
              child: MenuOptionCard(
                icon: FluentIcons.building_retail_money_24_filled,
                accentColor: Colors.orange.shade700,
                title: "Ventas diarias por Producto",
                subtitle: "Unidades facturadas en la jornada",
                onTap: () => context.pushNamed("daily-product-sales"),
              ),
            ),
          ),
          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.dailyClientInvoices,
              child: MenuOptionCard(
                icon: Icons.calendar_month,
                accentColor: Colors.orange.shade800,
                title: "Ventas por factura",
                subtitle: "Desglose por cliente y fecha",
                onTap: () => context.pushNamed("daily-client-invoices"),
              ),
            ),
          ),
          OrdersGate(
            child: RolePermissionGate(
              permissions: [CommercialSubModules.createInvoice],
              child: ShortcutAddableListTile(
                routeName: RouteNames.dailyProductInOrders,
                child: MenuOptionCard(
                  icon: Icons.list,
                  accentColor: Colors.orange.shade600,
                  title: "Productos en Órdenes de Compra",
                  subtitle: "Seguimiento de pedidos activos",
                  onTap: () => context.pushNamed("daily-product-in-orders"),
                ),
              ),
            ),
          ),
          QuotationsGate(
            child: RolePermissionGate(
              permissions: [CommercialSubModules.createInvoice],
              child: ShortcutAddableListTile(
                routeName: RouteNames.productDemandVsStock,
                child: MenuOptionCard(
                  icon: Icons.analytics_outlined,
                  accentColor: Colors.blue.shade800,
                  title: "Cotizaciones vs Existencias",
                  subtitle: "Demanda potencial comparada con almacén",
                  onTap: () => context.pushNamed("product-demand-vs-stock"),
                ),
              ),
            ),
          ),

          const QuotationsGate(
            child: MenuSectionDivider(title: "Cotizaciones y Proformas"),
          ),

          QuotationsGate(
            child: RolePermissionGate(
              permissions: [CommercialSubModules.orders],
              child: ShortcutAddableListTile(
                routeName: RouteNames.proformaHistory,
                child: MenuOptionCard(
                  icon: FluentIcons.clipboard_search_24_filled,
                  accentColor: Colors.blue.shade600,
                  title: "Cotizaciones",
                  subtitle: "Historial y seguimiento de presupuestos",
                  onTap: () => context.pushNamed("proforma-history"),
                ),
              ),
            ),
          ),
          QuotationsGate(
            child: RolePermissionGate(
              permissions: [CommercialSubModules.createOrder],
              child: ShortcutAddableListTile(
                routeName: RouteNames.proforma,
                child: MenuOptionCard(
                  icon: FluentIcons.document_text_24_filled,
                  accentColor: Colors.blue.shade600,
                  title: "Crear Cotización",
                  subtitle: "Nuevo presupuesto para cliente",
                  onTap: () => context.pushNamed("proforma"),
                ),
              ),
            ),
          ),
          QuotationsGate(
            child: RolePermissionGate(
              permissions: [CommercialSubModules.createOrder],
              child: ShortcutAddableListTile(
                routeName: RouteNames.proformaWholesale,
                child: MenuOptionCard(
                  icon: FluentIcons.document_text_24_filled,
                  accentColor: Colors.blue.shade800,
                  title: "Crear Cotización (Mayorista)",
                  subtitle: "Cotización con tarifas al por mayor",
                  onTap: () => context.pushNamed("proforma-wholesale"),
                ),
              ),
            ),
          ),
          QuotationsOrOrdersGate(
            child: RolePermissionGate(
              permissions: [CommercialSubModules.orders],
              child: ShortcutAddableListTile(
                routeName: RouteNames.quotationOrderSearch,
                child: MenuOptionCard(
                  icon: Icons.manage_search,
                  accentColor: Colors.indigo.shade600,
                  title: "Buscador de Cotizaciones/Órdenes",
                  subtitle: "Rastreo por folio, fecha o cliente",
                  onTap: () => context.pushNamed("quotation-order-search"),
                ),
              ),
            ),
          ),

          const MenuSectionDivider(title: "Órdenes de Compra y Recibos"),

          OrdersGate(
            child: RolePermissionGate(
              permissions: [CommercialSubModules.orders],
              child: ShortcutAddableListTile(
                routeName: RouteNames.currentOrders,
                child: MenuOptionCard(
                  icon: FluentIcons.receipt_bag_24_filled,
                  accentColor: Colors.orange.shade600,
                  title: "Órdenes de Compra",
                  subtitle: "Control y facturación de pedidos pendientes",
                  onTap: () => context.pushNamed("current-orders"),
                ),
              ),
            ),
          ),
          OrdersGate(
            child: RolePermissionGate(
              permissions: [CommercialSubModules.createOrder],
              child: ShortcutAddableListTile(
                routeName: RouteNames.saleOrder,
                child: MenuOptionCard(
                  icon: FluentIcons.receipt_add_24_filled,
                  accentColor: Colors.lightBlue.shade600,
                  title: "Crear Órden de Compra",
                  subtitle: "Nuevo pedido formal de compra",
                  onTap: () => context.pushNamed("sale-order"),
                ),
              ),
            ),
          ),
          OrdersGate(
            child: RolePermissionGate(
              permissions: [CommercialSubModules.createOrder],
              child: ShortcutAddableListTile(
                routeName: RouteNames.saleOrderWholesale,
                child: MenuOptionCard(
                  icon: FluentIcons.receipt_add_24_filled,
                  accentColor: Colors.blue.shade600,
                  title: "Crear Órden de Compra (Mayorista)",
                  subtitle: "Nuevo pedido con tarifas de volumen",
                  onTap: () => context.pushNamed("sale-order-wholesale"),
                ),
              ),
            ),
          ),
          RolePermissionGate(
            permissions: [CommercialSubModules.pendingInvoices],
            child: ShortcutAddableListTile(
              routeName: RouteNames.receiptHistory,
              child: MenuOptionCard(
                icon: Icons.content_paste_search_rounded,
                accentColor: Colors.teal.shade600,
                title: "Historial de Recibos",
                subtitle: "Consulta de comprobantes y recibos de pago",
                onTap: () => context.pushNamed("receipt-history"),
              ),
            ),
          ),

          const MenuSectionDivider(title: "Devoluciones"),

          RolePermissionGate(
            permissions: [CommercialSubModules.processDevolution],
            child: ShortcutAddableListTile(
              routeName: RouteNames.currentDevolution,
              child: MenuOptionCard(
                icon: Icons.file_open_rounded,
                accentColor: Colors.orange.shade600,
                title: "Devoluciones",
                subtitle: "Gestión y seguimiento de retornos",
                onTap: () => context.pushNamed("current-devolution"),
              ),
            ),
          ),
          RolePermissionGate(
            permissions: [CommercialSubModules.createInvoice],
            child: ShortcutAddableListTile(
              routeName: RouteNames.devolutions,
              child: MenuOptionCard(
                icon: Icons.file_open_rounded,
                accentColor: Colors.blueGrey.shade600,
                title: "Crear Devolución de productos",
                subtitle: "Reingreso por falla o garantía",
                onTap: () => context.pushNamed("devolutions"),
              ),
            ),
          ),
          RolePermissionGate(
            permissions: [CommercialSubModules.createDevolution],
            child: ShortcutAddableListTile(
              routeName: RouteNames.clientDevolution,
              child: MenuOptionCard(
                icon: Icons.file_open_rounded,
                accentColor: Colors.blue.shade600,
                title: "Crear Devolución de Productos a Clientes",
                subtitle: "Devolución asociada a factura de cliente",
                onTap: () => context.pushNamed("client-devolution"),
              ),
            ),
          ),
          RolePermissionGate(
            permissions: [CommercialSubModules.createDevolution],
            child: ShortcutAddableListTile(
              routeName: RouteNames.devolutionHistory,
              child: MenuOptionCard(
                icon: Icons.content_paste_search_rounded,
                accentColor: Colors.orange.shade700,
                title: "Historial de Devoluciones",
                subtitle: "Auditoría de devoluciones registradas",
                onTap: () => context.pushNamed("devolution-history"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
