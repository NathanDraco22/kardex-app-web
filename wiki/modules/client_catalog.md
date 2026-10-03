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
│   ├── cubit/                           # ClientGroupsCubit
│   └── client_groups_screen.dart        # Gestión de grupos y tarifas especiales
├── initial_balance/                     # Configuración de balances y deudas históricas
│   └── view/initial_balance_screen.dart # Pantalla de carga de saldos iniciales
└── cllient_map/                         # Localización y rutas en mapa
    └── client_map_screen.dart           # Visualizador de clientes geolocalizados
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
- **Diálogos:**
  - `showCreateClientDialog`: Modal con validaciones para alta/edición de clientes.

### 2.2. Grupos de Clientes (`client_groups`)
- **Propósito:** Segmentación de clientes (ej. "Mayoristas", "Minoristas", "VIP", "Distribuidores") para aplicar listas de precios y porcentajes de descuento predefinidos.
- **Vistas:** `ClientGroupsScreen`.
- **Cubits:** `ClientGroupsCubit`.

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
| Grupos de Clientes | `ClientGroupsDataSource` | `ClientGroupsRepository` |

---

## 4. Rutas en `app_router.dart`

- `/clients`: Menú principal del catálogo de clientes.
- `/clients/list`: Listado y mantenimiento de clientes.
- `/clients/groups`: Grupos de clientes.
- `/clients/initial-balance`: Carga de balance inicial.
- `/clients/map`: Visualizador de clientes en mapa.
