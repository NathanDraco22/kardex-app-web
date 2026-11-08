# Documentación del Módulo: Comercial (`commercial`)

El módulo **Comercial** es el núcleo transaccional de ventas y atención al cliente de `kardex_app_front`. Controla el flujo completo desde la captura ágil de ventas en el terminal POS hasta la emisión de facturas electrónicas/contables, cotizaciones, recibos de caja, devoluciones y estadísticas de desempeño por usuario.

---

## 1. Arquitectura y Submódulos

El módulo se encuentra ubicado en `lib/src/modules/commercial/` y se compone de los siguientes submódulos funcionales:

```text
lib/src/modules/commercial/
├── commercial_menu_screen.dart          # Menú principal del área comercial
├── sale_terminal/                       # Terminal POS para ventas rápidas
├── client_invoices/                     # Facturación directa a clientes
├── anon_invoices/                       # Facturación rápida a clientes anónimos
├── current_orders/                      # Gestión de órdenes y pedidos en curso
├── current_proforma/ & proforma/        # Elaboración y consulta de cotizaciones/proformas
├── quotation_order_search/              # Búsqueda y conversión de cotizaciones a facturas
├── daily_client_invoices/               # Facturas de clientes del día
├── daily_anon_invoinces/                # Facturas anónimas del día
├── daily_receipt/ & receipt_history/    # Recibos diarios e historial global de recibos
├── invoice_history/                     # Historial maestro de facturas emitidas
├── invoice_by_product/                  # Auditoría de ventas por producto
├── devolutions/ & client_devolution/    # Creación y emisión de notas de devolución
├── current_devolutions/ & devolution_history/ # Historial y estado de devoluciones
├── credit_notes/                        # Gestión y emisión reactiva de notas de crédito
├── daily_product_sales/                 # Reporte diario de ventas agrupadas por producto
├── daily_product_in_orders/             # Productos comprometidos en pedidos
├── pending_invoice/                     # Facturas con saldo pendiente de cobro
├── product_demand_vs_stock/             # Comparador de demanda proyectada vs existencia física
├── product_movements/                   # Movimientos comerciales de productos
├── product_price_setting/               # Configurador dinámico de precios de venta
└── user_operations_results/             # Cierre y arqueo de operaciones por vendedor/cajero
```

---

## 2. Detalle de Submódulos Clave

### 2.1. Terminal de Ventas (`sale_terminal`)
- **Propósito:** Proporciona un punto de venta (POS) optimizado para rapidez con soporte de teclado, lector de código de barras y diseño responsivo para Desktop, Tablet y Móvil.
- **Vistas:**
  - `SaleTerminalScreen`: Contenedor principal que selecciona la vista según el dispositivo.
  - `SaleTerminalWebScreen`, `SaleTerminalTabletScreen`, `SaleTerminalMobileScreen`.
- **Gestores de Estado (Cubits):**
  - `SaleTerminalCubit` / `SaleTerminalState`: Mantiene la lista de productos agregados, cantidades, descuentos por línea, tipo de pago (efectivo, tarjeta, transferencia, crédito) y cálculo en tiempo real de subtotales, IVA y total.
- **Soporte de Borradores en Espera (Hold Sales):**
  - Utiliza `SaleTerminalDraftManager` coordinado con `HoldSalesRepository` en el backend para guardar temporalmente ventas en espera sin reservar stock ni perder la venta actual.
- **Acciones Clave:**
  - Emisión de factura / ticket mediante `InvoiceRepository` y `ReceiptRepository`.
  - Integración con impresión directa mediante `InvoicePrinter` y `ReceiptPrinter`.

### 2.2. Facturación de Clientes y Anónimos (`client_invoices` y `anon_invoices`)
- **Propósito:** Flujos dedicados para registrar ventas nominativas (con cliente registrado, límite de crédito y NIT/RNC) o ventas al consumidor final.
- **Vistas:** `ClientInvoicesScreen`, `AnonInvoicesScreen`.
- **Integraciones:**
  - Validación de stock disponible (`currentStock - promiseStock`).
  - Verificación del estado de crédito del cliente mediante `ClientRepository`.

### 2.3. Cotizaciones y Proformas (`proforma` y `current_proforma`)
- **Propósito:** Permite generar propuestas comerciales y presupuestos sin descontar stock físico del inventario.
- **Vistas:** `ProformaScreen`, `CurrentProformaScreen`.
- **Flujo de Conversión:**
  - Una proforma puede buscarse desde `QuotationOrderSearchScreen` y cargarse directamente en la pantalla de facturación o terminal de ventas para convertirse en venta final.

### 2.4. Devoluciones (`devolutions`, `client_devolution`, `devolution_history`)
- **Propósito:** Registro de notas de crédito y reversión de inventario por productos devueltos por clientes.
- **Vistas:** `DevolutionsScreen`, `ClientDevolutionScreen`, `DevolutionHistoryScreen`, `CurrentDevolutionsScreen`.
- **Cubits:** `DevolutionCubit`, `DevolutionHistoryCubit`.
- **Impacto en Inventario y Finanzas:**
  - Reingresa las unidades correspondientes al stock disponible de la sucursal.
  - Si la factura original fue al contado, genera un egreso o saldo a favor; si fue a crédito, rebaja la cuenta por cobrar.
  - Plantilla de visualización e impresión: `DevolutionViewer` y `SingleDevolutionTemplate`.

