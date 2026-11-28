# Documentación del Módulo: Catálogo de Clientes (`client_catalog`)

El módulo **Catálogo de Clientes** administra el directorio de clientes, sus límites y condiciones de crédito, su clasificación por grupos, su balance inicial histórico y su distribución geográfica en mapas en `kardex_app_front`.

---

## 1. Arquitectura y Submódulos

Ubicación: `lib/src/modules/client_catalog/`:

```text
lib/src/modules/client_catalog/
├── client_catalog_menu_screen.dart      # Menú principal de clientes
├── client_list/                         # Directorio maestro de clientes
│   ├── cubit/                           # ClientCubit, ClientState
│   ├── dialogs/                         # CreateClientDialog, ClientDetailsModal
│   └── view/client_catalog_screen.dart  # Pantalla principal del catálogo
├── client_groups/                       # Segmentación y grupos comerciales
│   ├── dialog/                          # ClientGroupFormDialog (alta/edición)
│   └── client_groups_screen.dart        # Gestión de grupos y tarifas especiales
├── initial_balance/                     # Configuración de balances y deudas históricas
│   └── view/initial_balance_screen.dart # Pantalla de carga de saldos iniciales
└── cllient_map/                         # Localización y rutas en mapa
    └── client_map_screen.dart           # Visualizador de clientes geolocalizados

lib/src/cubits/client_group_cubit/       # Cubits globales de grupos de clientes
├── read_client_group_cubit.dart         # Lista reactiva (fuente de verdad)
├── read_client_group_state.dart
├── write_client_group_cubit.dart        # Alta/edición/borrado
└── write_client_group_state.dart

lib/widgets/dialogs/selectors/
└── client_group_selection_dialog.dart   # Selector modal con búsqueda local y alta rápida
```

---

## 2. Detalle de Submódulos Clave

### 2.1. Directorio Maestro de Clientes (`client_list`)
- **Propósito:** Registro, actualización, búsqueda y desactivación de clientes.
- **Vistas:** `ClientCatalogScreen`.
- **Cubits:** `ClientCubit`.
- **Información del Cliente:**
  - Identificación tributaria (RNC/Cédula/NIT), Nombre comercial y Razón social.
  - Teléfono, Email, Dirección y Ubicación GPS.
  - Límite de crédito permitido y días de plazo acordados.
  - Balance actual deudor acumulado en tiempo real.
  - Nivel de precio predeterminado (`defaultPriceLevel`).
- **Diálogos:**
  - `showCreateClientDialog`: Modal con validaciones para alta/edición de clientes.

#### Precio preferencial del cliente (`usePreferredPrice` + `defaultPriceLevel`)

- **Valores:** `usePreferredPrice = true` aplica `defaultPriceLevel` (`1..4` = “Precio 1”…“Precio 4”). `usePreferredPrice = false` significa **“Sin Preferencia”** y se guarda siempre con `defaultPriceLevel = 1`. Un nivel `0` o fuera de `1..4` tampoco aplica preferencia.
- **Alta:** los clientes nuevos creados desde la app nacen en `usePreferredPrice = false` y nivel `1`. Los clientes existentes conservan su bandera y nivel. Un documento persistido o legacy sin `usePreferredPrice` se lee como `true` con su nivel actual (o `1` si falta el nivel). Si un cliente existente trae `usePreferredPrice = true` pero un nivel fuera de `1..4`, el formulario normaliza a `false` + `1` mediante `ClientPricePreferencePolicy.normalize`.
- **Selector:** `ClientPriceLevelDropdown` (`lib/src/modules/client_catalog/client_list/widgets/client_price_level_dropdown.dart`) es el widget compartido por el diálogo del catálogo y el de cuentas por cobrar (`finance/client_accounts`). Solo se muestra cuando `AppSettingsPolicy.useClientPreferredPrices` está activo. “Sin Preferencia” entrega `false` + `1`; “Precio N” entrega `true` + `N`.
- **Persistencia:** el formulario siempre envía `usePreferredPrice` y `defaultPriceLevel` para no borrar el valor existente al editar con el selector oculto. `UpdateClient.toJson` conserva `false` y el nivel enviado.
- **Aplicación:** la preferencia se aplica al seleccionar el cliente en terminal de venta y facturación mediante `ClientPricePreferencePolicy`; “Sin Preferencia” deja intactos el nivel y los precios del carrito.

### 2.2. Grupos de Clientes (`client_groups`)
- **Propósito:** Segmentación de clientes (ej. "Mayoristas", "Minoristas", "VIP", "Distribuidores") para aplicar listas de precios y porcentajes de descuento predefinidos.
- **Vistas:** `ClientGroupsScreen` (envuelve `ClientGroupsScreenWeb`).
- **Cubits globales:** `ReadClientGroupCubit` y `WriteClientGroupCubit` viven en `lib/src/cubits/client_group_cubit/` y se registran/exponen desde `GlobalCubitProvider` (`lib/provider_container.dart`). La pantalla llama `ensureLoaded()` en `initState` y no crea providers locales.
- **Repositorio reactivo:** `ClientGroupsRepository` implementa el mixin `ReactiveRepository<ClientGroupInDb>` y **no mantiene caché interna**. `ReadClientGroupCubit` escucha `eventStream` y es la única fuente de verdad de la lista; los eventos `notifyItemCreated/Updated/Deleted` actualizan el estado sin recargar.
- **Selector modal:** `lib/widgets/dialogs/selectors/client_group_selection_dialog.dart` expone `showClientGroupSelectionDialog(...)`. Filtra localmente por nombre/descripción sobre el estado del `ReadClientGroupCubit`, permite elegir "Sin grupo" y ofrece el botón **"Crear Grupo de Clientes"**, que abre `showClientGroupFormDialog` y selecciona automáticamente el grupo creado. Se usa en el formulario de clientes (`create_client_dialog.dart`) en lugar del autocompletado anterior.
- **Formulario:** `dialog/client_group_form_dialog.dart` usa el `WriteClientGroupCubit` global vía `context.read`; la lista se refresca por eventos, sin `putGroupFirst`/`markGroupUpdated`.

### 2.3. Balance Inicial (`initial_balance`)
- **Propósito:** Carga o migración de saldos adeudados previos a la implantación del sistema, permitiendo iniciar operaciones con carteras preexistentes.
- **Vistas:** `InitialBalanceScreen`.

### 2.4. Mapa de Clientes (`cllient_map`)
- **Propósito:** Visualización de clientes en un mapa interactivo (usando `lib/widgets/map/`) para planificar rutas de cobranza, entregas a domicilio o prospección comercial.
- **Vistas:** `ClientMapScreen`.

---

## 3. Repositorios y Fuentes de Datos Involucrados

| Submódulo | DataSource | Repositorio |
| :--- | :--- | :--- |
| Clientes | `ClientDataSource` | `ClientRepository` |
| Grupos de Clientes | `ClientGroupsDataSource` | `ClientGroupsRepository` (`ReactiveRepository`, sin caché) |

---

## 4. Rutas en `app_router.dart`

- `/clients`: Menú principal del catálogo de clientes.
- `/clients/list`: Listado y mantenimiento de clientes.
- `/clients/groups`: Grupos de clientes.
- `/clients/initial-balance`: Carga de balance inicial.
- `/clients/map`: Visualizador de clientes en mapa.
