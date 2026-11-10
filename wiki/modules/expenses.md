# Documentación del Módulo: Gastos (`expenses`)

> **Estado:** rediseño completo del módulo (Fases 1–3) sobre la rama `feat/expenses-redesign`.
>
> **Commits:** `32d93f6c` (base compartida y listas), `c4ddfad9` (reporte y categorías), `9c340903` (formularios, visores y hub).
>
> **Verificación de la rama:** `flutter analyze` sin issues, `flutter test` con **199 tests passed**, `dart analyze packages/kardex_business` sin issues y **96 tests específicos de Gastos**.

El módulo **Gastos** administra el registro, la clasificación y el análisis de las salidas de dinero que no corresponden a la compra directa de inventario. Cubre gastos operativos de caja o banco, gastos asociados a proveedores y, a nivel de lectura/reportes, gastos de tipo impuesto. También concentra las categorías de gasto, el visor de solo lectura y el reporte por período.

---

## 1. Visión general y alcance

- **Operación diaria:** alta, edición, pago y eliminación de gastos operativos y de proveedores.
- **Clasificación:** catálogo de categorías reutilizables para los gastos operativos.
- **Análisis:** reporte por período con KPIs, detalle paginado, consolidado por categoría/proveedor y exportación CSV/PDF.
- **Consulta:** visor compartido de solo lectura con la ficha completa del gasto.
- **Alcance por sucursal:** las listas y el reporte consultan la sucursal activa de la sesión (`AuthCubit.currentBranchId`). Las categorías son un catálogo global del endpoint, no por sucursal.
- **Acceso:** el hub se habilita desde Inicio con el permiso `Modules.expenses`; las rutas hijas no agregan una guarda de rol propia.
- **Tipos de gasto:** `operative`, `supplier` y `tax`. La UI de esta fase crea y edita los dos primeros; `tax` se contempla en el visor y en los reportes si existen registros de impuestos creados por otra vía.

El módulo **no** reemplaza la compra de inventario ni el kárdex. Los pagos a proveedores registrados aquí son egresos administrativos/financieros, no documentos de entrada de mercancía.

---

## 2. Cambios del rediseño

| Fase | Commit | Cambios principales |
| :--- | :--- | :--- |
| **1. Base y listas** | `32d93f6c` | Nueva capa `shared/`: configuración de lista, orquestador responsive, métricas, badges, acciones, filtros, KPIs y tabla/tarjetas. Se retiraron las vistas Web/Móvil duplicadas de gastos operativos y de proveedores. |
| **2. Reporte y categorías** | `c4ddfad9` | Nuevo reporte con presets de período, KPIs, detalle local, consolidado con dona/ranking y exportación. Catálogo de categorías con grid responsive, búsqueda y diálogo moderno. CSV/PDF alineados a `createdAt`. |
| **3. Formularios, visores y hub** | `9c340903` | Formularios adaptativos (diálogo desktop / pantalla completa móvil), parser robusto de montos, preservación de estado y vencimiento, visor compartido tipo recibo y hub rediseñado. |

---

## 3. Arquitectura actual

Ruta del módulo: `lib/src/modules/expenses/`.

```text
lib/src/modules/expenses/
├── expenses_menu_screen.dart                 # Hub + ExpensesHubBody
├── shared/
│   ├── expense_actions.dart                  # Permisos, editar, pagar, eliminar, snackbars
│   ├── expense_form_utils.dart               # Montos, estado, vencimiento, payload/dateId
│   ├── expense_list_config.dart              # Configuración por tipo de gasto
│   ├── expense_list_screen.dart              # Orquestador responsive de ambas listas
│   ├── expense_metrics.dart                  # Métricas de los registros visibles
│   ├── expense_status_ui.dart                # Badges y regla de vencido
│   └── widgets/
│       ├── expense_filter_panel.dart
│       ├── expense_form_widgets.dart
│       ├── expense_kpi_strip.dart
│       ├── expense_list_tile.dart            # Fila desktop + tarjeta móvil
│       ├── expense_page_header.dart
│       └── expense_table_header.dart
├── operative_expenses/
│   ├── dialogs/create_expense_dialog.dart
│   ├── dialogs/form_section.dart
│   └── view/operative_expenses_screen.dart
├── supplier_expenses/
│   ├── dialogs/create_supplier_expense_dialog.dart
│   ├── dialogs/supplier_form_section.dart
│   └── view/supplier_expenses_view.dart
├── expense_categories/
│   ├── dialogs/create_expense_category_dialog.dart
│   ├── view/expense_categories_view.dart
│   └── widgets/
│       ├── expense_categories_grid.dart
│       ├── expense_categories_header.dart
│       ├── expense_category_card.dart
│       └── expense_category_search_bar.dart
└── expenses_reports/
    ├── expense_report_period.dart            # Presets y rangos de fecha
    ├── expense_report_aggregation.dart       # Totales por tipo y breakdowns
    ├── view/expenses_reports_view.dart
    └── widgets/
        ├── expense_report_header.dart
        ├── expense_report_filters.dart
        ├── expense_report_kpi_grid.dart
        ├── expense_report_view_toggle.dart
        ├── expense_report_detail.dart
        └── expense_report_consolidated.dart
```

