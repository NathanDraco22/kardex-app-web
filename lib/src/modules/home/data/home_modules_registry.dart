import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/adjust_exit/adjust_exit_screen.dart';
import 'package:kardex_app_front/src/modules/settings/view/local_printer_settings_dialog.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/clients_catalog_template.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/src/tools/icon_widgets.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/client_full_details_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/simple_search_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial/search_product_commercial_delegate.dart';
import 'package:kardex_business/kardex_business.dart';

enum HomeModuleId {
  clients,
  suppliers,
  products,
  commercial,
  pendingAccounts,
  inventory,
  expenses,
  finance,
  advancedTools,
  settings,
}

class HomeSubmoduleItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? accentColor;
  final String? routeName;
  final void Function(BuildContext context)? customAction;
  final List<Enum> permissions;
  final bool isExpirationGate;
  final String? section;

  const HomeSubmoduleItem({
    required this.title,
    this.subtitle,
    required this.icon,
    this.accentColor,
    this.routeName,
    this.customAction,
    this.permissions = const [],
    this.isExpirationGate = false,
    this.section,
  });
}

class HomeModuleCategory {
  final HomeModuleId id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final List<Modules> permissions;
  final bool isCommerceOnly;
  final String mobileRoute;
  final List<HomeSubmoduleItem> submodules;

  const HomeModuleCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.permissions,
    this.isCommerceOnly = false,
    required this.mobileRoute,
    required this.submodules,
  });
}

