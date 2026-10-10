# Comparativa Técnica y de Navegación: Rama `lite` vs. `main`

Este documento detalla las diferencias arquitectónicas, funcionales y de módulos existentes entre la versión estándar de producción (`main`) y la versión ligera (`lite`) de **Kardex App Front** (**Neptuno App**).

---

## 1. Propósito y Filosofía de la Rama `lite`

La rama `lite` está diseñada como una versión simplificada y enfocada en operaciones directas del punto de venta y almacén básico:
- **Reducción de complejidad operativa:** Se eliminan herramientas analíticas o predictivas que no aplican a negocios pequeños o terminales secundarias.
- **Flujos unificados:** Se agrupan módulos relacionados (por ejemplo, el catálogo de productos se consolida dentro de inventario en lugar de existir como un menú raíz independiente).
- **Control de inventario esencial:** Se mantiene el catálogo y el kárdex directo sin habilitar módulos de ajustes manuales por merma o auditorías complejas de kárdex físico por movimiento que requieren parametrización avanzada.

---

## 2. Sistema de Navegación Unificado

Ambas ramas comparten ahora el mismo paradigma responsivo moderno:

### Desktop (Pantallas ≥ 840 dp) - Split Hub
- **Sidebar Izquierdo (`DesktopModuleSidebar`):** Ancho fijo de 280 dp con información de la sucursal activa, indicador online, lista de módulos con icono temático, título y conteo de opciones.
- **Panel Central / Derecho (`DesktopSubmenuPanel`):** Ancho ergonómico (~960 dp), encabezado con icono destacado y descripción, buscador reactivo en tiempo real y opciones organizadas en tarjetas estilizadas (`DesktopSubmenuCard`) agrupadas por secciones mediante `MenuSectionDivider`.

### Móvil (Pantallas < 600 dp) - Drill-Down con Tarjetas
- **`MenuOptionCard`:** Sustituto universal de `ListTile`. Ofrece contenedor redondeado (14 dp), icono tintado al 10% del color temático, jerarquía tipográfica (título en negrita y subtítulo conciso) y chevron indicador.
- **`MenuSectionDivider`:** Divisores temáticos con título sutil en mayúsculas y línea horizontal tenue.

---

## 3. Matriz Comparativa de Módulos (Nivel Superior / Home)

| Módulo | En rama `main` | En rama `lite` | Justificación |
|---|:---:|:---:|---|
| **Clientes** (`Modules.clients`) | ✅ Activo | ✅ Activo | Idéntico. Directorio, saldos iniciales, búsqueda por cédula, mapas, grupos y exportación PDF. |
| **Proveedores** (`Modules.suppliers`) | ✅ Activo | ✅ Activo | Idéntico. Directorio y compras. |
| **Catálogo de Productos** (`Modules.products`) | ✅ Módulo Raíz | 🔄 Integrado en Inventario | En `lite` se eliminó del menú principal para evitar redundancia y se integró como la primera sección de Inventario. |
| **Comercio** (`Modules.commercial`) | ✅ Activo (si `isCommerce`) | ✅ Activo (si `isCommerce`) | Casi idéntico, con 1 opción omitida en `lite` (*Movimientos de un Producto*). |
| **Cuentas por Cobrar** (`Modules.pendingInvoices`) | ✅ Activo (si `isCommerce`) | ✅ Activo (si `isCommerce`) | Idéntico. Facturas por cobrar, transacciones pendientes, días de impago y abonos. |
| **Inventario** (`Modules.inventory`) | ✅ Activo (5 secciones) | ✅ Activo (4 secciones) | Profundamente adaptado: integra el catálogo maestro y elimina ajustes/mermas. |
| **Gastos** (`Modules.expenses`) | ✅ Activo | ✅ Activo | Idéntico. Gastos operativos, compras a proveedores, categorías y reporte. |
| **Finanzas** (`Modules.finance`) | ✅ Activo | ✅ Activo | Idéntico. Operaciones diarias, flujos, extracto de clientes, historial, liquidadas y resúmenes. |
| **Herramientas Avanzadas** (`Modules.advancedTools`) | ✅ Activo | ❌ Deshabilitado | Excluido por completo en `lite` (estimación por ventas y proyección). |
| **Configuraciones** (`Modules.settings`) | ✅ Activo | ✅ Activo | Mismas opciones (usuarios, sucursales, integraciones, llaves API, impresora). |