### Piezas fuera del módulo

| Pieza | Ruta real | Rol |
| :--- | :--- | :--- |
| Cubits de gastos | `lib/src/cubits/expenses/` | `ReadExpenseCubit` y `WriteExpenseCubit`. |
| Cubits de categorías | `lib/src/cubits/expense_category_cubit/` | `ReadExpenseCategoryCubit` y `WriteExpenseCategoryCubit`. |
| Visor compartido | `lib/widgets/dialogs/viewers/expense_viewer_page.dart` | Ficha de solo lectura. |
| Wrappers de visor | `lib/widgets/dialogs/viewers/operative_expense_viewer.dart` y `supplier_expense_viewer.dart` | Compatibilidad con las listas de Fase 1. |
| DataSources y repositorios | `packages/kardex_business/lib/src/data/` y `.../domain/repositories/` | `ExpensesDataSource`, `ExpenseCategoriesDataSource`, `ExpensesRepository`, `ExpenseCategoriesRepository`. |
| Modelos y query params | `packages/kardex_business/lib/src/domain/models/expense/`, `.../models/expense_category_model/`, `.../query_params/expense_query_params.dart` | `ExpenseInDb`, `CreateExpense`, `UpdateExpense`, `ExpenseCategoryInDb`, `ExpenseQueryParams`. |
| Dropdown de categorías | `lib/widgets/dropdown/expense_category_dropdown.dart` | Selector reutilizable de categorías activas. |
| Rutas | `lib/config/app_router.dart` y `lib/constants/route_names.dart` | Registro del hub y sus rutas hijas. |

Flujo estándar de la arquitectura Onion/BLoC:

```text
Vista / Widget
   ↓ eventos
Cubit (Read/Write)
   ↓
Repositorio (kardex_business)
   ↓
DataSource (HTTP singleton)
   ↓
API FastAPI
```

---

## 4. Base compartida y design system

### 4.1 Utilidades compartidas

| Archivo | Responsabilidad |
| :--- | :--- |
| `shared/expense_actions.dart` | Reglas de permisos, acciones de fila y confirmaciones. Centraliza `edit`, `markAsPaid`, `delete` y el snackbar del módulo. |
| `shared/expense_form_utils.dart` | `parseExpenseAmountCents`, `formatExpenseAmountInput`, `resolveExpenseStatus`, `resolveExpirationDate` y `buildExpensePayload`. |
| `shared/expense_list_config.dart` | Contrato que adapta la lista compartida a cada tipo: título, subtítulo, icono, color, tipo, etiqueta del concepto, textos de búsqueda/vacío, callbacks y soporte de filtros. |
| `shared/expense_list_screen.dart` | Orquesta header, KPIs, filtros, tabla/cards, skeletons, errores, estado vacío y paginación. No conoce los formularios; los recibe por configuración. |
| `shared/expense_metrics.dart` | `ExpenseMetrics.fromExpenses(...)` calcula total, pagado, pendiente, vencido y sus conteos sobre los registros visibles. |
| `shared/expense_status_ui.dart` | Etiqueta, icono y variante de color por estado; badge de vencido; badge de actividad (`Nuevo`/`Actualizado`); función `isExpenseOverdue`. |

### 4.2 Widgets compartidos

| Widget | Uso |
| :--- | :--- |
| `ExpensePageHeader` | Cabecera con icono tintado, título, subtítulo, refresco y botón de creación. |
| `ExpenseKpiStrip` | Cuatro tarjetas: Total registrado, Pagado, Pendiente y Vencidos. Incluye la nota de alcance “sobre N registros visibles de M cargados”. |
| `ExpenseFilterPanel` | Búsqueda, pills de estado, filtro de categoría/proveedor, rango de fechas y limpieza de filtros. |
| `ExpenseTableHeader` / `ExpenseTableRow` | Tabla desktop: Concepto, Documento, Registro, Vencimiento, Estado, Monto y acciones. |
| `ExpenseCardTile` | Tarjeta equivalente para móvil/tablet, con metadatos, badges y menú de acciones. |
| `ExpenseFormSection`, `ExpenseFormColumns`, `ExpenseAmountField`, `ExpenseDateField`, `ExpenseCreditSwitch`, `expenseFormFieldDecoration` | Base visual y campos reutilizables de los formularios. |

### 4.3 Design system

La UI se apoya en el design system y en widgets reutilizables:

- `AppThemeTokens` para colores, radios, bordes y sombras.
- `AppStatusBadge` para estados, actividad y badges personalizados.
- `AppEmptyState` para vacíos y errores con acción de reintento.
- `AppSkeletonLoader` para placeholders de listas y tarjetas.
- `AppDialogHeader` para la cabecera de los diálogos desktop.
- `AppActionTile` para las tarjetas de navegación del hub.
- `PrimaryMenuButton` y `SecondaryMenuButton` (`lib/widgets/buttons/`) para acciones principales y secundarias.
- `ExpenseCategoryDropdown` (`lib/widgets/dropdown/`) para seleccionar categorías activas; conserva el valor actual aunque la categoría haya quedado inactiva.

