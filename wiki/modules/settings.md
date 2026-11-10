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

### 2.4. Integraciones y Periféricos (`integrations`)
- **Propósito:** Configuración de periféricos locales:
  - Impresoras de tickets térmicos (ancho 58mm / 80mm, USB o Bluetooth) con soporte de impresión directa nativa ESC/POS en 1 clic y fallback automático al diálogo del sistema.
  - Ver guía técnica completa, arquitectura y post-mortems en [Sistema de Impresión Térmica Directa](../sistema_impresion_termica.md).
  - Diálogo de configuración local interactivo: `LocalPrinterSettingsDialog` (`lib/src/modules/settings/view/local_printer_settings_dialog.dart`), accesible desde el menú de Ajustes en móvil y escritorio para vincular impresoras, calibrar papel, invertir polaridad, tramado halftone y pruebas de impresión.
  - Lectores de códigos de barras (modo emulación teclado o serial).
  - Balanzas electrónicas y cajones portamonedas.
- **Vistas:** `IntegrationsScreen`, `LocalPrinterSettingsDialog`.

### 2.5. Matriz de Precios a Productos (`price_to_product`)
- **Propósito:** Parametrizar y sincronizar márgenes de ganancia, precios mínimos y precios mayoristas entre diferentes sucursales.
- **Vistas:** `PriceToProductScreen`.

### 2.6. Configuraciones del Sistema (`app_settings`)
- **Propósito:** Parametrizar reglas operativas y banderas globales que rigen el comportamiento comercial, logístico y financiero en toda la aplicación.
- **Vistas:** `AppSettingsScreen` (`lib/src/modules/settings/view/app_settings/app_settings_screen.dart`).
- **Ubicación en Navegación:**
  - Móvil (`SettingsScreen`): Tarjeta `MenuOptionCard` al final del listado, justo después de *Configuración de Impresora Local*.
  - Escritorio (`home_modules_registry.dart`): Submódulo `HomeSubmoduleItem` al final de la categoría `Modules.settings`, después de *Impresora Local*.
- **Cubit / Estado:** `AppSettingsCubit` y `AppSettingsState` (`lib/cubits/app_settings/`), inyectado globalmente en `ProviderContainer` como Singleton en `getIt<AppSettingsCubit>()` y precargado en `SplashScreen`.
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
  - `useQuickProductSearch` (bool): Abrir directamente el buscador rápido con botones de agregar y quitar cantidad al agregar productos en móvil (facturas, órdenes y cotizaciones; por defecto: `false`).
  - `currency` (`AppCurrency`): Moneda global del sistema (`NIO`, `USD`, `HNL`, `GTQ`, `CRC`, `COP`, `MXN`, `EUR`; por defecto `NIO`). Solo define el símbolo visual usado por `NumberFormatter` en pantallas, tickets y reportes; no convierte montos existentes.
    - El símbolo se resuelve mediante `NumberFormatter.configureCurrencyResolver`, registrado por `AppSettingsCubit` al construirse. Así, cualquier pantalla, PDF o ticket que use `NumberFormatter` adopta la moneda automáticamente.
    - El contador de efectivo (`cash_counter`) mantiene sus denominaciones físicas de Córdobas y Dólares y no cambia con esta configuración.
  - `secondaryCurrency` (`AppCurrency`): Moneda secundaria informativa (`USD` por defecto). Se muestra junto a la moneda principal en la tile superior de configuración; no convierte montos ni modifica precios.
  - `exchangeRate` (double): Tasa informativa donde `1` unidad de la moneda secundaria equivale a `exchangeRate` unidades de la moneda principal. `0.0` significa “sin configurar”. No se usa en cálculos, tickets ni reportes.
    - La tile “Moneda y tasa de cambio” es el primer elemento de `AppSettingsScreen`. Al tocarla se abre `showCurrencySettingsDialog`, que guarda únicamente `currency`, `secondaryCurrency` y `exchangeRate` mediante un PATCH parcial.
    - El botón inferior “Guardar Configuraciones” conserva el resto de parámetros y no sobrescribe la moneda ni la tasa.
  - `showInvoiceTotalInSecondaryCurrency` (bool): Muestra el equivalente del total de facturas en la moneda secundaria (`false` por defecto).
    - La opción se controla con el switch “Mostrar total de facturas en moneda secundaria (USD)” debajo de la tile de moneda y se guarda con el botón inferior.
    - El equivalente aparece después del total final en el visor de facturas, el ticket térmico (imprimir/compartir) y el PDF A4.
    - Solo se muestra si la moneda secundaria es distinta a la principal y la tasa es mayor que cero. No modifica montos, pagos, cuentas por cobrar ni inventario.
    - La línea usa el formato `Total(USD): US$27.31`.
  - `companyLogoUrl` (`String?`): URL pública de la imagen corporativa global de la empresa. Es un parámetro **solo estético**; no se usa en facturas, tickets, reportes ni cálculos.

#### Identidad de la Empresa (`companyLogoUrl`):
- La sección **“Identidad de la empresa”** es el primer bloque de `AppSettingsScreen`.
- Permite **subir, cambiar o quitar** una imagen JPG/PNG desde la galería. La imagen conserva su proporción original y la transparencia del PNG.
- Al seleccionar una imagen, se sube mediante `ImageUploader` al almacenamiento de imágenes y se guarda la URL con un `PATCH` parcial inmediato de `companyLogoUrl`; no requiere pulsar “Guardar Configuraciones”.
- El logo se muestra en:
  - El `AppBar` del `HomeScreen` (si no existe, se usa el nombre de la empresa como fallback).
  - El `AppBar` del `AdminPanelScreen`.
  - El hero de `MultibranchHomeScreen`.
- La resolución de la imagen en la UI usa `CompanyLogo` (`lib/widgets/design_system/company_logo.dart`), que prioriza bytes locales para la previsualización y usa `CachedNetworkImage` + `AppImageCacheManager` para la URL remota.

#### Uso Operativo del Margen de Ganancia Sugerido:
1. **Editor de Precios de Producto (`ProductPriceEditorScreen`):**
   - Si `useDefaultProfitMargin` está encendido y el producto cuenta con costo registrado (`averageCost` o `lastCost`), se renderiza una tarjeta destacada con el porcentaje configurado y el precio sugerido calculado ($\text{Costo} \times [1 + \frac{\text{Margen}}{100}]$).
   - Al pulsar el botón **"Usar Precio Sugerido"**, `SuggestedPriceCard` aplica el valor al primer nivel mediante `PriceLevelSyncController.applySuggestedBasePrice`, actualizando el precio base y su equivalente por unidad extra.
2. **Creación Rápida de Producto con Datos (`CreateProductWithDataDialog`):**
   - Al tipear el costo unitario en el formulario, un `AnimatedBuilder` calcula en tiempo real el precio de venta sugerido y despliega el botón **"Usar Precio Sugerido"** para transferirlo directamente al campo `priceController`.


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
