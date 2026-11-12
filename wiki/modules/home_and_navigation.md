# Documentación del Módulo: Navegación, Sesión y Acceso (`home_and_navigation`)

Este documento agrupa los módulos que gestionan el ciclo de vida inicial, la autenticación, la selección de entorno multi-sucursal y los accesos rápidos de la aplicación en `kardex_app_front`.

---

## 1. Arquitectura y Módulos Incluidos

```text
lib/src/modules/
├── splash/                              # Pantalla de carga y bootstrap inicial
├── activation/                          # Activación de licencia o dispositivo
├── login/                               # Autenticación y control de credenciales
├── change_password/                     # Cambio obligatorio o voluntario de contraseña
├── home/                                # Pantalla principal y menú de navegación
├── multi_branch_home/                   # Conmutador visual de sucursales
├── shortcuts/                           # Panel interactivo de atajos de teclado
└── inactive/                            # Pantalla de bloqueo por cuenta/sucursal inactiva
```

---

## 2. Detalle de Módulos

### 2.1. Carga Inicial (`splash`)
- **Propósito:** Inicialización asíncrona de servicios (Hive, temas, comprobación de token JWT guardado en almacenamiento seguro).
- **Vistas:** `SplashScreen`.
- **Lógica de Desvío:**
  - Si no hay licencia o activación válida -> Redirige a `/activation`.
  - Si no hay sesión iniciada -> Redirige a `/login`.
  - Si el usuario o sucursal están inactivos -> Redirige a `/inactive`.
  - Si la sesión es válida y el usuario tiene múltiples sucursales asignadas -> `/multibranch-home`.
  - Si tiene una sucursal única -> `/home`.

### 2.2. Autenticación (`login` & `change_password`)
- **Propósito:** Validación de credenciales de usuario contra el backend FastAPI.
- **Vistas:** `LoginScreen`, `ChangePasswordScreen`.
- **Cubits:** `AuthCubit` (`lib/cubits/auth/auth_cubit.dart`).
- **Seguridad:**
  - Guarda tokens JWT (Access Token y Refresh Token).
  - Almacena información del usuario activo (`UserInDb`), rol y lista de sucursales autorizadas.

### 2.3. Menú Principal y Sistema de Navegación (`home`)
- **Propósito:** Hub central de navegación (Launchpad) desde donde se accede a todos los módulos operativos y se entra en modo pantalla completa.
- **Documentación Maestra:** Para la arquitectura exhaustiva, componentes (`MenuOptionCard`, `MenuSectionDivider`, `DesktopModuleSidebar`, `DesktopSubmenuPanel`), control de roles y diferencias entre `main` y `lite`, consulta:
  👉 **[Sistema de Navegación y Arquitectura Completa (`wiki/sistema_navegacion.md`)](../sistema_navegacion.md)**.
- **Vistas Responsivas:**
  - `HomeScreen`: Wrapper que selecciona `HomeDesktop` (Split Hub adaptativo de 2 columnas con búsqueda en tiempo real), `HomeTablet` o `HomeMobile` (drill-down táctil con `MenuOptionCard`).
- **Comportamiento Dinámico Comercial vs Bodega:**
  - Evalúa la propiedad `isCommerce` de la sucursal activa (`currentBranch`).
  - Si `isCommerce == false`: Excluye del menú los accesos a **Comercial** (`/commercial`) y **Cuentas por Cobrar** (`/pending-accounts`), adaptando además el icono del encabezado a un almacén (`Icons.warehouse_rounded`) en tonos neutros/pizarra.
  - Si `isCommerce == true`: Muestra el icono de tienda (`FluentIcons.building_shop_24_filled`) en tonos ámbar y habilita todas las funciones comerciales.

### 2.4. Conmutador Multi-Sucursal (`multi_branch_home`)
- **Propósito:** Permitir a usuarios con permisos en varias sucursales alternar rápidamente entre ellas con un solo clic sin tener que cerrar sesión.
- **Vistas:** `MultibranchHomeScreen`.
- **Diseño actual:**
  - Hero con el logo corporativo (`companyLogoUrl` de `app_settings`), nombre de la empresa, bienvenida al usuario y estado de la sesión.
  - Tarjetas principales para entrar al **Panel Administrativo** o a **Sucursales**.
  - Sección “Tus sucursales” con tarjetas que muestran logo/imagen, nombre, dirección y badge Comercio/Almacén. Un clic selecciona la sucursal y navega al home.
  - La tarjeta “Sucursales” abre siempre el diálogo `BranchSelectionDialog`, incluso si solo existe una sucursal. El diálogo resalta la sucursal actual y comparte el avatar `BranchAvatar` con las tarjetas de la sección “Tus sucursales”.
  - Chip de usuario y cierre de sesión con confirmación.
- **Efecto:** Actualiza el estado global de la sucursal activa en `AppModeCubit` y recarga las cachés locales de inventario y precios.

### 2.5. Panel Administrativo (`admin_panel`)
- **Propósito:** Tablero ejecutivo con las ventas del día anterior, el acumulado de los últimos 7 días y accesos rápidos a reportes, existencias globales, cambio de sucursal, catálogos y configuración.
- **Diseño:** Fondo global coherente `Colors.indigo.shade50`, hero de bienvenida con avatar y sucursal activa, tarjetas Bento blancas de métricas y gráfica de tendencia con estilo suave (sin gradientes) que contrastan de forma nítida con el fondo.
- **Componente reutilizable:** Los accesos usan `AppActionTile` (`lib/widgets/design_system/app_action_tile.dart`), un tile con icono tintado, título, subtítulo, hover sutil y chevron. Sustituye la repetición de `ListTile` + `Divider`.
- **Navegación:** “Ir a sucursal” reutiliza `BranchSelectionDialog` y resalta la sucursal actual.

### 2.6. Atajos de Teclado (`shortcuts`)
- **Propósito:** Mostrar al usuario el mapa de atajos globales configurados para agilizar la operación diaria sin ratón.
- **Vistas:** `ShortcutsMenuScreen`.
- **Atajos Globales Destacados:**
  - `Ctrl + Space`: Despliega la calculadora flotante (`SpotlightCalculator`).
  - `F1`: Búsqueda global de existencias (`GlobalStockSearchModal`).
  - `F2`: Acceso directo al Terminal de Venta.
  - `F3`: Búsqueda de clientes.
  - `Escape`: Cerrar modales o cancelar operaciones en curso.

---

## 3. Repositorios y Fuentes de Datos Involucrados

| Submódulo | DataSource | Repositorio |
| :--- | :--- | :--- |
| Autenticación | `AuthDataSource` | `AuthRepository` |
| Sucursales | `BranchesDataSource` | `BranchesRepository` |
| Almacenamiento Local | `Hive` / Flutter Secure Storage | Gestión de tokens y preferencias |

---

## 4. Rutas en `app_router.dart`

- `/splash`: Pantalla de inicio y desvío inicial.
- `/activation`: Activación de licencia.
- `/login`: Formulario de inicio de sesión.
- `/home`: Menú principal del sistema.
- `/multibranch-home`: Selector de sucursales.
- `/shortcuts`: Catálogo de atajos de teclado.
- `/inactive`: Pantalla de bloqueo.
