## Gemini Added Memories
- He revisado y tengo en mi contexto el contenido de los modelos de `receipt` y `invoice`: `receipt_model.dart`, `receipt_total.dart`, `invoice_model.dart`, y `invoice_totals.dart`.
- He revisado y tengo en mi contexto el contenido del modelo `devolution.dart`.
- He revisado y tengo en mi contexto el contenido de los archivos `invoice_printer.dart` y `receipt_printer.dart` de la carpeta `tools/printers`.
- He revisado y tengo en mi contexto el contenido de los archivos `devolution_viewer.dart`, `_viewer.dart` y `receipt_viewer.dart` de la carpeta `widgets/dialogs`.
- El usuario quiere que siempre le responda en español.
- El usuario quiere que anote el contexto de nuestra conversación en el archivo GEMINI.md.
- Se han creado las features completas de 'Historial de Recibos' y 'Historial de Devoluciones', replicando la estructura de UI y Cubit de 'Historial de Facturas'.
- Se ha rediseñado la cabecera en `single_invoice_template.dart` para incluir de forma limpia y estética la información completa de la sucursal (logo, dirección, teléfono, email).
- Se han creado las plantillas PDF en tamaño de hoja normal (A4) para Pedidos (`single_order_template.dart`), Recibos de pago (`single_receipt_template.dart`) y Devoluciones (`single_devolution_template.dart`), compartiendo la misma estructura de cabecera premium y datos de la sucursal.
- Se integraron los botones "Exportar PDF (A4)" en los visores de Pedidos (`order_viewer.dart`), Recibos (`receipt_viewer.dart`) y Devoluciones (`devolution_viewer.dart`) para garantizar paridad de funciones en la exportación de documentos con respecto a las Facturas.
- Se realizaron ajustes de diseño en los 4 templates PDF A4 (`single_invoice_template.dart`, `single_order_template.dart`, `single_receipt_template.dart` y `single_devolution_template.dart`) para:
  - Eliminar el prefijo textual `"Fecha: "` de la cabecera superior derecha, dejando solo el valor de fecha y hora.
- Se ha implementado un botón de ordenamiento alfabético toggle (A-Z / Z-A) en las pantallas de creación de factura para Pedidos (`current_orders/invoice_creator_screen.dart`) y Proformas (`current_proforma/invoice_creator_screen.dart`).
- Dicho botón ordena visualmente los items al instante mediante `setState` de forma local (evitando llamar al servidor por ahora).
- Se sincronizó esta ordenación en el `OrderContainer` mutable expuesto por el `InvoiceCreateMediator` en ambos módulos, lo cual garantiza que las operaciones que leen de la cabecera (como "Imprimir", "Compartir" o modales de confirmación de facturación/cancelación) tengan acceso inmediato a la lista ordenada.
- Se implementó el mismo botón de ordenamiento alfabético toggle (A-Z / Z-A) en la tabla de facturación a clientes (`client_invoice_table.dart`) al lado de la columna "Producto". Ordena localmente a través de `ClientInvoiceViewController` y se limpia su estado visual (`_isAscending = null`) al detectar cambios externos por parte del usuario (adiciones, ediciones, remociones).
- Se realizó la migración del control de acceso basado en constantes de tipo String (`lib/constants/const_modules.dart`) hacia enums fuertemente tipados (`Modules` y `CommercialSubModules`) en `lib/src/domain/models/user_role/modules.dart`.
- Se introdujo el widget `RolePermissionGate` en `lib/widgets/gates/role_permission_gate.dart` para manejar de forma declarativa el control de acceso visual (whitelist/blacklist) en la UI de Flutter, integrándose con `AccessManager` de forma limpia.
- Se refactorizaron múltiples pantallas del sistema (`HomeScreen`, menús principales de finanzas, inventario, comercio, configuración, clientes y proveedores) para emplear esta nueva infraestructura declarativa basada en Enums y `.name` en lugar de strings sueltos.








