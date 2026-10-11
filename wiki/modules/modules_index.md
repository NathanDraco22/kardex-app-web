# Índice de Módulos del Sistema (`wiki/modules/modules_index.md`)

Este documento ofrece un panorama general y conciso de cada uno de los módulos funcionales que componen **Kardex App Front**. Su objetivo es permitir a desarrolladores y agentes de IA comprender a grandes rasgos qué hace cada módulo, su rol en el negocio y acceder directamente a su documentación técnica detallada.

---

## 🧭 Mapa General de Módulos

| Módulo | Carpeta (`lib/src/modules/`) | Rol de Negocio Principal | Documento Detallado |
| :--- | :--- | :--- | :--- |
| **Comercial** | `commercial/` | Terminal POS, facturación (nominativa y final), cotizaciones/proformas, recibos de caja, devoluciones y arqueo por usuario. | [commercial.md](./commercial.md) |
| **Inventario** | `inventory/` | Existencias en tiempo real, entradas/salidas (flujo con y sin kárdex), ajustes, transferencias entre sucursales y bitácora de vencimientos. | [inventory.md](./inventory.md) |
| **Catálogo de Productos** | `product_catalog/` | Catálogo maestro de productos, códigos alternativos (`altCode`), categorías taxonómicas y unidades de medida con factores de conversión. | [product_catalog.md](./product_catalog.md) |
| **Cuentas Pendientes** | `pending_accounts/` | Cuentas por cobrar, cartera de deudores, sesiones de crédito y aplicación de abonos a facturas pendientes. | [pending_accounts.md](./pending_accounts.md) |
| **Finanzas** | `finance/` | Cierre diario y resumen ejecutivo de sucursal, reportes por rangos de fecha, arqueos de operaciones y estados de cuenta de clientes. | [finance.md](./finance.md) |
| **Gastos** | `expenses/` | Registro de gastos operativos de caja/banco, pagos a proveedores, centros de costos/categorías y reportes analíticos de egresos. | [expenses.md](./expenses.md) |
| **Catálogo de Clientes** | `client_catalog/` | Directorio de clientes, límites de crédito, grupos comerciales, balances iniciales históricos y mapa geolocalizado de clientes. | [client_catalog.md](./client_catalog.md) |
| **Catálogo de Proveedores** | `suppliers_catalog/` | Directorio de abastecedores de mercancía, plazos de pago, condiciones crediticias e integración con compras e inventario. | [suppliers_catalog.md](./suppliers_catalog.md) |
| **Configuración** | `settings/` | Administración de sucursales (`isCommerce`), usuarios, roles y permisos, llaves de API, periféricos/impresoras y matriz de precios. | [settings.md](./settings.md) |
| **Navegación y Sesión** | `home/`, `login/`, `splash/`... | Bootstrap inicial, autenticación JWT, menú responsivo comercial vs bodega, conmutador multi-sucursal y atajos de teclado. | [home_and_navigation.md](./home_and_navigation.md) |
| **Herramientas Avanzadas** | `advanced_tools/` | Estadísticas avanzadas de rotación de productos, días de inventario y proyecciones automáticas de demanda para reabastecimiento. | [advanced_tools.md](./advanced_tools.md) |

---

## 🔍 Resumen Rápido por Módulo

### 1. Comercial (`commercial`)
- **Enfoque:** Transacciones de venta rápidas y formales.
- **Puntos Críticos:**
  - El terminal de venta (`sale_terminal`) soporta ventas en espera temporales persistidas en servidor (`HoldSalesRepository`).
  - Las facturas validan stock comprometido (`promiseStock`) y reducen existencias.
  - La visualización e impresión de facturas y tickets utiliza `InvoicePrinter` y `SingleInvoiceTemplate`.

### 2. Inventario (`inventory`)
- **Enfoque:** Trazabilidad física y contable del almacén.
- **Puntos Críticos:**
  - Soporte de doble flujo: movimientos con kárdex formal (`createNewEntryDoc` / `createNewExitDoc`) vs movimientos directos atómicos de alto rendimiento (`createNewEntryDocDirect` / `createNewExitDocDirect`).
  - Transferencias inter-sucursal con soporte de borradores con `TransferDraftManager`.
  - Edición en caliente de parámetros de producto por sucursal desde el diálogo de inventario.

### 3. Catálogo de Productos (`product_catalog`)
- **Enfoque:** Maestro global de artículos.
- **Puntos Críticos:**
  - Soporte de código alternativo (`altCode`) para productos que manejan códigos de fábrica y códigos internos propios.
  - Conversión de unidades con `UnitConversionTool` para despachos por fracciones o paquetes.
  - Reconstrucción reactiva de modelos en sucursal con `product_in_branch_factory.dart`.

### 4. Cuentas Pendientes (`pending_accounts`)
- **Enfoque:** Cobranza y crédito comercial.
- **Puntos Críticos:**
  - Permite cobrar deudas totales o parciales por factura.
  - Emite recibos oficiales de cobro y actualiza en tiempo real el saldo deudor del cliente.

### 5. Finanzas (`finance`)
- **Enfoque:** Analítica, rentabilidad y caja.
- **Puntos Críticos:**
  - Permite conciliar ventas frente a dinero físico contado por cajero (`userId`).
  - Exporta balances en rangos de fecha hacia formatos impresos o digitales.

### 6. Gastos (`expenses`)
- **Enfoque:** Control de egresos no relacionados a compra directa de inventario.
- **Puntos Críticos:**
  - Clasificación por categorías contables para monitorear el gasto operativo de cada sucursal.

### 7. Clientes y Proveedores (`client_catalog` & `suppliers_catalog`)
- **Enfoque:** Directorios de contrapartes comerciales.
- **Puntos Críticos:**
  - Los clientes cuentan con límites de crédito estrictos que frenan la facturación si la deuda supera el tope autorizado.
  - Los proveedores se asocian de forma natural con los comprobantes de compra y gastos.

### 8. Configuración (`settings`)
- **Enfoque:** Parametrización y control de acceso.
- **Puntos Críticos:**
  - La bandera `isCommerce` en sucursales determina si el sistema habilita módulos de venta o si se comporta puramente como centro logístico/bodega.
  - El submódulo `app_settings` centraliza reglas y banderas globales (margen de ganancia sugerido, fechas de vencimiento, órdenes, cotizaciones, inventario negativo y días de crédito).
  - Control de accesos mediante `RolePermissionGate`.

### 9. Navegación, Sesión y Atajos (`home_and_navigation`)
- **Enfoque:** Experiencia de usuario y agilidad operativa.
- **Puntos Críticos:**
  - Soporta atajos de teclado globales como `Ctrl + Space` para la calculadora y `F1` para búsqueda global de existencias.