List<HomeModuleCategory> getHomeModuleCategories(
  BuildContext context, [
  BranchInDb? branch,
]) {
  final currentBranch = branch ?? getIt<AuthCubit>().currentBranch;
  final isCommerce = currentBranch?.isCommerce ?? true;

  final categories = <HomeModuleCategory>[
    HomeModuleCategory(
      id: HomeModuleId.clients,
      title: "Clientes",
      subtitle: "Directorio, saldos iniciales, mapas y grupos",
      icon: FluentIcons.contact_card_16_filled,
      accentColor: const Color(0xFF2563EB),
      permissions: const [Modules.clients],
      mobileRoute: "client-catalog",
      submodules: [
        const HomeSubmoduleItem(
          title: "Lista de Clientes",
          subtitle: "Directorio general de clientes y saldos",
          icon: FluentIcons.person_12_filled,
          accentColor: Color(0xFF2563EB),
          routeName: "client-list",
        ),
        const HomeSubmoduleItem(
          title: "Saldos Iniciales",
          subtitle: "Asignación y ajuste de saldos iniciales",
          icon: Icons.account_balance_wallet_rounded,
          accentColor: Color(0xFF0D9488),
          routeName: "initial-balance",
        ),
        HomeSubmoduleItem(
          title: "Buscar por #Cédula",
          subtitle: "Búsqueda directa e información del cliente",
          icon: FluentIcons.search_12_filled,
          accentColor: const Color(0xFF4F46E5),
          customAction: (ctx) {
            final clientRepo = ctx.read<ClientsRepository>();
            showSimpleSearchDialog(
              ctx,
              searchFuture: (value) {
                if (value.isEmpty) {
                  return Future.error("La cédula no puede estar vacía");
                }
                return clientRepo.getClientByCardId(value.toUpperCase());
              },
              title: "Buscar Cliente por #Cédula",
              onResult: (value) {
                showClientFullDetailsDialog(ctx, client: value);
              },
            );
          },
        ),
        const HomeSubmoduleItem(
          title: "Mapa de Clientes",
          subtitle: "Geolocalización en mapa interactivo",
          icon: Icons.map_rounded,
          accentColor: Color(0xFFEA580C),
          routeName: "client-map",
        ),
        const HomeSubmoduleItem(
          title: "Grupos de Clientes",
          subtitle: "Segmentación y clasificación comercial",
          icon: Icons.group_work_rounded,
          accentColor: Color(0xFF9333EA),
          routeName: "client-groups",
        ),
        HomeSubmoduleItem(
          title: "Exportar Clientes (PDF)",
          subtitle: "Descargar catálogo completo en documento PDF",
          icon: Icons.picture_as_pdf,
          accentColor: const Color(0xFFE11D48),
          customAction: (ctx) async {
            LoadingDialogManager.showLoadingDialog(ctx);
            try {
              final clientRepo = ctx.read<ClientsRepository>();
              final clientsList = await clientRepo.getAllClients();
              final template = ClientsCatalogTemplate(
                branchName: getIt<AuthCubit>().currentBranchName,
                clients: clientsList,
              );
              await PdfExportTool.export(template, fileName: "catalogo_clientes.pdf");
              if (ctx.mounted) Navigator.pop(ctx);
            } catch (e) {
              if (ctx.mounted) {
                Navigator.pop(ctx);
                DialogManager.showErrorDialog(ctx, e.toString());
              }
            }
          },
        ),
      ],
    ),
    const HomeModuleCategory(
      id: HomeModuleId.suppliers,
      title: "Proveedores",
      subtitle: "Directorio de proveedores y condiciones comerciales",
      icon: FluentIcons.building_multiple_20_filled,
      accentColor: Color(0xFF0D9488),
      permissions: [Modules.suppliers],
      mobileRoute: "suppliers-catalog",
      submodules: [
        HomeSubmoduleItem(
          title: "Lista de Proveedores",
          subtitle: "Gestión de proveedores, contactos y plazos",
          icon: FluentIcons.building_multiple_20_filled,
          accentColor: Color(0xFF0D9488),
          routeName: "suppliers-catalog",
        ),
      ],
    ),
    const HomeModuleCategory(
      id: HomeModuleId.products,
      title: "Catálogo de Productos",
      subtitle: "Lista global, categorías y unidades de medida",
      icon: FluentIcons.receipt_bag_20_filled,
      accentColor: Color(0xFF7C3AED),
      permissions: [Modules.products],
      mobileRoute: "product-catalog",
      submodules: [
        HomeSubmoduleItem(
          title: "Lista Global de Productos",
          subtitle: "Inventario maestro, precios y códigos de barra",
          icon: FluentIcons.cube_12_filled,
          accentColor: Color(0xFF7C3AED),
          routeName: "product-list",
        ),
        HomeSubmoduleItem(
          title: "Unidades de Medida",
          subtitle: "Factores de conversión y unidades de empaque",
          icon: Icons.tag,
          accentColor: Color(0xFF2563EB),
          routeName: "units",
        ),
        HomeSubmoduleItem(
          title: "Categorías de Productos",
          subtitle: "Clasificación de familias y líneas de producto",
          icon: Icons.category_rounded,
          accentColor: Color(0xFFEA580C),
          routeName: "product-category",
        ),
      ],
    ),
    if (isCommerce)
      HomeModuleCategory(
        id: HomeModuleId.commercial,
        title: "Comercio",
        subtitle: "Terminal POS, facturación, cotizaciones y pedidos",
        icon: FluentIcons.money_calculator_20_filled,
        accentColor: const Color(0xFF059669),
        permissions: const [Modules.commercial],
        isCommerceOnly: true,
        mobileRoute: "commercial",
        submodules: [
          // Sección 1: Punto de Venta y Facturación
          const HomeSubmoduleItem(
            section: "Punto de Venta y Facturación",
            title: "Terminal de Venta (POS)",
            subtitle: "Punto de venta ágil para mostrador",
            icon: FluentIcons.cart_24_filled,
            accentColor: Color(0xFF0D9488),
            routeName: "sale-terminal",
            permissions: [CommercialSubModules.createInvoice],
          ),
          const HomeSubmoduleItem(
            section: "Punto de Venta y Facturación",
            title: "Facturación de Productos",
            subtitle: "Venta rápida sin cliente registrado",
            icon: FluentIcons.building_retail_money_24_filled,
            accentColor: Color(0xFF16A34A),
            routeName: "anon-invoice",
            permissions: [CommercialSubModules.createInvoice],
          ),
          const HomeSubmoduleItem(
            section: "Punto de Venta y Facturación",
            title: "Arqueo y Resultados por Usuario",
            subtitle: "Control de caja por turno y cajero",
            icon: Icons.badge_outlined,
            accentColor: Color(0xFF0F766E),
            routeName: "user-operations-results",
            permissions: [CommercialSubModules.createInvoice],
          ),
          const HomeSubmoduleItem(
            section: "Punto de Venta y Facturación",
            title: "Ventas Diarias",
            subtitle: "Resumen cronológico de facturación del día",
            icon: Icons.date_range,
            accentColor: Color(0xFFD97706),
            routeName: "daily-invoice",
            permissions: [CommercialSubModules.createInvoice],
          ),
          const HomeSubmoduleItem(
            section: "Punto de Venta y Facturación",
            title: "Facturación a Clientes",
            subtitle: "Facturación personalizada con condición de pago",
            icon: FluentIcons.person_money_20_filled,
            accentColor: Color(0xFF16A34A),
            routeName: "client-invoice",
            permissions: [CommercialSubModules.createInvoice],
          ),
          const HomeSubmoduleItem(
            section: "Punto de Venta y Facturación",
            title: "Facturación a Clientes (Mayorista)",
            subtitle: "Precios y condiciones por volumen o fardo",
            icon: FluentIcons.person_money_20_filled,
            accentColor: Color(0xFF2563EB),
            routeName: "client-invoice-wholesale",
            permissions: [CommercialSubModules.createInvoice],
          ),
          const HomeSubmoduleItem(
            section: "Punto de Venta y Facturación",
            title: "Ventas por Factura",
            subtitle: "Detalle desagregado de comprobantes",
            icon: Icons.calendar_month,
            accentColor: Color(0xFFEA580C),
            routeName: "daily-client-invoices",
            permissions: [CommercialSubModules.createInvoice],
          ),
          const HomeSubmoduleItem(
            section: "Punto de Venta y Facturación",
            title: "Ventas Diarias por Producto",
            subtitle: "Cantidades e importes acumulados por ítem",
            icon: FluentIcons.building_retail_money_24_filled,
            accentColor: Color(0xFFF59E0B),
            routeName: "daily-product-sales",
            permissions: [CommercialSubModules.createInvoice],
          ),
          const HomeSubmoduleItem(
            section: "Punto de Venta y Facturación",
            title: "Historial de Facturas",
            subtitle: "Búsqueda, reimpresión y estado de documentos",
            icon: Icons.content_paste_search_rounded,
            accentColor: Color(0xFF16A34A),
            routeName: "invoice-history",
            permissions: [CommercialSubModules.createInvoice],
          ),
          const HomeSubmoduleItem(
            section: "Punto de Venta y Facturación",
            title: "Buscar Facturas por Producto",
            subtitle: "Localización de transacciones por artículo",
            icon: Icons.find_in_page_rounded,
            accentColor: Color(0xFF15803D),
            routeName: "invoices-by-product",
            permissions: [CommercialSubModules.createInvoice],
          ),

          // Sección 2: Consultas y Existencias
          const HomeSubmoduleItem(
            section: "Consultas y Existencias",
            title: "Existencias Globales",
            subtitle: "Disponibilidad en todas las sucursales",
            icon: Icons.search,
            accentColor: Color(0xFF9333EA),
            routeName: "global-stock-search",
            permissions: [CommercialSubModules.createInvoice],
          ),
          HomeSubmoduleItem(
            section: "Consultas y Existencias",
            title: "Consulta Rápida de Producto",
            subtitle: "Verificación de precio y stock sin salir",
            icon: Icons.info_outline,
            accentColor: const Color(0xFF2563EB),
            customAction: (ctx) => showProductInfoSearchDelegate(ctx),
            permissions: const [CommercialSubModules.createInvoice],
          ),
          const HomeSubmoduleItem(
            section: "Consultas y Existencias",
            title: "Movimientos de un Producto",
            subtitle: "Trazabilidad de ventas y rotación de ítems",
            icon: Icons.sync,
            accentColor: Color(0xFF0D9488),
            routeName: "commercial-product-movements",
            permissions: [CommercialSubModules.createInvoice],
          ),
          const HomeSubmoduleItem(
            section: "Consultas y Existencias",
            title: "Bitácora de Vencimientos",
            subtitle: "Alerta de lotes próximos a expirar",
            icon: Icons.timer_sharp,
            accentColor: Color(0xFFD97706),
            routeName: "expiration-logs",
            isExpirationGate: true,
          ),
          const HomeSubmoduleItem(
            section: "Consultas y Existencias",
            title: "Cotizaciones vs Existencias",
            subtitle: "Comparación de demanda contra stock real",
            icon: Icons.analytics_outlined,
            accentColor: Color(0xFF1D4ED8),
            routeName: "product-demand-vs-stock",
            permissions: [CommercialSubModules.createInvoice],
          ),
          const HomeSubmoduleItem(
            section: "Consultas y Existencias",
            title: "Productos en Órdenes de Compra",
            subtitle: "Artículos comprometidos en pedidos",
            icon: Icons.list,
            accentColor: Color(0xFFEA580C),
            routeName: "daily-product-in-orders",
            permissions: [CommercialSubModules.createInvoice],
          ),

          // Sección 3: Cotizaciones y Proformas
          const HomeSubmoduleItem(
            section: "Cotizaciones y Proformas",
            title: "Cotizaciones (Historial)",
            subtitle: "Consulta y gestión de proformas emitidas",
            icon: FluentIcons.clipboard_search_24_filled,
            accentColor: Color(0xFF2563EB),
            routeName: "proforma-history",
            permissions: [CommercialSubModules.orders],
          ),
          const HomeSubmoduleItem(
            section: "Cotizaciones y Proformas",
            title: "Crear Cotización",
            subtitle: "Generar nueva cotización a cliente",
            icon: FluentIcons.document_text_24_filled,
            accentColor: Color(0xFF3B82F6),
            routeName: "proforma",
            permissions: [CommercialSubModules.createOrder],
          ),
          const HomeSubmoduleItem(
            section: "Cotizaciones y Proformas",
            title: "Crear Cotización (Mayorista)",
            subtitle: "Cotización aplicando tarifas por volumen",
            icon: FluentIcons.document_text_24_filled,
            accentColor: Color(0xFF1D4ED8),
            routeName: "proforma-wholesale",
            permissions: [CommercialSubModules.createOrder],
          ),
          const HomeSubmoduleItem(
            section: "Cotizaciones y Proformas",
            title: "Buscador de Cotizaciones/Órdenes",
            subtitle: "Localización avanzada por cliente o fecha",
            icon: Icons.manage_search,
            accentColor: Color(0xFF4F46E5),
            routeName: "quotation-order-search",
            permissions: [CommercialSubModules.orders],
          ),

          // Sección 4: Órdenes de Compra y Cobranza
          const HomeSubmoduleItem(
            section: "Órdenes de Compra y Recibos",
            title: "Órdenes de Compra",
            subtitle: "Seguimiento y facturación de pedidos",
            icon: FluentIcons.receipt_bag_24_filled,
            accentColor: Color(0xFFEA580C),
            routeName: "current-orders",
            permissions: [CommercialSubModules.orders],
          ),
          const HomeSubmoduleItem(
            section: "Órdenes de Compra y Recibos",
            title: "Crear Orden de Compra",
            subtitle: "Ingreso de nuevo pedido para despacho",
            icon: FluentIcons.receipt_add_24_filled,
            accentColor: Color(0xFF0284C7),
            routeName: "sale-order",
            permissions: [CommercialSubModules.createOrder],
          ),
          const HomeSubmoduleItem(
            section: "Órdenes de Compra y Recibos",
            title: "Crear Orden (Mayorista)",
            subtitle: "Pedido formal con lista mayorista",
            icon: FluentIcons.receipt_add_24_filled,
            accentColor: Color(0xFF2563EB),
            routeName: "sale-order-wholesale",
            permissions: [CommercialSubModules.createOrder],
          ),
          const HomeSubmoduleItem(
            section: "Órdenes de Compra y Recibos",
            title: "Historial de Recibos",
            subtitle: "Comprobantes de pago y cancelaciones",
            icon: Icons.content_paste_search_rounded,
            accentColor: Color(0xFF0D9488),
            routeName: "receipt-history",
            permissions: [CommercialSubModules.pendingInvoices],
          ),

          // Sección 5: Devoluciones
          const HomeSubmoduleItem(
            section: "Devoluciones",
            title: "Devoluciones en Proceso",
            subtitle: "Borradores y devoluciones pendientes",
            icon: Icons.file_open_rounded,
            accentColor: Color(0xFFEA580C),
            routeName: "current-devolution",
            permissions: [CommercialSubModules.processDevolution],
          ),
          const HomeSubmoduleItem(
            section: "Devoluciones",
            title: "Crear Devolución de Productos",
            subtitle: "Retorno de mercancía por factura de venta",
            icon: Icons.file_open_rounded,
            accentColor: Color(0xFF475569),
            routeName: "devolutions",
            permissions: [CommercialSubModules.createInvoice],
          ),
          const HomeSubmoduleItem(
            section: "Devoluciones",
            title: "Devolución de Clientes (Crédito)",
            subtitle: "Devolución con compensación en cartera",
            icon: Icons.file_open_rounded,
            accentColor: Color(0xFF2563EB),
            routeName: "client-devolution",
            permissions: [CommercialSubModules.createDevolution],
          ),
          const HomeSubmoduleItem(
            section: "Devoluciones",
            title: "Historial de Devoluciones",
            subtitle: "Auditoría de devoluciones efectuadas",
            icon: Icons.content_paste_search_rounded,
            accentColor: Color(0xFFEA580C),
            routeName: "devolution-history",
            permissions: [CommercialSubModules.createDevolution],
          ),
        ],
      ),
    if (isCommerce)
      const HomeModuleCategory(
        id: HomeModuleId.pendingAccounts,
        title: "Cuentas por Cobrar",
        subtitle: "Facturas por cobrar, transacciones y abonos",
        icon: FluentIcons.receipt_money_24_filled,
        accentColor: Color(0xFFD97706),
        permissions: [Modules.pendingInvoices],
        isCommerceOnly: true,
        mobileRoute: "pending-accounts",
        submodules: [
          HomeSubmoduleItem(
            title: "Facturas por Cobrar",
            subtitle: "Cartera pendiente clasificada por cliente",
            icon: FluentIcons.document_endnote_24_filled,
            accentColor: Color(0xFFD97706),
            routeName: "pending-invoices",
          ),
          HomeSubmoduleItem(
            title: "Transacciones con Saldo Pendiente",
            subtitle: "Movimientos a crédito pendientes de liquidar",
            icon: FluentIcons.history_24_filled,
            accentColor: Color(0xFF2563EB),
            routeName: "pending-client-transactions",
          ),
          HomeSubmoduleItem(
            title: "Días de Impago",
            subtitle: "Control de antigüedad de saldos y mora",
            icon: FluentIcons.calendar_error_24_filled,
            accentColor: Color(0xFFE11D48),
            routeName: "unpaid-clients",
          ),
          HomeSubmoduleItem(
            title: "Abonos por Factura",
            subtitle: "Registro de pagos parciales y abonos de clientes",
            icon: FluentIcons.receipt_sparkles_24_filled,
            accentColor: Color(0xFF0D9488),
            routeName: "abonos-por-factura",
          ),
        ],
      ),
    HomeModuleCategory(
      id: HomeModuleId.inventory,
      title: "Inventario",
      subtitle: "Existencias, entradas, salidas, transferencias y ajustes",
      icon: FluentIcons.box_toolbox_20_filled,
      accentColor: const Color(0xFFEA580C),
      permissions: const [Modules.inventory],
      mobileRoute: "inventory",
      submodules: [
        // Sección 1: Existencias y Consultas
        HomeSubmoduleItem(
          section: "Existencias y Consultas",
          title: "Inventario Actual",
          subtitle: "Existencias físicas y costos en tiempo real",
          icon: IconWidgets.currentInventoryIcon.icon!,
          accentColor: const Color(0xFF0D9488),
          routeName: "current-inventory",
        ),
        HomeSubmoduleItem(
          section: "Existencias y Consultas",
          title: "Consulta Rápida de Producto",
          subtitle: "Buscar precio y stock en pantalla",
          icon: Icons.info_outline,
          accentColor: const Color(0xFF2563EB),
          customAction: (ctx) => showProductInfoSearchDelegate(ctx),
        ),
        const HomeSubmoduleItem(
          section: "Existencias y Consultas",
          title: "Existencias Globales",
          subtitle: "Consultar inventario en todas las sucursales",
          icon: Icons.search,
          accentColor: Color(0xFF9333EA),
          routeName: "global-stock-search",
        ),
        const HomeSubmoduleItem(
          section: "Existencias y Consultas",
          title: "Movimientos de un Producto",
          subtitle: "Kárdex detallado de entradas y salidas",
          icon: Icons.sync,
          accentColor: Color(0xFF0D9488),
          routeName: "product-movements",
        ),
        const HomeSubmoduleItem(
          section: "Existencias y Consultas",
          title: "Historial de Entradas por Producto",
          subtitle: "Registro de recepciones por artículo",
          icon: Icons.call_received,
          accentColor: Color(0xFFEA580C),
          routeName: "product-entry-history",
        ),
        const HomeSubmoduleItem(
          section: "Existencias y Consultas",
          title: "Catálogo de Precios",
          subtitle: "Listas de precios vigentes de la sucursal",
          icon: Icons.monetization_on,
          accentColor: Color(0xFF16A34A),
          routeName: "product-price-catalog",
        ),
        const HomeSubmoduleItem(
          section: "Existencias y Consultas",
          title: "Bitácora de Vencimientos",
          subtitle: "Control de caducidades y lotes",
          icon: Icons.timer_sharp,
          accentColor: Color(0xFFD97706),
          routeName: "expiration-logs",
          isExpirationGate: true,
        ),

        // Sección 2: Entradas y Salidas Regulares
        HomeSubmoduleItem(
          section: "Entradas y Salidas de Mercancía",
          title: "Entrada de Inventario",
          subtitle: "Ingreso regular con afectación de kárdex",
          icon: IconWidgets.entryInventoryIcon.icon!,
          accentColor: const Color(0xFF2563EB),
          routeName: "inventory-entry",
        ),
        HomeSubmoduleItem(
          section: "Entradas y Salidas de Mercancía",
          title: "Salida de Inventario",
          subtitle: "Descarga regular con afectación de kárdex",
          icon: IconWidgets.exitInventoryIcon.icon!,
          accentColor: const Color(0xFFE11D48),
          routeName: "inventory-exit",
        ),
        const HomeSubmoduleItem(
          section: "Entradas y Salidas de Mercancía",
          title: "Historial de Entradas",
          subtitle: "Comprobantes de ingresos efectuados",
          icon: FluentIcons.history_28_filled,
          accentColor: Color(0xFF2563EB),
          routeName: "history-entry",
        ),
        const HomeSubmoduleItem(
          section: "Entradas y Salidas de Mercancía",
          title: "Historial de Salidas",
          subtitle: "Comprobantes de salidas efectuadas",
          icon: FluentIcons.history_28_filled,
          accentColor: Color(0xFFE11D48),
          routeName: "history-exit",
        ),

        // Sección 3: Transferencias entre Sucursales
        const HomeSubmoduleItem(
          section: "Transferencias entre Sucursales",
          title: "Transferencias",
          subtitle: "Traslados entre sucursales en curso",
          icon: Icons.swap_vertical_circle_outlined,
          accentColor: Color(0xFF0D9488),
          routeName: "current-tranfers",
        ),
        const HomeSubmoduleItem(
          section: "Transferencias entre Sucursales",
          title: "Crear Transferencia",
          subtitle: "Despacho de mercancía hacia otra sede",
          icon: Icons.swap_vert_circle_outlined,
          accentColor: Color(0xFFE11D48),
          routeName: "create-transfer",
        ),

        // Sección 4: Ajustes y Mermas
        HomeSubmoduleItem(
          section: "Ajustes y Mermas",
          title: "Entrada por Ajuste",
          subtitle: "Ajuste manual positivo por descuadre",
          icon: IconWidgets.entryInventoryIcon.icon!,
          accentColor: const Color(0xFF2563EB),
          routeName: "adjust-entry",
        ),
        const HomeSubmoduleItem(
          section: "Ajustes y Mermas",
          title: "Historial de Entradas por Ajuste",
          subtitle: "Registro de ajustes positivos auditados",
          icon: FluentIcons.history_28_filled,
          accentColor: Color(0xFF2563EB),
          routeName: "history-adjust-entry",
        ),
        HomeSubmoduleItem(
          section: "Ajustes y Mermas",
          title: "Salida por Ajuste",
          subtitle: "Ajuste manual negativo por descuadre",
          icon: IconWidgets.exitInventoryIcon.icon!,
          accentColor: const Color(0xFFE11D48),
          customAction: (ctx) => Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (ctx) => const AdjustExitScreen(
                type: AdjustExitType.adjust,
              ),
            ),
          ),
        ),
        const HomeSubmoduleItem(
          section: "Ajustes y Mermas",
          title: "Historial de Salidas por Ajuste",
          subtitle: "Registro de ajustes negativos auditados",
          icon: FluentIcons.history_28_filled,
          accentColor: Color(0xFFE11D48),
          routeName: "history-adjust-exit",
        ),
        HomeSubmoduleItem(
          section: "Ajustes y Mermas",
          title: "Mermas",
          subtitle: "Baja de inventario por avería o daño",
          icon: IconWidgets.exitInventoryIcon.icon!,
          accentColor: const Color(0xFFDC2626),
          customAction: (ctx) => Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (ctx) => const AdjustExitScreen(
                type: AdjustExitType.loss,
              ),
            ),
          ),
        ),
      ],
    ),
    const HomeModuleCategory(
      id: HomeModuleId.expenses,
      title: "Gastos",
      subtitle: "Gastos operativos, compras a proveedores y reportes",
      icon: FluentIcons.money_24_regular,
      accentColor: Color(0xFFE11D48),
      permissions: [Modules.expenses],
      mobileRoute: "expenses",
      submodules: [
        HomeSubmoduleItem(
          title: "Gastos Operativos",
          subtitle: "Servicios, arriendo, planilla y compras menores",
          icon: Icons.monetization_on,
          accentColor: Color(0xFF16A34A),
          routeName: "operative-expenses",
        ),
        HomeSubmoduleItem(
          title: "Compras a Proveedores",
          subtitle: "Facturas de compras comerciales ingresadas",
          icon: Icons.shopping_cart,
          accentColor: Color(0xFFEA580C),
          routeName: "supplier-expenses",
        ),
        HomeSubmoduleItem(
          title: "Categorías de Gastos",
          subtitle: "Clasificación por centros de costos",
          icon: Icons.category,
          accentColor: Color(0xFF4F46E5),
          routeName: "expense-categories",
        ),
        HomeSubmoduleItem(
          title: "Reporte de Gastos",
          subtitle: "Consolidado y comparativas mensuales",
          icon: Icons.assessment,
          accentColor: Color(0xFF2563EB),
          routeName: "expenses-report",
        ),
      ],
    ),
    const HomeModuleCategory(
      id: HomeModuleId.finance,
      title: "Finanzas",
      subtitle: "Flujo de caja, resúmenes ejecutivos y balances",
      icon: FluentIcons.arrow_trending_lines_24_regular,
      accentColor: Color(0xFF4F46E5),
      permissions: [Modules.finance],
      mobileRoute: "finances",
      submodules: [
        HomeSubmoduleItem(
          title: "Resultado de Operaciones Diarias",
          subtitle: "Balance de ingresos y egresos diarios",
          icon: Icons.analytics_outlined,
          accentColor: Color(0xFFEA580C),
          routeName: "daily-operations-results",
        ),
        HomeSubmoduleItem(
          title: "Reporte de Ventas y Flujos",
          subtitle: "Ingresos y egresos en rango de fechas",
          icon: Icons.date_range_outlined,
          accentColor: Color(0xFF0D9488),
          routeName: "finance-range-report",
        ),
        HomeSubmoduleItem(
          title: "Estado de Cuenta de Clientes",
          subtitle: "Extractos detallados y movimientos por cliente",
          icon: FluentIcons.notepad_person_24_filled,
          accentColor: Color(0xFF2563EB),
          routeName: "client-accounts",
        ),
        HomeSubmoduleItem(
          title: "Historial Detallado de Facturas",
          subtitle: "Auditoría integral con condición y pagos",
          icon: Icons.content_paste_search_rounded,
          accentColor: Color(0xFF16A34A),
          routeName: "detail-invoice-history",
        ),
        HomeSubmoduleItem(
          title: "Facturas Liquidadas",
          subtitle: "Ventas saldadas en su totalidad",
          icon: FluentIcons.receipt_money_24_filled,
          accentColor: Color(0xFF059669),
          routeName: "paid-invoices",
        ),
        HomeSubmoduleItem(
          title: "Resumen Diario",
          subtitle: "Cierre de caja y métricas clave del día",
          icon: Icons.bar_chart_rounded,
          accentColor: Color(0xFF3B82F6),
          routeName: "branch-daily-summary",
        ),
        HomeSubmoduleItem(
          title: "Resumen Ejecutivo",
          subtitle: "Visión panorámica financiera del negocio",
          icon: Icons.pie_chart_rounded,
          accentColor: Color(0xFF9333EA),
          routeName: "branch-executive-summary",
        ),
      ],
    ),
    const HomeModuleCategory(
      id: HomeModuleId.advancedTools,
      title: "Herramientas Avanzadas",
      subtitle: "Estadísticas de rotación y proyección de ventas",
      icon: Icons.schema_rounded,
      accentColor: Color(0xFF9333EA),
      permissions: [Modules.advancedTools],
      mobileRoute: "advanced-tools",
      submodules: [
        HomeSubmoduleItem(
          title: "Estimación por Ventas",
          subtitle: "Cálculo de reposición óptima de inventario",
          icon: Icons.calculate,
          accentColor: Color(0xFF2563EB),
          routeName: "product-stats",
        ),
        HomeSubmoduleItem(
          title: "Proyección de Ventas",
          subtitle: "Modelos predictivos de demanda mensual",
          icon: Icons.calculate,
          accentColor: Color(0xFF16A34A),
          routeName: "sale-projection",
        ),
      ],
    ),
    HomeModuleCategory(
      id: HomeModuleId.settings,
      title: "Configuraciones",
      subtitle: "Usuarios, sucursales, integraciones e impresoras",
      icon: FluentIcons.settings_20_filled,
      accentColor: const Color(0xFF475569),
      permissions: const [Modules.settings],
      mobileRoute: "settings",
      submodules: [
        const HomeSubmoduleItem(
          title: "Usuarios",
          subtitle: "Cuentas de usuario, roles y permisos",
          icon: Icons.person,
          accentColor: Color(0xFF2563EB),
          routeName: "users",
        ),
        const HomeSubmoduleItem(
          title: "Ramas / Sucursales",
          subtitle: "Gestión de sedes, almacenes y parámetros",
          icon: Icons.other_houses,
          accentColor: Color(0xFF0D9488),
          routeName: "branches",
        ),
        const HomeSubmoduleItem(
          title: "Integraciones",
          subtitle: "Servicios periféricos y conexiones",
          icon: Icons.integration_instructions,
          accentColor: Color(0xFF4F46E5),
          routeName: "integrations",
        ),
        const HomeSubmoduleItem(
          title: "Llaves de API (Neptuno)",
          subtitle: "Credenciales de comunicación y sincronización",
          icon: Icons.key,
          accentColor: Color(0xFFD97706),
          routeName: RouteNames.apiKeys,
        ),
        HomeSubmoduleItem(
          title: "Impresora Local",
          subtitle: "Configuración de tickets e impresión térmica",
          icon: Icons.print,
          accentColor: const Color(0xFF475569),
          customAction: (ctx) => showLocalPrinterSettingsDialog(ctx),
        ),
      ],
    ),
  ];

  return categories;
}
