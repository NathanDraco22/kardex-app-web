# Documentación del Módulo: Configuración del Sistema (`settings`)

El módulo **Configuración** centraliza la parametrización de sucursales, usuarios, roles, llaves de API, integraciones con hardware externo y reglas de asignación de precios en `kardex_app_front`.

---

## 1. Arquitectura y Submódulos

Ubicación: `lib/src/modules/settings/`:

```text
lib/src/modules/settings/
├── view/
│   ├── settings_screen.dart             # Menú general de ajustes y parámetros
│   ├── branches/                        # Gestión de sucursales comerciales y bodegas
│   ├── users/                           # Usuarios, cajeros y asignación de roles
│   ├── api_keys/                        # Llaves de acceso y tokens de servicios externos
│   ├── integrations/                    # Impresoras térmicas, básculas y pasarelas
│   ├── price_to_product/                # Matriz de precios por producto y sucursal
│   └── app_settings/                    # Configuraciones y reglas globales del sistema
```

---

## 2. Detalle de Submódulos Clave

### 2.1. Sucursales (`branches`)
- **Propósito:** Administración de los centros de operaciones de la empresa (tiendas, bodegas, sucursales comerciales).
- **Vistas:** `BranchesScreen`, `BranchesScreenWeb`, `CreateBranchDialog`.
- **Propiedad Crítica `isCommerce`:**
  - `isCommerce == true`: La sucursal opera como comercio con punto de venta, emisión de facturas y cuentas por cobrar. Icono identificativo de tienda comercial en tonos ámbar.
  - `isCommerce == false`: La sucursal es estrictamente una bodega/almacén logístico. El sistema oculta automáticamente las opciones de Comercio y Cuentas por Cobrar en el menú principal y bloquea el acceso en el router. Icono identificativo de bodega en tonos pizarra.

### 2.2. Usuarios y Roles (`users`)
- **Propósito:** Creación y mantenimiento de las credenciales de los operadores del sistema.
- **Vistas:** `UsersScreen`, `UsersWebScreen`.
- **Funcionalidades:**
  - Asignación de roles predefinidos (Admin, Cajero, Bodeguero, Vendedor, Supervisor).
  - Asociación de sucursales permitidas para cada usuario.
  - Activación/desactivación de cuentas y reseteo de contraseñas.
  - Integración con `RolePermissionGate` (`lib/widgets/gates/`) para mostrar u ocultar componentes según los permisos del usuario activo.

### 2.3. Llaves de API (`api_keys`)
- **Propósito:** Configuración de tokens y credenciales para APIs externas de facturación electrónica gubernamental, pasarelas de pago o servicios de mensajería SMS/WhatsApp.
- **Vistas:** `ApiKeysScreen`.

### 2.4. Integraciones (`integrations`)
- **Propósito:** Configuración de periféricos locales:
  - Impresoras de tickets térmicos (ancho 58mm / 80mm, USB, Red o Bluetooth).
  - Lectores de códigos de barras (modo emulación teclado o serial).
  - Balanzas electrónicas y cajones portamonedas.
- **Vistas:** `IntegrationsScreen`.

### 2.5. Matriz de Precios a Productos (`price_to_product`)
- **Propósito:** Parametrizar y sincronizar márgenes de ganancia, precios mínimos y precios mayoristas entre diferentes sucursales.
- **Vistas:** `PriceToProductScreen`.

### 2.6. Configuraciones del Sistema (`app_settings`)
- **Propósito:** Parametrizar reglas operativas y banderas globales que rigen el comportamiento comercial, logístico y financiero en toda la aplicación.
- **Vistas:** `AppSettingsScreen` (`lib/src/modules/settings/view/app_settings/app_settings_screen.dart`).
- **Ubicación en Navegación:**
  - Móvil (`SettingsScreen`): Tarjeta `MenuOptionCard` al final del listado, justo después de *Configuración de Impresora Local*.
  - Escritorio (`home_modules_registry.dart`): Submódulo `HomeSubmoduleItem` al final de la categoría `Modules.settings`, después de *Impresora Local*.
- **Cubit / Estado:** `AppSettingsCubit` y `AppSettingsState` (`lib/src/cubits/app_settings/`), inyectado globalmente en `ProviderContainer` con carga automática al inicio.
- **Parámetros Configurados (`AppSettingModel` / `UpdateAppSetting`):**
  - `useDefaultProfitMargin` (bool): Habilitar o no el cálculo automático de margen de ganancia por defecto.
  - `defaultProfitMargin` (double): Porcentaje de margen sugerido (ej. 20.0%).
  - `useExpirationDates` (bool): Habilitar seguimiento de lotes y alertas de caducidad.
  - `useOrders` (bool): Habilitar módulo comercial de órdenes y pedidos.
  - `useQuotations` (bool): Habilitar emisión de cotizaciones y presupuestos/proformas.
  - `allowNegativeStock` (bool): Permitir ventas aun sin existencias físicas en la sucursal.
  - `alertMinStock` (bool): Activar alertas visuales de existencia mínima.
  - `defaultPaymentTermDays` (int): Días de crédito predeterminados para facturación.
  - `useHoldSales` (bool): Permitir pausar carritos en terminal de venta.

---

## 3. Repositorios y Fuentes de Datos Involucrados

| Submódulo | DataSource | Repositorio |
| :--- | :--- | :--- |
| Sucursales | `BranchesDataSource` | `BranchesRepository` |
| Usuarios | `UsersDataSource` | `UsersRepository` |
| Integraciones | Almacenamiento local / Preferencias | `SharedPreferences` / Hive |
| Configuraciones del Sistema | `AppSettingsDataSource` | `AppSettingsRepository` |

---

## 4. Rutas en `app_router.dart`

- `/settings`: Menú principal de configuraciones.
- `/settings/branches`: Listado y edición de sucursales.
- `/settings/users`: Administración de usuarios y roles.
- `/settings/api-keys`: Gestión de credenciales de API.
- `/settings/integrations`: Integraciones de periféricos.
- `/settings/price-to-product`: Asignación de precios a productos.
- `/settings/app-settings`: Parámetros y reglas globales del sistema.
