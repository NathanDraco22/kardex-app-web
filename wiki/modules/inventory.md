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
├── adjustment_request/                  # Solicitudes de ajuste con flujo de aprobación
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

### 2.4.1. Solicitudes de Ajuste (`adjustment_request`) — ⭐ Módulo Canónico de Referencia de Diseño y UX

> [!TIP]
> **Módulo de Ejemplo Canónico del Sistema:**
> Este módulo es la implementación de referencia recomendada para todo nuevo desarrollo o refactorización en `kardex_app_front`. Contiene la arquitectura modelo en Flutter (Cubit reactivo con stream del repositorio, separación Web/Mobile limpia), soporte integral de teclado para laptops sin numpad, y la aplicación perfecta de la identidad visual de la app: fondo índigo suave, cabecera de 2 tarjetas Bento, contenedor continuo de tarjetas sin márgenes flotantes, pastillas informativas `_InfoPill` y pie de tabla integrado.

- **Propósito:** Registrar un conteo físico y someterlo a aprobación antes de afectar existencias.
- **Flujo:**
  1. El usuario crea una solicitud **Pendiente** con los productos, la existencia del sistema, el conteo real, la diferencia y el costo.
  2. Un **Supervisor o Admin** la **Aprueba**; el servidor aplica la diferencia original guardada. Los Operadores no pueden aprobar.
  3. Si hay sobrantes y faltantes en la misma solicitud, se generan **dos documentos**: un Ajuste de Entrada y un Ajuste de Salida, dentro de la misma transacción Mongo.
  4. Si se **Cancela**, no se toca el inventario.
- **Reglas:**
  - Solo los roles `Supervisor` y `Admin` pueden aprobar solicitudes de ajuste.
  - Un Supervisor no puede aprobar su propia solicitud. Un Admin sí puede aprobar la suya.
  - Las solicitudes creadas por un Admin también quedan en estado pendiente y requieren una aprobación explícita.
  - Solo las solicitudes pendientes se pueden editar, cancelar o eliminar lógicamente.
  - El backend vuelve a tomar la foto real del `ProductAccount` al crear/editar; no confía en la existencia enviada por el cliente.
  - La aprobación aplica la diferencia registrada, aunque el stock actual haya cambiado. Si una salida ya no tiene stock suficiente, el servidor rechaza la aprobación.
- **Arquitectura de Vistas (Modelo a Seguir):**
  - **Imágenes de producto:** las filas/tarjetas de producto del formulario y del detalle muestran la miniatura del artículo (`ImageViewerWidget`, 40–46 px) con icono de respaldo cuando no existe imagen. El backend guarda la URL de imagen como snapshot en cada `AdjustmentRequestItem` al crear o editar la solicitud; las solicitudes históricas sin el campo muestran el icono.
  - **1. Formulario de Creación / Edición (`AdjustmentRequestFormScreen`):**
    - **Web (`AdjustmentRequestFormWebScreen`):** Envuelto en `ShortcutContainer` para capturar atajos (`Ctrl+G` para guardar, `Ctrl+1` para agregar producto). Cabecera estandarizada de 2 tarjetas Bento (380px fija + flexible). Tabla de productos con filas de 75px, alternancia de colores (`RowColorTool`), navegación rápida por teclado con `Enter` (`FocusScope.nextFocus`) optimizada para laptops sin teclado numérico, y `_TableFooter` con totales al pie del `Card`.
    - **Mobile (`AdjustmentRequestFormMobileScreen`):** Tarjetas Bento de entrada de datos, `DateFieldSelector` sincronizado, `FloatingActionButton.extended` protegido contra solapamiento con el teclado virtual, y edición ágil de conteo real.
  - **2. Detalle de la Solicitud (`AdjustmentRequestDetailScreen`):**
    - **Web (`AdjustmentRequestDetailWebScreen`):** Cabecera Bento de 2 tarjetas con metadatos de solo lectura, chip de estado, panel informativo de aprobación/cancelación con acceso directo a los ajustes generados, y tabla de productos de 75px con `_TableFooter` integrado.
    - **Mobile (`AdjustmentRequestDetailMobileScreen`):** Padding perimetral estricto de 4px (`EdgeInsets.all(4.0)`). Metadatos en pastillas Bento `_MobileDetailPill`, contenedor continuo de productos dentro de un único `Card` con `RowColorTool`, divisores sutiles y pastillas Bento compactas `_InfoPill` (Existencia, Costo, Conteo real, Diferencia coloreada con icono y Subtotal). Totales consolidados siempre fijos en la base mediante `BottomAppBar(height: 60)` con `TitleLabel` (Sobrante verde, Faltante rojo, Total Neto bold). Botones de acción envueltos en tarjeta Bento contenedora (`_MobileActionsCard`).
  - **3. Listado de Solicitudes (`AdjustmentRequestListScreen`):**
    - **Web (`AdjustmentRequestListWebScreen`):** Cabecera de filtros compacta y tabla de solicitudes con alternancia de colores, badges de estado y `_TableFooter` integrado directamente al pie del `Card` de la tabla (sin barra flotante exterior).
    - **Mobile (`AdjustmentRequestListMobileScreen`):** Padding perimetral de 4px (`EdgeInsets.all(4.0)`). Agrupación continua de todas las solicitudes dentro de un único `Card(margin: EdgeInsets.zero, clipBehavior: Clip.antiAlias)` con `Divider` entre filas, tarjetas Bento compactas con pastillas `_ListInfoPill` (Sobrante verde, Faltante rojo, Total Neto bold) y barra inferior fija `BottomAppBar(height: 60)` con `TitleLabel` para Sobrante, Faltante y Total Neto (estándar del Buscador de Cotizaciones).
- **Cubits:** `ReadAdjustmentRequestsCubit`, `WriteAdjustmentRequestCubit`, `ReadAdjustmentRequestDetailCubit`.
- **Repositorio:** `AdjustmentRequestsRepository` (reactivo: notifica altas/cambios/bajas al `ReadCubit`).

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
| Solicitudes de Ajuste | `AdjustmentRequestsDataSource` | `AdjustmentRequestsRepository` |
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
- `/inventory/adjustment-requests`: Lista de solicitudes de ajuste.
- `/inventory/adjustment-requests/create`: Nueva solicitud de ajuste.
- `/inventory/adjustment-requests/:requestId`: Detalle de la solicitud.
- `/inventory/adjustment-requests/:requestId/edit`: Edición de una solicitud pendiente.
- `/inventory/history-entry` & `/inventory/history-exit`: Historiales de movimientos.