La composición es responsive: máximo de `1400 px` de contenido, breakpoint principal de lista/reportes en `900 px` y grillas de categorías de 1/2/3 columnas según el ancho.

---

## 5. Detalle de los submódulos

### 5.1 Hub de Gastos (`expenses_menu_screen.dart`)

`ExpensesMenuScreen` monta `MenuAppBar` y `ExpensesHubBody`. El hub es un widget puro que puede probarse sin `GetIt`, con un `shortcutBuilder` opcional para sustituir el envoltorio de atajos.

Contenido:

- **Hero “Centro de Gastos”** con descripción del módulo.
- **Operación:** `Gastos Operativos` (verde) y `Gastos de Proveedores` (naranja).
- **Análisis y configuración:** `Categorías de Gastos` (índigo) y `Reporte de Gastos` (azul).
- **Tip:** recomendación de clasificar los gastos para mejorar los reportes.

Cada tarjeta navega con `context.pushNamed(...)` y se envuelve con `ShortcutAddableListTile` para permitir atajos. El acceso al hub se controla desde Inicio con `Modules.expenses`; no hay guardas adicionales en las rutas hijas.

### 5.2 Listas de gastos operativos y de proveedores

Ambas listas reutilizan `ExpenseListScreen` y solo cambian su `ExpenseListConfig`. La lista usa el `limit` por defecto de `ExpenseQueryParams` (50 registros por página). `OperativeExpenseScreen` y `SupplierExpenseScreen` crean:

- Un `ReadExpenseCubit` con `ExpenseQueryParams()..type = ExpenseType.operative|supplier`.
- Un `WriteExpenseCubit` para las mutaciones.
- Un `BlocListener<WriteExpenseCubit, WriteExpenseState>` que sincroniza la lectura al recibir `ExpenseCreated`, `ExpenseUpdated` o `ExpenseDeleted`.

#### Elementos de la interfaz

- AppBar simple “Gastos” y fondo `AppThemeTokens.surfaceLight`.
- Header con título, subtítulo, refresco y botón de creación.
- Franja de KPIs.
- Panel de búsqueda y filtros.
- Barra de progreso fina durante `ReadExpenseSearching`.
- Tabla en desktop (`>= 900 px`) y tarjetas en móvil/tablet.
- Skeletons de 6 filas o 4 tarjetas durante la carga inicial.
- Estado de error con “Reintentar” y estado vacío contextual (con o sin filtros).
- Paginación con “Cargar más registros” y aviso de error con reintento.

#### Filtros

| Filtro | Aplicación | Nota |
| :--- | :--- | :--- |
| Búsqueda de texto | Local | Busca en categoría, nombre de proveedor, N° documento y descripción. |
| Estado `Todos` | Local | No envía `status` al backend. |
| Estado `Pendientes` | Local | Agrupa `draft`, `open` y `partiallyPaid`; el backend solo acepta un estado por petición, por eso no se envía. |
| Estado `Pagados` | Servidor + local | Envía `status=paid` y vuelve a filtrar en la lista. |
| Estado `Vencidos` | Local | Usa `isExpenseOverdue`; no se envía al backend. |
| Categoría | Servidor + local | Solo en gastos operativos. |
| Proveedor | Servidor + local | Solo en gastos de proveedores. |
| Rango de fechas | Servidor + local | Se aplica sobre `createdAt`, con inicio/fin de día. |

Al cambiar un filtro se resetea el `offset` a 0 y se conserva el `type` del listado. Los filtros locales se aplican sobre los registros ya cargados; por eso “Pendientes” y “Vencidos” pueden requerir cargar más páginas para mostrar todos los resultados del período.

#### KPIs de lista

`ExpenseMetrics.fromExpenses` calcula sobre los registros **visibles** (después de filtros locales y sin eliminados):

- **Total registrado:** todos los no eliminados.
- **Pagado:** estado `paid`.
- **Pendiente:** `draft`, `open` y `partiallyPaid`.
- **Vencidos:** con `expirationDate` ya pasada y estado distinto de `paid`/`cancelled`.

Los KPIs **no son totales globales del backend**. La propia franja indica cuántos registros visibles se están considerando sobre el total cargado.

#### Acciones de fila

El menú de tres puntos expone:

- **Editar:** solo si el gasto fue creado hace menos de 4 horas (`createdAt`).
- **Marcar como pagado:** solo si el estado es `open`; pide confirmación y actualiza `status=paid`. La UI intenta limpiar `expirationDate`, pero el backend actual ignora ese campo en `UpdateExpense`, por lo que el vencimiento anterior puede permanecer.
- **Eliminar:** solo si se cumple la regla de 4 horas; pide confirmación deslizante y, al completarse con éxito, el `BlocListener` llama a `markExpenseDeleted`, por lo que el registro sale de la lista.

No hay acción de abono parcial en esta fase. Las escrituras siempre pasan por `WriteExpenseCubit`; la lista no llama directamente al repositorio.

#### Badges