## Arquitectura de Módulos
La arquitectura de un módulo en este proyecto Flutter incluye:
1.  **Vista (UI):** `lib/src/modules/<nombre_del_modulo>/<nombre_del_modulo>_screen.dart`.
2.  **Cubit (Lógica y Estado):** `lib/src/cubits/<nombre_del_modulo>/` con `_cubit.dart` y `_state.dart`.
3.  **Fuente de Datos (Data Source):** `lib/src/data/<nombre_del_modulo>_data_source.dart`.
4.  **Modelos:** `lib/src/domain/models/`.
5.  **Navegación:** Registro en `lib/config/app_router.dart`.
Esta estructura se ha seguido para módulos como 'Historial de Facturas', 'Historial de Recibos' y 'Historial de Devoluciones'.

- He revisado y aprendido de `lib/widgets/tables/inventory_movement_product_table.dart`. Es una tabla interactiva para movimientos de inventario que usa `ProductTableController` (ChangeNotifier) y `InheritedNotifier` para el estado. Soporta agregar, editar (cantidad/costo) y eliminar filas (`ProductRow`). Usa `NotificationListener` para eventos personalizados.

## Módulo de Unidades
- **Data & Repository**: Sigue la arquitectura estándar. `UnitsDataSource` maneja el CRUD y `UnitsRepository` gestiona el estado local y el mapeo a modelos.
- **Modelos**: `CreateUnit`, `UpdateUnit` y `UnitInDb`. Existe paridad total con el backend FastAPI.
- **Sincronización Backend**: Los endpoints de FastAPI (`POST`, `GET`, `PATCH`, `DELETE` en `/units`) están correctamente mapeados en el frontend.
- **UI & Lógica**: El módulo se encuentra en `lib/src/modules/product_catalog/units/` con sus respectivos Cubits para lectura (`ReadUnitCubit`) y escritura (`WriteUnitCubit`).

## Learnings from Adjust Entries (Dec 2025)
- **Product Search**: Use `showSearchProductInBranchDialog` (renamed from Commercial) for searching products within a branch context.
- **Adjust Entries Cost**: For inventory adjustments (`AdjustEntry`), the cost is **not editable** (`editableCost: false`) and defaults to `product.account.averageCost`.
- **Cost Display**: Non-editable costs in tables/lists should be formatted as `(value / 100).toStringAsFixed(2)` instead of showing "--".
- **UserInfo**: When creating entries, prefer explicit construction of `UserInfo(id: user.id, name: user.name)` over passing the Auth User object directly.
- **Confirmation**: Use `DialogManager.slideToConfirmActionDialog` for critical save actions.

## Widgets Genéricos
- Se han creado widgets atómicos en `lib/widgets/elements/` para ser reutilizados en componentes más grandes.
- `ClientShortInfo`: Muestra ID, Nombre, Cédula, Ubicación y Dirección de un cliente con iconos y estilos estandarizados.
- Se ha refactorizado `ClientListTile` y `ClientsTable` para utilizar `ClientShortInfo`, asegurando consistencia visual y eliminando código duplicado.
- `ClientListTile` en `lib/widgets/client_list_tile.dart` usa una estructura basada en `Row` e `InkWell` para mayor flexibilidad. Soporta un `backgroundColor` personalizado.
## Catálogo de Clientes
- **Límite de Crédito**: Se ha habilitado la visualización y edición del campo `creditLimit`.
  - En `client_full_details_dialog.dart`, se muestra el límite formateado como moneda (`C\$`).
  - En `create_client_dialog.dart`, se ha añadido un campo de entrada numérica que se activa solo si "Crédito Activo" está habilitado.
  - El valor se almacena como `int` (multiplicado por 100) para manejar decimales de forma consistente con otros campos financieros del proyecto.

