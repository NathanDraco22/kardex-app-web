# Índice y Arquitectura del Directorio `lib/`

Este documento explica la estructura, propósito y distribución de cada una de las carpetas y archivos dentro del directorio `lib/` de **Kardex App Front**, respetando los estándares del proyecto y la arquitectura Onion / BLoC (Cubit) modular.

---

## 📁 Raíz (`lib/`)

En el nivel superior del directorio `lib/` se encuentran la configuración inicial de la app, el inyector global de proveedores de estado y el árbol principal de rutas:

- 📄 **`main.dart`**: Punto de entrada de la aplicación Flutter. Inicializa servicios asíncronos (como almacenamiento local con Hive), carga configuraciones de la app y ejecuta el widget raíz.
- 📄 **`material_app_builder.dart`**: Configura la instancia de `MaterialApp.router` (temas, navegadores, comportamientos de scroll y atajos globales de teclado como la calculadora flotante `Ctrl + Space`).
- 📄 **`provider_container.dart`**: Contenedor global de `MultiBlocProvider` y servicios de Provider que envuelven la aplicación, suministrando cubits globales desde el nivel superior.

---

## ⚙️ `lib/config/`
**Propósito:** Contiene las configuraciones globales del sistema.

- 📄 **`app_env.dart`**: Definición de variables de entorno y URLs de servidor.
- 📄 **`app_router.dart`**: Enrutamiento declarativo centralizado de la aplicación (`GoRouter`). Registra las pantallas principales, sub-rutas y guardas de navegación.
- 📄 **`app_theme.dart`**: Definición del sistema visual de diseño (colores primarios, tipografías, estilos de botones, barras de navegación y diálogos).
- 📄 **`get_it_config.dart`**: Configuración e inyección de dependencias mediante `GetIt`.
- 📄 **`scroll_behavior.dart`**: Comportamiento personalizado de scroll para la interfaz web/móvil (drag táctil y soporte con ratón).

---

## 📌 `lib/constants/`
**Propósito:** Definiciones de valores constantes globales reutilizables.

- 📄 **`route_names.dart`**: Constantes con los nombres e identificadores de las rutas del sistema para evitar cadenas hardcodeadas al navegar.
- 📄 **`shortcut_registry.dart`**: Registro central de atajos de teclado y acciones disponibles en toda la interfaz.

---

## 🧠 `lib/cubits/`
**Propósito:** Contiene Cubits de alcance global o heredado (legacy) que gestionan estados compartidos transversalmente por toda la aplicación (como la autenticación o el modo/sucursal actual de la app).

---

## 🧱 `lib/src/`
**Propósito:** Núcleo de la arquitectura modular y la lógica de negocio.

### 🛡️ `lib/src/core/`
Servicios core y coordinadores transaccionales (gestión de borradores locales como `TransferDraftManager`, sincronización entre sucursales, etc.).

### ⚡ `lib/src/cubits/`
Gestores de estado globales o inter-módulo específicos.

### 🏛️ `lib/src/domain/`
Capa de dominio del proyecto. Contiene:
- **`models/`**: Modelos de datos DTOs fuertemente tipados (Facturas, Recibos, Devoluciones, Productos, Clientes, Roles, etc.).
- **`repositories/`**: Fuentes de verdad para los Cubits. Mapean la respuesta cruda hacia objetos fuertemente tipados y mantienen caché en memoria.
- **`query_params/`**: Clases para construir filtros y parámetros de consulta en peticiones HTTP.
- **`responses/`**: Definición de envolturas genéricas de respuestas paginadas de la API (`ListResponse`, etc.).

### 📦 `lib/src/modules/`
Módulos funcionales de la aplicación. Cada módulo encapsula su vista (`_screen.dart`), sus Cubits locales de lectura (`Read`) y escritura (`Write`), y sus diálogos o sub-componentes específicos:

1. **`activation/`**: Pantallas y diálogos de activación de licencias o sucursales.
2. **`advanced_tools/`**: Herramientas avanzadas del sistema.
3. **`change_password/`**: Cambio de contraseña de usuarios.
4. **`client_catalog/`**: Gestión y catálogo de clientes.
5. **`commercial/`**: Operaciones comerciales (órdenes de venta, facturación a clientes, proformas, cotizaciones e historial de facturas/recibos/devoluciones).
6. **`expenses/`**: Gastos operativos y pagos a proveedores.
7. **`finance/`**: Reportes financieros, cierres de caja y reporte de flujos por rangos de fecha.
8. **`home/`**: Pantalla principal y menú de navegación.
9. **`inactive/`**: Estado inactivo de cuentas o módulos.
10. **`inventory/`**: Entradas, salidas, transferencias entre sucursales, ajustes e inventario actual con soporte de borradores y conversiones.
11. **`login/`**: Autenticación e inicio de sesión.
12. **`multi_branch_home/`**: Selección y vista general multi-sucursal.
13. **`pending_accounts/`**: Cuentas por cobrar/pagar pendientes.
14. **`product_catalog/`**: Catálogo de productos, categorías, unidades de medida y precios.
15. **`settings/`**: Configuración general del sistema y administración de usuarios/roles.
16. **`shortcuts/`**: Configuración visual de accesos directos.
17. **`splash/`**: Pantalla de carga inicial.
18. **`suppliers_catalog/`**: Gestión de proveedores y días de crédito.

### 🛠️ `lib/src/tools/`
Herramientas utilitarias y complementos del sistema (impresoras PDF/Ticket `printers/`, utilidades HTTP `http_tool.dart`, formateadores de texto/números `input_formatters.dart`, exportadores a Excel/PDF, `UnitConversionTool`, y `ReactiveRepository`).

---

## 🎨 `lib/widgets/`
**Propósito:** Componentes de interfaz de usuario reutilizables globales.

- **`calculator/`**: Teclado numérico y calculadora flotante (`SpotlightCalculator` y `Numpad`).
- **`custom_listviews/`**: Componentes de listas optimizadas responsivas.
- **`dialogs/`**: Cuadros de diálogo y visores globales (`viewers/` como `InvoiceViewer`, `ReceiptViewer`, `DevolutionViewer`, `selectors/` como selección de clientes/proveedores, e `ImageViewerDialog`).
- **`dropdown/`**: Desplegables estilizados.
- **`elements/`**: Elementos atómicos UI (`ClientShortInfo`, etiquetas, indicadores).
- **`gates/`**: Guardas de renderizado declarativo por roles y permisos (`RolePermissionGate`).
- **`map/`**: Widgets para visualización de mapas y direcciones.
- **`modals/`**: Diálogos modales genéricos.
- **`pdf/`**: Plantillas PDF A4 de documentos comercializados (`SingleInvoiceTemplate`, `SingleOrderTemplate`, `SingleReceiptTemplate`, `SingleDevolutionTemplate`).
- **`row_widgets/`**: Filas compuestas reutilizables.
- **`super_widgets/`**: Widgets avanzados e interactivos (`ImageViewerWidget`, `ImageSelectorWidget`).
- **`tables/`**: Controladores y tablas interactivas de alta frecuencia.
- **`*.dart` (Archivos sueltos)**: Componentes atómicos genéricos como `DatePickerListTile`, `IncrementalTextField`, `TitleTextField`, entre otros.

---

## 🛡️ `lib/admin_panel/`
**Propósito:** Módulo administrativo independiente para supervisión global del sistema y herramientas de gestión empresarial.