- **Estado:** `Borrador` (neutro), `Pendiente` (warning), `Pagado` (success), `Parcial` (info), `Cancelado` (danger).
- **Vencido:** se muestra si la fecha límite ya pasó; se compara contra el final del día para no marcar como vencido un gasto que vence hoy.
- **Actividad:** `Nuevo` y `Actualizado` para los registros creados/editados en la sesión.

### 5.3 Formularios de gasto

Los formularios son adaptativos:

- **Desktop/Web:** `showDialog` con `Dialog`, `AppDialogHeader`, ancho máximo de `600 px` y footer con Cancelar/Guardar.
- **Móvil:** `Navigator.push` a una pantalla completa con AppBar, cuerpo desplazable y footer fijo.

La selección se hace con `context.isMobile()`. Al guardar, el diálogo/pantalla retorna el `ExpenseInDb` creado o actualizado.

#### Formulario operativo

Secciones:

1. **Información del gasto:** N° Documento, Fecha, interruptor “¿Es a crédito?” y Fecha de Vencimiento (si aplica).
2. **Clasificación y monto:** Categoría obligatoria (`ExpenseCategoryDropdown`), Monto y Descripción.

Comportamiento:

- Por defecto `isCredit = false`, por lo que un gasto nuevo se guarda como `paid`.
- Al activar crédito se muestra el vencimiento y el estado resultante es `open`.
- La categoría es obligatoria y se selecciona entre las categorías activas/no eliminadas.
- `N° Documento` es opcional en creación.

#### Formulario de proveedor

Secciones:

1. **Proveedor:** selector mediante `showSupplierSelectionDialog`; muestra los días de crédito del proveedor cuando están disponibles.
2. **Información del gasto:** N° Documento, Fecha, crédito y vencimiento.
3. **Monto y detalle:** Monto y Descripción.

Comportamiento:

- Por defecto `isCredit = true`.
- Al seleccionar un proveedor con `creditDays`, el vencimiento se calcula como fecha del documento + días de crédito. Si el usuario cambia la fecha, el vencimiento se recalcula mientras el crédito siga activo.
- El formulario no captura una categoría nueva; conserva la categoría existente al editar y la envía vacía en un alta nueva. El concepto del reporte para proveedores es el nombre del proveedor.

#### Reglas comunes

- **Monto:** se maneja en centavos. `ExpenseAmountField` formatea el valor inicial como `1,234.56` y valida con `parseExpenseAmountCents`.
- **Parser robusto:** acepta `1,234.56`, `1.234,56`, `12,50`, `12.50`, `1,234`, etc.; rechaza formatos ambiguos, negativos, paréntesis y valores no positivos.
- **Validación:** monto requerido y mayor a cero; categoría requerida en operativos; proveedor requerido en proveedores; vencimiento requerido si el crédito está activo.
- **N° Documento en edición:** es de solo lectura, muestra candado y helper text. El DTO `UpdateExpense` de Dart tampoco declara `docNumber`, por lo que no se envía en la actualización.
- **Preservación de estado:** si el usuario no toca el interruptor de crédito, `resolveExpenseStatus` conserva el estado original (`cancelled`, `partiallyPaid`, `draft`, etc.). Si lo cambia, resuelve `open` o `paid`.
- **Preservación de vencimiento:** si no hay cambio de crédito, se conserva el vencimiento original; al pasar a contado con cambio explícito se construye el payload con `expirationDate: null`, pero `UpdateExpense.toJson()` omite los nulos y el backend actual tampoco declara ese campo, por lo que el valor anterior puede permanecer; con crédito activo se usa la fecha actual del formulario.
- **Payload:** `buildExpensePayload` incluye `type`, `branchId`, `createdBy`, `docNumber`, `category`, `description`, `amount`, `date`, `dateId`, `status`, `expirationDate`, `supplierId` y `supplierName`. `dateId` se genera como `YYYY-MM-DD` a partir de `date`.
- **Concurrencia:** si `WriteExpenseCubit` ya está en `WritingExpense`, el submit se ignora para evitar dobles envíos.
- **Feedback:** `WritingExpense` abre el diálogo de carga; `ExpenseCreated`/`ExpenseUpdated` lo cierran y retornan el registro; `WriteExpenseError` muestra el error.

### 5.4 Visor compartido de gastos

Archivo principal: `lib/widgets/dialogs/viewers/expense_viewer_page.dart`.

- `showExpenseViewer(context, expense)` abre la ficha con la sucursal activa.
- `showExpenseViewerFromId(context, expenseId)` carga por ID y mantiene estados de carga/error dentro de la misma pantalla.
- `operative_expense_viewer.dart` y `supplier_expense_viewer.dart` son wrappers de compatibilidad que delegan en las funciones anteriores.

La ficha es **de solo lectura** y se presenta como un recibo:

- Hero con tipo (`Gasto Operativo`, `Gasto de Proveedor`, `Gasto de Impuesto`), N° de documento o `S/N`, badge de tipo, estado y vencido.
- Tarjeta protagonista con el monto.
- Grilla de detalle: proveedor (si aplica), categoría, N° documento, fecha del documento, vencimiento, registrado el, elaborado por, pagado el y sucursal.
- Tarjeta de descripción (o “Sin descripción”).
- Botón “Cerrar” en el footer.

