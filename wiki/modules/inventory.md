# Documentación del Módulo: Inventario (`inventory`)

El módulo **Inventario** gestiona el control de existencias, valuación de costos, movimientos entre sucursales y ajustes en `kardex_app_front`. Es uno de los módulos más robustos, integrando soporte para doble flujo: movimientos formales con Kárdex ponderado y movimientos directos sin kárdex.

---

## 1. Arquitectura y Submódulos

Ubicación: `lib/src/modules/inventory/`:

```text
lib/src/modules/inventory/
├── inventory_menu_screen.dart           # Menú principal de almacén/inventario
├── current_inventory/                   # Catálogo de stock y existencia en tiempo real
├── inventory_entry/                     # Entrada formal de mercancía por compra o recepción
├── inventory_exit/                      # Salida formal de mercancía por consumo o despacho
├── adjust_entry/ & adjust_exit/         # Ajustes de inventario (sobrantes y faltantes)
├── history_entry/ & history_exit/       # Historial de entradas y salidas registradas
├── create_transfer/                     # Creación y emisión de traslados entre sucursales
├── current_tranfers/                    # Recepción y confirmación de traslados en tránsito
├── expiration_logs/                     # Bitácora y seguimiento de fechas de vencimiento
├── product_movements/                   # Trazabilidad completa de movimientos por producto
├── product_entry_history/               # Auditoría histórica de compras por ítem
└── product_price_catalog/               # Consulta y sincronización de precios e inventario
```

---

## 2. Detalle de Submódulos Clave

### 2.1. Inventario Actual (`current_inventory`)
- **Propósito:** Visualización de stock de cada producto en la sucursal activa (`currentStock`, `promiseStock` comprometido en pedidos, y stock disponible real).
- **Vistas:**
  - `CurrentInventoryScreen`: Adaptable a Web y Móvil.
  - Integra tabla de alta densidad con filtros por categoría, búsqueda por nombre, código y código alternativo (`altCode`).
- **Cubits:** `CurrentInventoryCubit`, `ReadProductInBranchCubit`.
- **Editor de Inventario:** Permite abrir el diálogo `showProductInventoryEditor` para ajustar parámetros de inventario por sucursal, cambiar umbrales de reabastecimiento o abrir el editor completo de producto.

### 2.2. Entradas de Inventario (`inventory_entry` & `history_entry`)
- **Propósito:** Registro de documentos de entrada provenientes de proveedores o producción.
- **Vistas:** `InventoryEntryScreen`, `InventoryEntryMobileScreen`, `HistoryEntryScreen`.
- **Cubits:**
  - `WriteEntryDocCubit`: Gestiona la construcción del documento de entrada, proveedor asociado, costos unitarios, impuestos y cantidades.
  - **Doble Flujo (Kárdex vs Directo):** Dispone de la propiedad reactiva `useKardex`.
    - `createNewEntryDoc`: Flujo contable que recalcula costos promedio ponderados y genera registros en el libro kárdex.
    - `createNewEntryDocDirect`: Flujo ultrarrápido sin kárdex que incrementa el stock atómicamente y actualiza `averageCost` y `lastCost` sin generar transacciones contables complejas.
- **Historial:** `HistoryEntryScreen` permite filtrar por rango de fechas, proveedor, número de documento y reimprimir el comprobante.

### 2.3. Salidas de Inventario (`inventory_exit` & `history_exit`)
- **Propósito:** Registro de mermas, consumos internos, donaciones o salidas no comerciales.
- **Vistas:** `InventoryExitScreen`, `HistoryExitScreen`.
- **Cubits:**
  - `WriteExitDocCubit`: Gestiona los ítems de salida. Soporta `useKardex`:
    - `createNewExitDoc`: Salida formal con costo ponderado y registro kárdex.
    - `createNewExitDocDirect`: Salida rápida atómica validando disponibilidad (`currentStock - promiseStock >= 0`).

### 2.4. Ajustes de Entrada y Salida (`adjust_entry` & `adjust_exit`)
- **Propósito:** Regularización de discrepancias físicas identificadas durante conteos cíclicos o inventarios generales.
- **Vistas:** `AdjustEntryScreen`, `AdjustExitScreen`, junto con sus historiales `AdjustEntryHistoryScreen` y `AdjustExitHistoryScreen`.
- **Cubits:** `AdjustEntryCubit`, `AdjustExitCubit`.
- **Regla de Negocio:** Permite especificar motivo del ajuste (auditoría, rotura, merma, corrección de sistema) y actualiza el saldo contable.

### 2.5. Transferencias entre Sucursales (`create_transfer` & `current_tranfers`)
- **Propósito:** Despacho y recepción controlada de mercadería entre distintas bodegas o puntos de venta.
- **Vistas:**
  - `CreateTransferScreen`: Selección de sucursal destino, productos y cantidades.
  - `CurrentTranfersScreen` & `TransferDetailScreen`: Supervisión de traslados en estado `pending`, `accepted` o `rejected`.
- **Gestión Offline/Borradores:**
  - Utiliza `TransferDraftManager` para guardar estados intermedios antes de enviar la transferencia al servidor.

### 2.6. Bitácora de Vencimientos (`expiration_logs`)
- **Propósito:** Supervisión de lotes próximos a caducar para prevenir pérdidas operativas.
- **Vistas:** `ExpirationLogsScreen`.
- **Cubits:** `ExpirationLogsCubit`.

---

## 3. Repositorios y Fuentes de Datos Involucrados

| Submódulo | DataSource | Repositorio |
| :--- | :--- | :--- |
| Cuentas de Producto | `ProductAccountsDataSource` | `ProductAccountsRepository` |
| Entradas | `EntryDocsDataSource` | `EntryDocsRepository` |
| Salidas | `ExitDocsDataSource` | `ExitDocsRepository` |
| Transferencias | `TransfersDataSource` | `TransfersRepository` |
| Ajustes | `AdjustDocsDataSource` | `AdjustDocsRepository` |
| Lotes / Vencimientos | `ExpirationLogsDataSource` | `ExpirationLogsRepository` |

---

## 4. Rutas en `app_router.dart`

- `/inventory`: Menú principal de inventario.
- `/inventory/current`: Inventario actual y existencias.
- `/inventory/entry`: Registro de entradas.
- `/inventory/exit`: Registro de salidas.
- `/inventory/create-transfer`: Crear transferencia entre sucursales.
- `/inventory/current-transfers`: Consultar transferencias activas.
- `/inventory/expiration-logs`: Bitácora de fechas de caducidad.
- `/inventory/adjust-entry` & `/inventory/adjust-exit`: Ajustes de inventario.
- `/inventory/history-entry` & `/inventory/history-exit`: Historiales de movimientos.