### 2.5. Notas de Crédito (`credit_notes`)
- **Propósito:** Evolución moderna de las devoluciones con dos modalidades: retorno de mercancía a inventario físico (`devolution`) o concesión de saldos a favor con motivo obligatorio (`amount`).
- **Arquitectura Reactiva:** Implementa el primer `ReactiveRepository` del frontend, emitiendo notificaciones en vivo hacia `ReadCreditNoteCubit` sin refetch manual.
- **Flujo Completo:** Ver [Documentación Detallada de Notas de Crédito](./credit_notes.md).

### 2.6. Historiales y Auditorías
- **`invoice_history` / `receipt_history`:** Pantallas para consultar, reimprimir o filtrar facturas y recibos con `HistoryParams` (rango de fechas, cliente, sucursal, estado).
- **`invoice_by_product`:** Permite saber con precisión qué facturas incluyeron determinado producto.
- **`user_operations_results`:** Muestra el desglose de ventas, cobros y anulaciones agrupados por usuario para el cierre de turno y arqueo de caja.

---

### 2.6. Facturas por Cobrar y Cobranza Compuesta (`pending_invoice` & Composite API)
- **Propósito:** Permite la gestión y cobro de cuentas pendientes de clientes, integrando automáticamente facturas, devoluciones y notas de crédito disponibles.
- **Optimización de Red (Composite API):**
  - Utiliza `CompositeRepository.getClientPendingInvoices(clientId, branchId)` que consulta el endpoint backend `/api/v1/composite/client-pending-invoices`.
  - Reduce de 3 llamadas HTTP por separado a 1 sola llamada atómica que devuelve facturas, devoluciones, notas de crédito y el `summary` con los balances calculados.
- **Experiencia Visual (Tile de Notas de Crédito Bento UI):**
  - Incorpora `CreditNotesSummaryTile` (`lib/src/modules/commercial/pending_invoice/widget/credit_notes_summary_tile.dart`) que se renderiza justo antes de la lista de facturas pendientes.
  - Presenta un banner interactivo en tonos púrpura con el saldo total a favor del cliente, píldora con el conteo de notas (`AppStatusBadge`), y sección expandible con el desglose individual y botón para abrir el visor `showCreditNoteViewerDialog`.
  - La barra inferior (`_BottomPendingInvoice`) y el modal de abono rápido calculan el balance neto a pagar deduciendo de forma canónica las notas de crédito y devoluciones.

## 3. Repositorios y Fuentes de Datos Involucrados

| Concepto | DataSource (`lib/src/data/`) | Repositorio (`lib/src/domain/repositories/`) |
| :--- | :--- | :--- |
| Facturas | `InvoiceDataSource` | `InvoiceRepository` |
| Recibos | `ReceiptDataSource` | `ReceiptRepository` |
| Devoluciones | `DevolutionDataSource` | `DevolutionRepository` |
| Notas de Crédito | `CreditNotesDataSource` | `CreditNotesRepository (ReactiveRepository)` |
| Composite / Cobranzas | `CompositeDataSource` | `CompositeRepository` |
| Proformas/Pedidos | `ProformaDataSource` | `ProformaRepository` |
| Ventas en Espera | `HoldSalesDataSource` | `HoldSalesRepository` |
| Clientes | `ClientDataSource` | `ClientRepository` |

---

## 4. Rutas en `app_router.dart`

- `/commercial`: Menú principal del módulo comercial (restringido a sucursales donde `isCommerce == true`).
- `/sale-terminal`: Terminal POS.
- `/commercial/client-invoices`: Facturación nominativa.
- `/commercial/anon-invoices`: Facturas a consumidor final.
- `/commercial/invoice-history`: Historial maestro de facturación.
- `/commercial/receipt-history`: Historial de recibos.
- `/commercial/devolutions`: Registro de devoluciones.
- `/commercial/devolution-history`: Historial de devoluciones.
- `/commercial/credit-notes`: Gestión y emisión de notas de crédito (devolución y monto).
- `/commercial/user-operations-results`: Arqueo y resultados por usuario.

---

## 5. Control de Visibilidad y Reglas Globales (`AppSettings` & Gates)

El módulo Comercial interactúa de forma directa y reactiva con la configuración global del sistema (`AppSettingsCubit`) a través de componentes **Gate**:

| Bandera en `AppSettings` | Gate Asociado | Herramientas y Submódulos Afectados | Comportamiento si está Deshabilitado |
| :--- | :--- | :--- | :--- |
| `useOrders` | `OrdersGate` | Órdenes de Compra (`current-orders`), Crear Orden (`sale-order`), Crear Orden Mayorista (`sale-order-wholesale`), Productos en Órdenes (`daily-product-in-orders`). | Oculta automáticamente las tarjetas y opciones en Desktop y Móvil. |
| `useQuotations` | `QuotationsGate` | Historial de Cotizaciones (`proforma-history`), Crear Cotización (`proforma`), Crear Cotización Mayorista (`proforma-wholesale`), Cotizaciones vs Existencias (`product-demand-vs-stock`). | Oculta las opciones y el separador completo de sección de cotizaciones. |
| `useOrders` o `useQuotations` | `QuotationsOrOrdersGate` | Buscador de Cotizaciones / Órdenes (`quotation-order-search`). | Solo se muestra si al menos una de las dos modalidades está activa en la configuración. |
| `useExpirationDates` | `ExpirationDateGate` | Bitácora de Vencimientos (`expiration-logs`), columnas de lotes y fechas de caducidad. | Oculta la herramienta si la sucursal o las configuraciones globales tienen apagado el control de caducidad. |