## Historial de Facturas por Producto (Mayo 2026)
- **Endpoint**: Se añadió soporte en el frontend para el endpoint del servidor `/invoices/byProduct/{product_id}` con query parameters `InvoiceQueryParams`.
- **Capa de Datos**: Modificado `InvoicesDataSource` agregando `getInvoicesByProduct`.
- **Capa de Dominio**: Modificado `InvoicesRepository` agregando `getInvoicesByProduct` retornando `ListResponse<InvoiceInDb>`.
- **Capa de Lógica**: Creado el cubit `ReadInvoiceByProductCubit` (`read_invoice_by_product_cubit.dart` y `read_invoice_by_product_state.dart`) para cargar paginadamente las facturas asociadas a un producto.
- **Módulo UI**: Creado el módulo `Buscar facturas por producto` en `lib/src/modules/commercial/invoice_by_product/` compuesto por `invoice_by_product_screen.dart`, `invoice_by_product_web_screen.dart` y sus subsecciones (`header_section.dart` y `content_section.dart`).
- **Navegación y Menú**: Registrada la ruta `invoices-by-product` en `app_router.dart` y agregada la opción en el menú principal de comercio en `commercial_menu_screen.dart`.

## Onion CLI Helper
- La herramienta `onion` CLI ya está correctamente instalada y disponible en el `PATH` global del sistema.
- Se puede ejecutar directamente en cualquier terminal escribiendo:
  `onion --help`
- Si en algún momento deja de funcionar de forma global, se puede recurrir a su ruta absoluta del entorno virtual:
  `C:\Users\sytru\Developer\Python\onion-cli\.venv\Scripts\onion.exe`

### Convenciones de Nombres
- Pasar siempre la entidad en **singular** (ej. `product`). La CLI genera las variaciones de PascalCase y snake_case para singular y plural de forma automática.

### Comandos Clave (Flutter / Dart)
- `onion dart <entidad>`: Genera modelo, datasource y repositorio en una sola ejecución.
- `onion flutter-module <entidad>`: Crea la carpeta del módulo Flutter con cubits, vista base, dialogs y widgets stubs.
- `onion dart-cubit <entidad>`: Genera los cubits de lectura/escritura y sus estados.
- `onion dart-model <entidad>`: Genera solo los archivos de modelo en Dart.
- `onion dart-view <entidad>`: Genera solo el StatelessWidget básico de vista.

### Comandos Clave (FastAPI / Python)
- `onion crud <entidad> --version <n>`: Genera router, controller, repos, datasource, model (stubs).
- `onion crud-mongo <entidad> --version <n>`: Genera CRUD completo integrado con persistencia MongoDB.

## Migración a Inyección de Dependencias con GetIt (Mayo 2026)
- Se realizó un refactor masivo (más de 200 archivos modificados) para integrar la inyección de dependencias utilizando `GetIt` (`get_it: ^9.2.1`).
- Se eliminaron las clases utilitarias legacy `BranchesTool` y `SessionTool`. Su funcionalidad de lectura de estado y sucursal actual se delegó directamente a las propiedades reactivas expuestas por `AuthCubit` (`currentBranchId`, `currentBranch`, etc.).
- Se reemplazaron todas las referencias contextuales de `context.read<AuthCubit>()` y `context.watch<AuthCubit>()` por el acceso global `getIt<AuthCubit>()`.
- Se adaptaron las llamadas visuales como `BlocBuilder<AuthCubit, AuthState>` para pasar el parámetro explícito `bloc: getIt<AuthCubit>()`, evitando la necesidad de un `BlocProvider<AuthCubit>` en el árbol de widgets.
- Se corrigió un posible bug en `GlobalCubitProvider` ([provider_container.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/provider_container.dart)): originalmente era un `StatelessWidget` que creaba y registraba `AuthCubit` en `getIt` en cada ejecución de `build`. Se convirtió en un `StatefulWidget` para instanciar, registrar y limpiar (`dispose/close`) el cubit de manera única y segura durante el ciclo de vida de la aplicación, previniendo crashes por registros duplicados y pérdida del estado de sesión en reconstrucciones del árbol.
- Se refactorizó [auth_cubit.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/cubits/auth/auth_cubit.dart) para eliminar duplicación de código en la inicialización de la sesión autenticada (`_initializeSession`), centralizar la actualización de la configuración de red estática (`_updateNetworkConfig`), arreglar un bug en la captura de excepciones donde `UnauthorizedException` emitía `Unauthenticated` pero no interrumpía la ejecución del método (lo que provocaba la emisión errónea de un posterior `AuthError` sobreescribiendo el estado), y aprovechar la sintaxis de desestructuración de listas de Dart 3 en llamadas concurrentes `Future.wait`.