Los acentos cambian por tipo: verde para operativo, naranja para proveedor y morado para impuesto. Las acciones de escritura (editar, pagar, eliminar) se hacen desde la lista, no desde el visor. El visor no muestra abonos parciales porque el modelo Dart no expone `amountPaid`.

### 5.5 Categorías de gastos

`ExpenseCategoriesScreen` crea `ReadExpenseCategoryCubit` y `WriteExpenseCategoryCubit`. La vista:

- Carga las categorías al entrar.
- Muestra header con conteo de categorías no eliminadas, refresco y “Nueva Categoría”.
- Permite buscar localmente por nombre o descripción.
- Renderiza un grid responsive de 1/2/3 columnas con tarjetas de altura fija (`200 px`).
- Cada tarjeta usa un color determinístico derivado del nombre, un botón de edición y badges `Inactiva`, `Nueva` o `Actualizada` cuando aplica.
- Si no hay descripción, muestra “Sin descripción” en cursiva.

El diálogo de categoría:

- Desktop: `Dialog` con ancho máximo `520 px` y `AppDialogHeader`.
- Compacto (`< 700 px`): `Dialog.fullscreen` con AppBar y footer.
- Campos: Nombre obligatorio (máx. 60) y Descripción opcional (máx. 200).
- Pide confirmación deslizante antes de crear/actualizar y muestra carga/error desde el cubit.
- Al crear o editar, la vista actualiza la lista local con `markExpenseCategoryCreated`/`markExpenseCategoryUpdated`.

Refresco robusto:

- `refresh()` conserva la lista anterior mientras recarga.
- Si falla y ya había datos, emite el mismo estado con `refreshError`; la vista muestra “No se pudieron actualizar las categorías. Se muestran los datos anteriores.” y un botón de reintento.
- Si falla la carga inicial, muestra el estado de error con “Reintentar”.

### 5.6 Reporte de gastos

`ExpensesReportScreen` crea un `ReadExpenseCubit` con la sucursal activa, rango inicial de **Hoy**, `limit = 100` y ejecuta `loadAll(maxPages: 20)`.

#### Períodos

| Preset | Rango |
| :--- | :--- |
| Hoy | Día actual. |
| Ayer | Día anterior. |
| Últimos 7 días | Hoy y los 6 días previos. |
| Este mes | Del día 1 del mes actual a hoy. |
| Mes anterior | Mes calendario anterior completo. |
| Fecha Inicio / Fecha Fin | Dos selectores de fecha separados. Los presets los rellenan como atajos y el usuario puede ajustar cada extremo manualmente. |

La tarjeta de filtros muestra **“Fecha Inicio”** y **“Fecha Fin”** como campos separados. Al cambiar cualquiera de los dos, el reporte se recarga automáticamente y no queda ningún preset resaltado. Los presets siguen disponibles como atajos que rellenan ambos campos. El filtro y la columna “Registro” usan `createdAt`, no `date`.

#### Carga y límites

- Primera página: `100` registros.
- `loadAll` recorre hasta `20` páginas → máximo **2,000 registros**.
- Si al llegar al límite `hasMore` sigue en `true`, la vista muestra un aviso para acotar el rango de fechas.
- Si falla una carga adicional, muestra un aviso de error con “Reintentar”.
- Mientras recarga, el botón de exportación se deshabilita.

#### KPIs

`ExpenseReportKpiGrid` calcula con `ExpenseMetrics` y `summarizeExpenseTypes`:

- Total registrado.
- Operativos.
- Proveedores.
- Impuestos (solo si `tax > 0`).
- Pagado.
- Pendiente.
- Vencidos.
- Cancelados (solo si hay cancelados).

La nota inferior indica sobre cuántos registros del período se calcularon los montos. Los impuestos se incluyen en el total y se muestran aparte; no se mezclan en los consolidados por categoría ni por proveedor.

#### Detalle

- Desktop: tabla con Tipo, Concepto, Documento, Registro, Vencimiento, Estado y Monto.
- Móvil: tarjetas con tipo, concepto, descripción, monto, documento, estado, vencimiento y fecha de registro.
- La paginación es **local**: muestra 100 registros y aumenta de 100 en 100 con “Mostrar más”. Se reinicia a 100 cuando cambia la lista de items.
- El concepto se resuelve así: categoría para operativos, nombre del proveedor para proveedores y categoría (o descripción) para impuestos.

#### Consolidado

`ExpenseReportConsolidatedView` muestra:

- Total del período con conteo de registros.
- Aviso de impuestos incluidos cuando existen.
- Dos tarjetas: **Operativos por categoría** y **Proveedores por proveedor**.
- Dona (`fl_chart`) + leyenda/ranking con monto, porcentaje y barra de proporción.
- Hasta 6 grupos visibles por dimensión + una fila “Otros” para el resto.
- Los porcentajes se calculan sobre el total completo de la dimensión, no solo sobre las filas visibles.

#### Exportación

