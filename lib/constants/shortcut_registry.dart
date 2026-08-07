import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:kardex_app_front/constants/route_names.dart';

class ShortcutInfo {
  final String title;
  final IconData icon;
  final Color? color;

  const ShortcutInfo({
    required this.title,
    required this.icon,
    this.color,
  });
}

class ShortcutRouteRegistry {
  ShortcutRouteRegistry._();

  static final Map<String, ShortcutInfo> routes = {
    // --- Comercio ---
    RouteNames.globalStockSearch: const ShortcutInfo(
      title: "Consulta de Existencias Globales",
      icon: Icons.search,
      color: Color(0xFF9C27B0),
    ),

    RouteNames.anonInvoice: const ShortcutInfo(
      title: "Facturación de productos",
      icon: FluentIcons.building_retail_money_24_filled,
      color: Color(0xFF43A047),
    ),
    RouteNames.dailyInvoice: const ShortcutInfo(
      title: "Ventas diarias",
      icon: Icons.date_range,
      color: Color(0xFFFFB300),
    ),
    RouteNames.anonDevolution: const ShortcutInfo(
      title: "Devolución de productos",
      icon: Icons.file_open_rounded,
      color: Color(0xFF546E7A),
    ),
    RouteNames.clientInvoice: const ShortcutInfo(
      title: "Facturación a Clientes",
      icon: FluentIcons.person_money_20_filled,
      color: Color(0xFF43A047),
    ),
    RouteNames.expirationLogs: const ShortcutInfo(
      title: "Bitácora de Vencimientos",
      icon: Icons.timer_sharp,
      color: Color(0xFFFFCA28),
    ),
    RouteNames.commercialProductMovements: const ShortcutInfo(
      title: "Movimientos de un Producto",
      icon: Icons.sync,
      color: Color(0xFF009688),
    ),
    RouteNames.invoiceHistory: const ShortcutInfo(
      title: "Historial de Facturas",
      icon: Icons.content_paste_search_rounded,
      color: Color(0xFF43A047),
    ),
    RouteNames.invoicesByProduct: const ShortcutInfo(
      title: "Buscar facturas por producto",
      icon: Icons.find_in_page_rounded,
      color: Color(0xFF2E7D32),
    ),
    RouteNames.dailyProductSales: const ShortcutInfo(
      title: "Ventas diarias por Producto",
      icon: FluentIcons.building_retail_money_24_filled,
      color: Color(0xFFFB8C00),
    ),
    RouteNames.dailyClientInvoices: const ShortcutInfo(
      title: "Ventas por factura",
      icon: Icons.calendar_month,
      color: Color(0xFFEF6C00),
    ),
    RouteNames.dailyProductInOrders: const ShortcutInfo(
      title: "Productos en Órdenes de Compra",
      icon: Icons.list,
      color: Color(0xFFFB8C00),
    ),
    RouteNames.productDemandVsStock: const ShortcutInfo(
      title: "Cotizaciones vs Existencias",
      icon: Icons.analytics_outlined,
      color: Color(0xFF1565C0),
    ),
    RouteNames.proformaHistory: const ShortcutInfo(
      title: "Cotizaciones",
      icon: FluentIcons.clipboard_search_24_filled,
      color: Color(0xFF1E88E5),
    ),
    RouteNames.proforma: const ShortcutInfo(
      title: "Crear Cotización",
      icon: FluentIcons.document_text_24_filled,
      color: Color(0xFF1E88E5),
    ),
    RouteNames.currentOrders: const ShortcutInfo(
      title: "Órdenes de Compra",
      icon: FluentIcons.receipt_bag_24_filled,
      color: Color(0xFFFB8C00),
    ),
    RouteNames.saleOrder: const ShortcutInfo(
      title: "Crear Orden de Compra",
      icon: FluentIcons.receipt_add_24_filled,
      color: Color(0xFF29B6F6),
    ),
    RouteNames.receiptHistory: const ShortcutInfo(
      title: "Historial de Recibos",
      icon: Icons.content_paste_search_rounded,
      color: Color(0xFF00897B),
    ),
    RouteNames.currentDevolution: const ShortcutInfo(
      title: "Devoluciones",
      icon: Icons.file_open_rounded,
      color: Color(0xFFFB8C00),
    ),
    RouteNames.clientDevolution: const ShortcutInfo(
      title: "Crear Devolución de Productos a Clientes",
      icon: Icons.file_open_rounded,
      color: Color(0xFF1E88E5),
    ),
    RouteNames.devolutionHistory: const ShortcutInfo(
      title: "Historial de Devoluciones",
      icon: Icons.content_paste_search_rounded,
      color: Color(0xFFFB8C00),
    ),

    // --- Inventario ---
    RouteNames.currentInventory: const ShortcutInfo(
      title: "Inventario Actual",
      icon: FluentIcons.book_toolbox_24_filled,
      color: Color(0xFF009688),
    ),
    RouteNames.productInventoryCatalog: const ShortcutInfo(
      title: "Catálogo de Inventario",
      icon: Icons.inventory,
      color: Color(0xFF4CAF50),
    ),
    RouteNames.productMovements: const ShortcutInfo(
      title: "Movimientos de un Producto",
      icon: Icons.sync,
      color: Color(0xFF009688),
    ),
    RouteNames.productEntryHistory: const ShortcutInfo(
      title: "Historial de Entradas por Producto",
      icon: Icons.call_received,
      color: Color(0xFFFF9800),
    ),
    RouteNames.productPriceCatalog: const ShortcutInfo(
      title: "Catálogo de Precios",
      icon: Icons.monetization_on,
      color: Color(0xFF4CAF50),
    ),
    RouteNames.inventoryEntry: const ShortcutInfo(
      title: "Entrada de Inventario",
      icon: FluentIcons.arrow_down_left_12_filled,
      color: Color(0xFF2196F3),
    ),
    RouteNames.inventoryExit: const ShortcutInfo(
      title: "Salida de Inventario",
      icon: FluentIcons.arrow_up_right_12_filled,
      color: Color(0xFFF44336),
    ),
    RouteNames.historyEntry: const ShortcutInfo(
      title: "Historial de Entradas",
      icon: FluentIcons.history_28_filled,
      color: Color(0xFF2196F3),
    ),
    RouteNames.historyExit: const ShortcutInfo(
      title: "Historial de Salidas",
      icon: FluentIcons.history_28_filled,
      color: Color(0xFFF44336),
    ),
    RouteNames.currentTranfers: const ShortcutInfo(
      title: "Transferencias",
      icon: Icons.swap_vertical_circle_outlined,
      color: Color(0xFF009688),
    ),
    RouteNames.createTransfer: const ShortcutInfo(
      title: "Crear Transferencia",
      icon: Icons.swap_vert_circle_outlined,
      color: Color(0xFFF44336),
    ),
    RouteNames.adjustEntry: const ShortcutInfo(
      title: "Entrada por Ajuste",
      icon: FluentIcons.arrow_down_left_12_filled,
      color: Color(0xFF2196F3),
    ),
    RouteNames.historyAdjustEntry: const ShortcutInfo(
      title: "Historial de Entradas por Ajuste",
      icon: FluentIcons.history_28_filled,
      color: Color(0xFF2196F3),
    ),
    RouteNames.historyAdjustExit: const ShortcutInfo(
      title: "Historial de Salidas por Ajuste",
      icon: FluentIcons.history_28_filled,
      color: Color(0xFFF44336),
    ),

    // --- Finanzas ---
    RouteNames.dailyOperationsResults: const ShortcutInfo(
      title: "Resultado de Operaciones Diarias",
      icon: Icons.analytics_outlined,
      color: Color(0xFFFF9800),
    ),
    RouteNames.clientAccounts: const ShortcutInfo(
      title: "Estado de cuenta de Clientes",
      icon: FluentIcons.notepad_person_24_filled,
      color: Color(0xFF2196F3),
    ),
    RouteNames.detailInvoiceHistory: const ShortcutInfo(
      title: "Historial Detallado de Facturas",
      icon: Icons.content_paste_search_rounded,
      color: Color(0xFF4CAF50),
    ),
    RouteNames.paidInvoices: const ShortcutInfo(
      title: "Facturas Liquidadas",
      icon: FluentIcons.receipt_money_24_filled,
      color: Color(0xFF4CAF50),
    ),
    RouteNames.branchDailySummary: const ShortcutInfo(
      title: "Resumen Diario",
      icon: Icons.bar_chart_rounded,
      color: Color(0xFF2196F3),
    ),
    RouteNames.branchExecutiveSummary: const ShortcutInfo(
      title: "Resumen Ejecutivo",
      icon: Icons.pie_chart_rounded,
      color: Color(0xFF9C27B0),
    ),

    // --- Catálogo de Productos ---
    RouteNames.productList: const ShortcutInfo(
      title: "Lista Global de Productos",
      icon: FluentIcons.cube_12_filled,
    ),
    RouteNames.units: const ShortcutInfo(
      title: "Unidades de Medida de Productos",
      icon: Icons.tag,
    ),
    RouteNames.productCategory: const ShortcutInfo(
      title: "Lista de Categorías de Productos",
      icon: Icons.category_rounded,
    ),

    // --- Catálogo de Clientes ---
    RouteNames.clientList: const ShortcutInfo(
      title: "Lista de Clientes",
      icon: FluentIcons.person_12_filled,
    ),
    RouteNames.initialBalance: const ShortcutInfo(
      title: "Saldos Iniciales",
      icon: Icons.account_balance_wallet_rounded,
    ),
    RouteNames.clientMap: const ShortcutInfo(
      title: "Mapa de Clientes",
      icon: Icons.map_rounded,
    ),
    RouteNames.clientGroups: const ShortcutInfo(
      title: "Grupos de Clientes",
      icon: Icons.group_work_rounded,
    ),

    // --- Gastos ---
    RouteNames.operativeExpenses: const ShortcutInfo(
      title: "Gastos Operativos",
      icon: Icons.monetization_on,
      color: Color(0xFF4CAF50),
    ),
    RouteNames.supplierExpenses: const ShortcutInfo(
      title: "Compras a Proveedores",
      icon: Icons.shopping_cart,
      color: Color(0xFFFF9800),
    ),
    RouteNames.expenseCategories: const ShortcutInfo(
      title: "Categorías de Gastos",
      icon: Icons.category,
      color: Color(0xFF3F51B5),
    ),
    RouteNames.expensesReport: const ShortcutInfo(
      title: "Reporte de Gastos",
      icon: Icons.assessment,
      color: Color(0xFF2196F3),
    ),

    // --- Cuentas por Cobrar ---
    RouteNames.pendingInvoices: const ShortcutInfo(
      title: "Facturas por Cobrar",
      icon: FluentIcons.document_endnote_24_filled,
      color: Color(0xFFFFB300),
    ),
    RouteNames.pendingClientTransactions: const ShortcutInfo(
      title: "Transacciones con Saldo Pendiente",
      icon: FluentIcons.history_24_filled,
      color: Color(0xFF1E88E5),
    ),
    RouteNames.unpaidClients: const ShortcutInfo(
      title: "Días de Impago",
      icon: FluentIcons.calendar_error_24_filled,
      color: Color(0xFFEF5350),
    ),
    RouteNames.invoicePayments: const ShortcutInfo(
      title: "Abonos por Factura",
      icon: FluentIcons.receipt_sparkles_24_filled,
      color: Color(0xFF00897B),
    ),

    // --- Herramientas Avanzadas ---
    RouteNames.productStats: const ShortcutInfo(
      title: "Estimación de Productos por Ventas",
      icon: Icons.calculate,
      color: Color(0xFF2196F3),
    ),
    RouteNames.saleProjection: const ShortcutInfo(
      title: "Proyección de Ventas",
      icon: Icons.calculate,
      color: Color(0xFF4CAF50),
    ),

    // --- Configuraciones ---
    RouteNames.users: const ShortcutInfo(
      title: "Usuarios",
      icon: Icons.person,
    ),
    RouteNames.branches: const ShortcutInfo(
      title: "Ramas/Sucursales",
      icon: Icons.other_houses,
    ),
    RouteNames.integrations: const ShortcutInfo(
      title: "Integraciones",
      icon: Icons.integration_instructions,
    ),
  };
}