---

## 4. Desglose Detallado de Diferencias por Módulo

### 4.1. Módulo de Inventario (`Modules.inventory`)

En `main`, Inventario se divide en:
1. *Existencias y Consultas* (incluye `product-movements`, `product-entry-history`, `product-price-catalog`, `expiration-logs`).
2. *Entradas y Salidas de Mercancía* (`inventory-entry`, `inventory-exit`, `history-entry`, `history-exit`).
3. *Transferencias entre Sucursales* (`current-tranfers`, `create-transfer`).
4. *Ajustes y Mermas* (`adjust-entry`, `history-adjust-entry`, salidas por ajuste, `history-adjust-exit`, `mermas`).

En `lite`, la estructura adaptada es:
1. **Sección 1: Catálogo de Productos:**
   - *Lista Global de Productos* (`product-list`)
   - *Unidades de Medida* (`units`)
   - *Categorías de Productos* (`product-category`)
2. **Sección 2: Existencias y Consultas:**
   - *Inventario Actual* (`current-inventory`)
   - *Consulta Rápida de Producto* (modal interactivo)
   - *Consulta de Existencias Globales* (`global-stock-search`)
   - *Catálogo de Inventario* (`product-inventory-catalog` en vez de `product-price-catalog`)
   - *Bitácora de Vencimientos* (`expiration-logs`)
   - ❌ *Movimientos de un Producto* (`product-movements`): deshabilitado en `lite`.
3. **Sección 3: Entradas y Salidas de Mercancía:**
   - *Entrada de Inventario* (`inventory-entry`)
   - *Historial de Entradas* (`history-entry`)
   - *Historial de Entradas por Producto* (`product-entry-history`)
   - *Salida de Inventario* (`inventory-exit`)
   - *Historial de Salidas* (`history-exit`)
4. **Sección 4: Transferencias entre Sucursales:**
   - *Transferencias* (`current-tranfers`)
   - *Crear Transferencia* (`create-transfer`)
5. ❌ **Sección 5: Ajustes y Mermas:**
   - No disponible en `lite`. Las rutas de ajuste (`adjust-entry`, `history-adjust-entry`, `history-adjust-exit`) no están registradas en el enrutador de `lite`.

### 4.2. Módulo de Comercio (`Modules.commercial`)

- En `main`: Dispone de 28 opciones entre ventas, POS, arqueos, proformas, órdenes y devoluciones.
- En `lite`: Dispone de 27 opciones; se deshabilitó la opción:
  - ❌ *Movimientos de un Producto* (`commercial-product-movements` / `commercialProductMovements`).

### 4.3. Herramientas Avanzadas (`Modules.advancedTools`)

- En `main`: Incluye *Estimación por Ventas* (`product-stats`) y *Proyección de Ventas* (`sale-projection`).
- En `lite`: Módulo y rutas totalmente ausentes del router y de la interfaz.

### 4.4. Configuraciones (`Modules.settings`)

- En `main`: El router incluye la ruta interna `product-price` (`PriceToProductScreen`).
- En `lite`: Dicha ruta está comentada en el router. La configuración expuesta al usuario es idéntica (Usuarios, Ramas, Integraciones, Llaves API, Impresora Local).

---

## 5. Diferencias en Rutas y Registro de Accesos Directos

### En `lib/constants/route_names.dart`
- `lite` contiene:
  ```dart
  static const productInventoryCatalog = 'product-inventory-catalog';
  ```
- `main` utiliza `productPriceCatalog` (`product-price-catalog`).

### En `lib/constants/shortcut_registry.dart`
- `lite` registra:
  ```dart
  RouteNames.productInventoryCatalog: const ShortcutInfo(
    title: "Catálogo de Inventario",
    icon: Icons.inventory,
    color: Color(0xFF4CAF50),
  ),
  ```

### En `lib/config/app_router.dart`
- En `lite`:
  - `product-inventory-catalog` mapea a `ProductInventoryCatalogScreen()`.
  - Las rutas de `/advanced-tools`, `adjust-entry`, `history-adjust-entry`, `history-adjust-exit`, `product-price-setting` y `product-price` están explícitamente comentadas.