- Botón “Exportar” → `showExportOptionsDialog` con CSV o PDF.
- **CSV:** cabecera `Tipo,N° Documento,Concepto,Registro,Estado,Monto`; usa `createdAt` para la columna “Registro”.
- **PDF:** plantilla `ExpensesReportTemplate` con columna “Registro” y `createdAt`.
- Nombre de archivo: `reporte_gastos_<dd-MMM-yy>_a_<dd-MMM-yy>` (por ejemplo, `reporte_gastos_10-nov-26_a_10-nov-26`).
- Se exportan los registros cargados/no eliminados del período, no solo la página visible del detalle.
- Si el período supera el límite de 2,000, la exportación también queda limitada a esos registros cargados.

---

## 6. Flujo de estado, cubits y paginación

### 6.1 `ReadExpenseCubit`

Archivo: `lib/src/cubits/expenses/read_expenses_cubit.dart`.

| Elemento | Comportamiento |
| :--- | :--- |
| `getAll([params])` | Resuelve `branchId` (inyectado o `AuthCubit`), carga gastos y categorías en paralelo, descarta respuestas de generaciones anteriores y emite `ReadExpenseSuccess`. |
| `ReadExpenseSearching` | Extiende `ReadExpenseSuccess` y conserva los items anteriores mientras llega la primera página. |
| `refresh()` | Vuelve a la primera página manteniendo los filtros activos. |
| `applyFilters(...)` | Aplica estado/categoría/proveedor/fechas, conserva `type` y resetea `offset` a 0. |
| `clearFilters()` | Limpia los filtros de servidor. |
| `loadMore()` | Carga la siguiente página sin vaciar la lista y con deduplicación por ID. |
| `loadAll({maxPages})` | Encadena `getAll` + `loadMore` para el reporte; se detiene al agotar `hasMore`, ante error o al alcanzar `maxPages`. |
| `getById(id)` | Carga un gasto puntual. |
| `markExpenseCreated/Updated/Deleted` | Sincroniza la lista tras una mutación y ajusta la membresía del conjunto filtrado. |

Paginación:

- El offset de la siguiente página se deriva de `_serverCountedIds.length`, no de un contador paralelo.
- `_serverCountedIds` contiene exactamente los registros cargados que cumplen los filtros enviados al servidor.
- Al crear un gasto que cumple los filtros se agrega al set; al actualizarlo se agrega o quita según corresponda; al eliminarlo se quita.
- `_requestGeneration` invalida respuestas viejas de la primera página.
- `_mutationGeneration` invalida una página de `loadMore` si hubo una mutación local mientras estaba en vuelo; la página se descarta y el siguiente `loadMore` recalcula el offset.
- `loadMoreError` conserva la lista visible y permite reintentar.
- `hasMore` se calcula con `results.length >= pageSize`; si el backend devuelve exactamente una página llena, se asume que puede haber más.

### 6.2 `WriteExpenseCubit`

Archivo: `lib/src/cubits/expenses/write_expenses_cubit.dart`.

- `create(CreateExpense)` emite `WritingExpense`, luego `ExpenseCreated` y vuelve a `WriteExpenseInitial`.
- `update(id, UpdateExpense)` y `delete(id)` retornan `bool`; permiten que las acciones distingan éxito de error y muestren el diálogo correspondiente.
- Los estados `ExpenseCreated`, `ExpenseUpdated` y `ExpenseDeleted` son capturados por el `BlocListener` de cada lista para actualizar el `ReadExpenseCubit`.

### 6.3 `ReadExpenseCategoryCubit`

Archivo: `lib/src/cubits/expense_category_cubit/read_expense_categories_cubit.dart`.

- `getAll()` emite carga y luego éxito/error.
- `refresh()` conserva los items si ya había una lista; si falla, emite `ReadExpenseCategorySuccess.copyWith(refreshError: ...)`.
- `_requestGeneration` descarta respuestas obsoletas.
- `searchByKeyword`, `markExpenseCategoryCreated`, `markExpenseCategoryUpdated` y `markExpenseCategoryDeleted` mantienen la reactividad local.

### 6.4 Secuencia de una mutación

```text
Fila → ExpenseActions → WriteExpenseCubit
        ↓
   API /expenses
        ↓
WriteExpenseCubit emite ExpenseCreated|Updated|Deleted
        ↓
BlocListener de la lista → ReadExpenseCubit.mark...
        ↓
La UI se reconstruye y refleja el cambio
```

---

## 7. Semántica de fechas y exportación

| Campo | Significado | Uso actual |
| :--- | :--- | :--- |
| `date` | Fecha del documento en milisegundos. | Campo “Fecha” de los formularios; se muestra como “Fecha documento” en el visor. No se usa para filtrar el reporte. |
| `dateId` | Fecha date-only en formato `YYYY-MM-DD`, derivada de `date`. | Compatibilidad con registros existentes y payload del backend. |
| `createdAt` | Fecha/hora de registro generada por el servidor. | Filtro de listas y reporte, columna “Registro” y exportaciones CSV/PDF. |
| `expirationDate` | Fecha de vencimiento del gasto a crédito. | Formularios, visor y regla de vencido. El backend actual no la persiste en `UpdateExpense`. |
| `paidAt` | Fecha/hora de pago. | Se muestra como “Pagado el” en el visor. |

Reglas:

- Las listas filtran por rango de fechas y muestran la columna “Registro” con `createdAt`.
- El reporte usa los campos “Fecha Inicio” y “Fecha Fin” y `createdAt` tanto en la pantalla como en CSV/PDF.
- `date` sigue siendo la fecha del documento y se conserva para el formulario, el visor y la compatibilidad de datos; no es la fecha del reporte.
- La exportación CSV/PDF usa los registros cargados del período y la etiqueta “Registro”, no `date`.

---

## 8. Rutas

Registradas en `lib/config/app_router.dart` bajo el prefijo `/expenses`:

| Ruta | Nombre | Pantalla |
| :--- | :--- | :--- |
| `/expenses` | `expenses` | `ExpensesMenuScreen` (hub). |
| `/expenses/operative-expenses` | `operative-expenses` | `OperativeExpenseScreen`. |
| `/expenses/supplier-expenses` | `supplier-expenses` | `SupplierExpenseScreen`. |
| `/expenses/expense-categories` | `expense-categories` | `ExpenseCategoriesScreen`. |
| `/expenses/expenses-report` | `expenses-report` | `ExpensesReportScreen`. |

Los nombres también existen como constantes en `lib/constants/route_names.dart` (`expenses`, `operativeExpenses`, `supplierExpenses`, `expenseCategories`, `expensesReport`). El hub navega con `context.pushNamed(...)`.

Los formularios no tienen ruta propia: se abren como diálogo o pantalla completa según plataforma. El visor tampoco tiene ruta: se abre con `Navigator.push`.

---

## 9. Capa de datos y endpoints

| Capa | Clase / archivo | Endpoint o responsabilidad |
| :--- | :--- | :--- |
| DataSource | `ExpensesDataSource` (`packages/kardex_business/lib/src/data/expenses_data_source.dart`) | `/expenses`: crear, listar, obtener por ID, actualizar, eliminar y `add-to-amount-paid`. |
| Repositorio | `ExpensesRepository` (`packages/kardex_business/lib/src/domain/repositories/expenses_repository.dart`) | Mapea JSON a `ExpenseInDb` y mantiene caché en memoria de la lista. |
| DataSource | `ExpenseCategoriesDataSource` (`.../data/expense_categories_data_source.dart`) | `/expense-categories`: CRUD de categorías. |
| Repositorio | `ExpenseCategoriesRepository` (`.../domain/repositories/expense_categories_repository.dart`) | Mapea categorías y mantiene la lista en memoria. |
| Modelos | `ExpenseInDb`, `BaseExpense`, `CreateExpense`, `UpdateExpense`, `AddToAmountRequest` | `packages/kardex_business/lib/src/domain/models/expense/expense_model.dart`. |
| Modelos | `ExpenseCategoryInDb`, `CreateExpenseCategory`, `UpdateExpenseCategory` | `packages/kardex_business/lib/src/domain/models/expense_category_model/expense_category_model.dart`. |
| Query params | `ExpenseQueryParams` | Offset, límite, estado, fechas, usuario, sucursal, categoría, documento, montos, tipo y proveedor. |

Los repositorios y DataSources se inyectan en `lib/provider_container.dart`. `ExpenseQueryParams.toMap()` elimina los valores nulos antes de enviar la consulta.

El backend devuelve listas envueltas en `ListResponse<ExpenseInDb>` / `ListResponse<ExpenseCategoryInDb>`; el repositorio extrae `data`.

---

## 10. Pruebas y verificación

### Comandos ejecutados

```bash
flutter analyze
flutter test
dart analyze packages/kardex_business
```

Resultados registrados:

- `flutter analyze` → **No issues found**.
- `flutter test` completo → **199 tests passed**.
- `dart analyze packages/kardex_business` → **No issues found**.
- Suite específica de Gastos → **96 tests** (incluye casos parametrizados por ancho de pantalla).

### Archivos de prueba del módulo

| Archivo | Cobertura principal |
| :--- | :--- |
| `test/expense_metrics_test.dart` | Cálculo de métricas, estados, vencidos y montos. |
| `test/expense_shared_layout_test.dart` | Layout responsive de header, KPIs, filtros, tabla, tarjetas, estados vacíos y paginación. |
| `test/expense_reports_test.dart` | Presets de período, agregación, consolidado, CSV, `loadAll`, KPIs y paginación local del detalle. |
| `test/expense_categories_test.dart` | Grid, tarjetas, badges, búsqueda, refresh con error y diálogo responsive. |
| `test/expense_forms_test.dart` | Parser de montos, estado/vencimiento, payload de edición y formularios responsive. |
| `test/expense_viewers_test.dart` | Ficha de solo lectura, campos, tipos y estados. |
| `test/expenses_menu_test.dart` | Render del hub y tarjetas de navegación; no valida taps ni rutas. |

No se modificaron tests en esta actualización documental; los resultados anteriores corresponden a la verificación de la rama.

---

## 11. Limitaciones y dependencias de backend

1. **Categorías: `description` e `isActive` no persisten.**
   El modelo base de Pydantic del backend (`expense_category_model.py`) solo declara `name`; no declara `description` ni `isActive`. El frontend incluye `description` en el payload e `isActive` en el modelo de creación, pero el servidor los descarta; además, el diálogo no expone un control de `isActive`. La UI usa fallback: “Sin descripción” cuando falta texto y `isActive = true` cuando el campo no llega. Para persistir ambos campos hay que ampliar el modelo y el repositorio del backend.

2. **`UpdateExpense` del backend no incluye `docNumber`, `expirationDate` ni `supplierName`.**
   El DTO Dart `UpdateExpense` incluye `expirationDate` y `supplierName` y los envía cuando tienen valor, pero el servidor los ignora. `docNumber` tampoco existe en el DTO Dart de actualización; por eso el N° Documento quedó de solo lectura en edición. Consecuencias:
   - El N° Documento no se puede modificar desde la UI.
   - La fecha de vencimiento editada no se persiste en el backend.
   - El nombre de proveedor editado no se persiste; el `supplierId` sí forma parte del modelo de actualización.
   Para habilitar estos cambios hace falta modificar el backend y luego el DTO/UI.

3. **`amountPaid` existe en el backend pero no en `ExpenseInDb` de Dart.**
   El backend tiene `amountPaid` y el endpoint `add-to-amount-paid`; el repositorio Dart incluso expone `addToAmountPaid`, pero el modelo `ExpenseInDb` no lee el campo y no hay UI de abonos. Los gastos `partiallyPaid` muestran el badge “Parcial”, pero se agrupan como pendientes en los KPIs y en el filtro “Pendientes”; no se puede consultar ni editar el monto abonado en esta fase.

4. **El reporte limita la carga a 2,000 registros.**
   `loadAll(maxPages: 20)` con páginas de 100. Si el período supera ese volumen, la vista avisa y la exportación solo incluye los registros cargados. Para períodos mayores hay que acotar fechas o ampliar el límite/estrategia de carga.

5. **Los KPIs de lista no son totales globales.**
   Se calculan sobre los registros cargados y visibles después de filtros locales. La franja muestra la relación “visibles de cargados”, pero no representa el total del período en el backend.

6. **El visor es de solo lectura.**
   Editar, marcar como pagado y eliminar se hacen desde la lista. El visor no expone acciones de escritura ni abonos.

7. **El tipo `tax` no tiene flujo de alta en la UI de esta fase.**
   El modelo, el visor, los KPIs y los consolidados lo contemplan, pero los formularios actuales solo crean `operative` y `supplier`. Los registros `tax` existentes se muestran correctamente en reportes y visor.

8. **La UI de categorías no expone eliminación.**
   `WriteExpenseCategoryCubit.delete` existe, pero el grid solo ofrece edición. Eliminar una categoría requeriría agregar la acción y su confirmación.

---

## 12. Regla `main` / `lite`

El rediseño de Gastos es **UI compartida** del frontend: no contiene cambios lite-only.

- Aplica a `main` y debe sincronizarse con `lite` mediante `git merge main` en la rama `lite`.
- No se debe mergear `lite` completo hacia `main`.
- Las limitaciones de backend (categorías, `UpdateExpense`, `amountPaid`) son las mismas en ambas ediciones mientras no cambie el servidor.
- Si en el futuro se agrega una funcionalidad exclusiva de `lite`, debe implementarse en esa rama y documentarse como lite-only.

Consulta la regla completa en [ramas_main_vs_lite.md](../ramas_main_vs_lite.md#8-reglas-para-desarrollo-y-mantenimiento).

---

## 13. Referencias rápidas

- Hub: [`expenses_menu_screen.dart`](../../lib/src/modules/expenses/expenses_menu_screen.dart)
- Lista compartida: [`expense_list_screen.dart`](../../lib/src/modules/expenses/shared/expense_list_screen.dart)
- Acciones: [`expense_actions.dart`](../../lib/src/modules/expenses/shared/expense_actions.dart)
- Utilidades de formulario: [`expense_form_utils.dart`](../../lib/src/modules/expenses/shared/expense_form_utils.dart)
- Reporte: [`expenses_reports_view.dart`](../../lib/src/modules/expenses/expenses_reports/view/expenses_reports_view.dart)
- Categorías: [`expense_categories_view.dart`](../../lib/src/modules/expenses/expense_categories/view/expense_categories_view.dart)
- Visor: [`expense_viewer_page.dart`](../../lib/widgets/dialogs/viewers/expense_viewer_page.dart)
- Cubit de lectura: [`read_expenses_cubit.dart`](../../lib/src/cubits/expenses/read_expenses_cubit.dart)
- Cubit de escritura: [`write_expenses_cubit.dart`](../../lib/src/cubits/expenses/write_expenses_cubit.dart)
- Rutas: [`app_router.dart`](../../lib/config/app_router.dart)
- Pruebas: [`expense_reports_test.dart`](../../test/expense_reports_test.dart), [`expense_forms_test.dart`](../../test/expense_forms_test.dart), [`expense_shared_layout_test.dart`](../../test/expense_shared_layout_test.dart)
