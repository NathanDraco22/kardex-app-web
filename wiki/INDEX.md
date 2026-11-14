# INDEX — Contexto rápido de `kardex_app_front`

Punto de entrada de la wiki del frontend. **Lee esto antes de explorar el código.** Aquí está la estructura, qué hace cada carpeta y los enlaces para profundizar solo en lo que necesites.

> Si llegaste aquí desde [`../agents.md`](../agents.md): estás en el lugar correcto. Continúa con la sección que corresponda a tu tarea.

> [!WARNING]
> **Este proyecto tiene dos ediciones: `main` y `lite`.** Antes de leer o modificar código, determina en cuál estás:
> ```powershell
> git branch --show-current
> ```
> También puedes verificar el `applicationId` en `android/app/build.gradle.kts` (`...neptuno_system` vs `...neptuno_system_lite`).
> La fuente canónica es [`ramas_main_vs_lite.md`](./ramas_main_vs_lite.md). **No asumas paridad entre ediciones.**

---

## 1. Qué es este proyecto

`kardex_app_front` es la aplicación **Flutter multiplataforma** (Web, Windows Desktop, Android Tablet/Móvil) de **Kardex App / Neptuno**. Gestiona inventario multi-sucursal, POS y facturación, compras, cuentas por cobrar, tesorería, gastos y reportes. Consume la API REST de `kardex-server`.

La arquitectura es **Onion + BLoC/Cubit**: la UI consume cubits, los cubits consumen repositorios, los repositorios consumen data sources y estos hacen las peticiones HTTP. La capa de datos y dominio vive en el paquete local `packages/kardex_business`.

| Dato | Valor |
| :--- | :--- |
| SDK | Dart `^3.12.0`, Flutter `>=3.44.0` |
| Entrada | `lib/main.dart` → `MaterialApp.router` |
| Estado | `flutter_bloc` (Cubit) |
| Navegación | `go_router` (`lib/config/app_router.dart`) |
| Persistencia local | Hive (`sessionBox`, `config_box`, caché HTTP) |
| Paquete de dominio | `packages/kardex_business` |
| Ediciones | `main` (Estándar) y `lite` (Ligera) — ver [`ramas_main_vs_lite.md`](./ramas_main_vs_lite.md) |
| Plataformas | `web/`, `windows/`, `android/` |

> Verifica siempre la rama activa con `git branch --show-current`. El repo tiene dos ediciones con reglas de negocio distintas.

---

## 2. Edición activa (`main` vs `lite`)

| Aspecto | `main` | `lite` |
| :--- | :--- | :--- |
| Módulos raíz | 10 | 8 |
| Productos | Módulo raíz propio | Integrado en Inventario |
| Catálogo de inventario | `product-price-catalog` | `product-inventory-catalog` |
| Movimientos de Producto | Expuesto | No expuesto |
| Herramientas Avanzadas | Expuesto | No expuesto |
| Ajustes, Mermas y Solicitudes | Activos | **Activos** |
| `applicationId` | `...neptuno_system` | `...neptuno_system_lite` |

> **Implementado ≠ registrado en el router ≠ expuesto en el Home.** En `lite` hay rutas comentadas y una ruta activa que no aparece en `home_modules_registry.dart`. Verifica el contexto antes de concluir que una pantalla está disponible.
>
> Tabla completa, método de verificación y checklist de cierre: [`ramas_main_vs_lite.md`](./ramas_main_vs_lite.md).

---

## 3. Mapa de un vistazo

| Carpeta | Qué hace |
| :--- | :--- |
| `lib/main.dart` | Bootstrap: Hive, `initializeDateFormatting`, `initServices`, `runApp`. |
| `lib/provider_container.dart` | Crea data sources, repositorios y `MultiBlocProvider` global. |
| `lib/material_app_builder.dart` | `MaterialApp.router`, atajos globales y overlays. |
| `lib/config/` | `app_env.dart` (URLs), `app_router.dart` (rutas y guards), `app_theme.dart` (tema), `get_it_config.dart` (DI), `scroll_behavior.dart`. |
| `lib/constants/` | `route_names.dart`, `shortcut_registry.dart`, `feature_flags.dart`. |
| `lib/cubits/` | Cubits globales: `auth`, `app_mode`, `app_settings`, `near_expiration`, `shortcuts`, `toast`. |
| `lib/src/core/` | `access_manager`, `session_manager`, `app_config_manager`, `app_kardex_config`, gestores de borradores. |
| `lib/src/modules/` | Módulos funcionales (19): cada uno con sus vistas, cubits locales y widgets. |
| `lib/src/services/` | Servicio de impresión térmica. |
| `lib/src/tools/` | Utilidades: extensiones responsive, formateadores, exportadores, impresoras, `ReactiveRepository`, etc. |
| `lib/widgets/` | Componentes globales reutilizables: `design_system/`, `dialogs/`, `gates/`, `pdf/`, `tables/`, `dropdown/`, etc. |
| `lib/admin_panel/` | Módulo administrativo para supervisión global. |
| `packages/kardex_business/lib/src/data/` | Data sources HTTP (`*_data_source.dart`). |
| `.../domain/models/` | Modelos y DTOs (`fromJson`, `toJson`, `copyWith`). |
| `.../domain/repositories/` | Repositorios: caché, mapeo y reactividad. |
| `.../domain/query_params/` | Filtros y parámetros de consulta tipados. |
| `.../domain/responses/` | Envoltorios de respuesta (`ListResponse`, etc.). |
| `.../services/` | `http_service.dart`, `dio_http_service.dart`. |
| `.../tools/` | `TokenManager`, `ReactiveRepository` y utilidades del paquete. |
| `test/` | Suite de tests (`flutter test`). |
| `scripts/` | Compilación y despliegue (web, Android, edición lite). |
| `assets/` | Fondos, fuentes y animaciones. |
| `wiki/` | Esta documentación. |
| `docs/` | Notas de diferencias lite/main, segmentación de vistas y atajos. |

> Las filas con `.../` continúan la ruta `packages/kardex_business/lib/src/`.

---

## 4. Dónde está cada cosa

| Si buscas… | Ve a… |
| :--- | :--- |
| Una petición HTTP | `packages/kardex_business/lib/src/data/<entidad>_data_source.dart` |
| El mapeo JSON → modelo | `packages/kardex_business/lib/src/domain/repositories/<entidad>_repository.dart` |
| Un modelo o DTO | `packages/kardex_business/lib/src/domain/models/<entidad>/` |
| Filtros de búsqueda | `packages/kardex_business/lib/src/domain/query_params/` |
| Un cubit de pantalla | `lib/src/modules/<modulo>/<vista>/cubit/` |
| Un cubit global | `lib/cubits/<nombre>/` |
| Una pantalla | `lib/src/modules/<modulo>/.../<nombre>_screen.dart` |
| Un widget reutilizable | `lib/widgets/` |
| Tokens y tema | `lib/config/app_theme.dart` y `lib/widgets/design_system/app_theme_tokens.dart` |
| Rutas y guards | `lib/config/app_router.dart` + `lib/constants/route_names.dart` |
| Inyección de dependencias | `lib/config/get_it_config.dart` y `lib/provider_container.dart` |
| Permisos y roles | `lib/src/core/access_manager.dart` y `lib/widgets/gates/role_permission_gate.dart` |
| Sesión y token | `lib/src/core/session_manager.dart` + `packages/.../tools/token_manager.dart` |
| Impresión térmica | `lib/src/services/thermal_printer_service.dart` y `lib/src/tools/printers/` |
| Plantillas PDF | `lib/widgets/pdf/` |
| Borradores de transferencia/terminal | `lib/src/core/transfer_draft_manager.dart`, `terminal_draft_manager.dart` |
| Feature flags | `lib/constants/feature_flags.dart` |
| URLs del backend | `lib/config/app_env.dart` y `secrets.json` (`--dart-define-from-file`) |
| Tests | `test/` |
| Documentación de módulos | [`modules/modules_index.md`](./modules/modules_index.md) |

---

## 5. Catálogo de enlaces

### 🧭 Para empezar

| Enlace | Qué encontrarás |
| :--- | :--- |
| [`../agents.md`](../agents.md) | Regla de oro, capas, sincronización `main` ↔ `lite` y mapa de documentación. **Obligatorio.** |
| [`project_index.md`](./project_index.md) | Arquitectura Onion/BLoC, ciclo de vida, árbol y flujo global. |
| [`modules/modules_index.md`](./modules/modules_index.md) | Catálogo de los módulos funcionales y su rol de negocio. |

### 🏗️ Arquitectura y convenciones

| Enlace | Qué encontrarás |
| :--- | :--- |
| [`conventions.md`](./conventions.md) | Capas, naming, modelos, reactividad, reglas de UI, atajos, lints y tests. |
| [`security.md`](./security.md) | Autenticación, sesión, permisos (`AccessManager`, `RolePermissionGate`), guards de router y `isCommerce`. |
| [`operations.md`](./operations.md) | `flutter pub get`, ejecución con `secrets.json`, defines, analyze/test, builds y problemas comunes. |
| [`../agents.md`](../agents.md) | Reglas de arquitectura y sincronización de ramas. |

### 🎨 Diseño, navegación e impresión

| Enlace | Qué encontrarás |
| :--- | :--- |
| [`diseno_e_identidad_visual.md`](./diseno_e_identidad_visual.md) | Paleta, fondos, tarjetas Bento, reglas de filtros móviles y checklist visual. |
| [`sistema_navegacion.md`](./sistema_navegacion.md) | Split Hub (Desktop), Drill-Down (Mobile), breakpoints y matriz de rutas `main` vs `lite`. |
| [`sistema_impresion_termica.md`](./sistema_impresion_termica.md) | Impresión Bluetooth/USB, ESC/POS, rasterización y post-mortems. |
| [`ramas_main_vs_lite.md`](./ramas_main_vs_lite.md) | Por qué existe `lite` y en qué difiere el modelo operativo. |

### 🗂️ Módulos funcionales

| Enlace | Qué encontrarás |
| :--- | :--- |
| [`modules/commercial.md`](./modules/commercial.md) | POS, facturas, recibos, proformas, devoluciones y arqueo. |
| [`modules/credit_notes.md`](./modules/credit_notes.md) | Notas de crédito, repositorio reactivo y amortización en recibos. |
| [`modules/inventory.md`](./modules/inventory.md) | Stock, entradas/salidas, transferencias, ajustes y solicitudes. |
| [`modules/product_catalog.md`](./modules/product_catalog.md) | Productos, códigos alternativos, categorías, unidades y precios. |
| [`modules/unit_scales.md`](./modules/unit_scales.md) | Escalas de conversión y presets. |
| [`modules/pending_accounts.md`](./modules/pending_accounts.md) | Cuentas por cobrar y abonos. |
| [`modules/finance.md`](./modules/finance.md) | Cierres, arqueos y reportes. |
| [`modules/expenses.md`](./modules/expenses.md) | Gastos operativos y proveedores. |
| [`modules/client_catalog.md`](./modules/client_catalog.md) | Clientes, límites de crédito y mapa. |
| [`modules/suppliers_catalog.md`](./modules/suppliers_catalog.md) | Proveedores y condiciones de compra. |
| [`modules/settings.md`](./modules/settings.md) | Sucursales, usuarios, roles, API keys, periféricos y precios. |
| [`modules/imports.md`](./modules/imports.md) | Importaciones CSV con vista previa. |
| [`modules/home_and_navigation.md`](./modules/home_and_navigation.md) | Login, multi-sucursal, home y atajos. |
| [`modules/advanced_tools.md`](./modules/advanced_tools.md) | Estadísticas y proyecciones. |

### 📋 Documentos de trabajo (fuera de la wiki)

| Enlace | Qué encontrarás |
| :--- | :--- |
| [`../GEMINI.md`](../GEMINI.md) | Bitácora cronológica de cambios. |
| [`../docs/`](../docs/) | Notas de `docs/`: diferencias lite/main, segmentación de vistas y atajos. |
| [`../DIRECTORY_INDEX.md`](../DIRECTORY_INDEX.md) | Árbol detallado de `lib/` (documento heredado; verifica contra el código). |

---

## 6. Rutas rápidas por tarea

| Tarea | Edición | Archivos a abrir |
| :--- | :--- | :--- |
| POS / venta rápida | Ambas | `lib/src/modules/commercial/sale_terminal/`, [`modules/commercial.md`](./modules/commercial.md) |
| Facturación / proformas | Ambas | `lib/src/modules/commercial/client_invoices/`, `proforma/`, `current_proforma/` |
| Notas de crédito | Ambas | `lib/src/modules/commercial/credit_notes/`, [`modules/credit_notes.md`](./modules/credit_notes.md) |
| Cobros / recibos | Ambas | `lib/src/modules/commercial/receipt_history/`, `lib/src/modules/pending_accounts/` |
| Devoluciones | Ambas | `lib/src/modules/commercial/devolutions/`, `current_devolutions/` |
| Inventario / kárdex | Ambas (comportamiento distinto) | `lib/src/modules/inventory/`, [`modules/inventory.md`](./modules/inventory.md), [`ramas_main_vs_lite.md`](./ramas_main_vs_lite.md) |
| Catálogo de inventario | `lite` | `lib/src/modules/inventory/product_inventory_catalog/` |
| Catálogo de precios | `main` | `lib/src/modules/inventory/product_price_catalog/` |
| Ajustes y solicitudes | Ambas | `lib/src/modules/inventory/adjustment_request/`, `adjust_entry/`, `adjust_exit/` |
| Transferencias | Ambas | `lib/src/modules/inventory/create_transfer/`, `current_tranfers/` |
| Productos y precios | Ambas (raíz en `main`, dentro de Inventario en `lite`) | `lib/src/modules/product_catalog/`, `lib/src/modules/inventory/product_inventory_catalog/`, [`modules/product_catalog.md`](./modules/product_catalog.md) |
| Clientes | Ambas | `lib/src/modules/client_catalog/`, [`modules/client_catalog.md`](./modules/client_catalog.md) |
| Proveedores | Ambas | `lib/src/modules/suppliers_catalog/`, [`modules/suppliers_catalog.md`](./modules/suppliers_catalog.md) |
| Gastos | Ambas | `lib/src/modules/expenses/`, [`modules/expenses.md`](./modules/expenses.md) |
| Finanzas / reportes | Ambas | `lib/src/modules/finance/`, [`modules/finance.md`](./modules/finance.md) |
| Importaciones CSV | Ambas | `lib/src/modules/imports/`, [`modules/imports.md`](./modules/imports.md) |
| Configuración / roles | Ambas | `lib/src/modules/settings/`, [`modules/settings.md`](./modules/settings.md) |
| Home / navegación / atajos | Ambas (menú distinto) | `lib/src/modules/home/`, [`sistema_navegacion.md`](./sistema_navegacion.md) |
| Estadísticas / proyecciones | `main` | `lib/src/modules/advanced_tools/`, [`modules/advanced_tools.md`](./modules/advanced_tools.md) |
| Estilos y fondos | Ambas | [`diseno_e_identidad_visual.md`](./diseno_e_identidad_visual.md), `lib/config/app_theme.dart` |
| Impresión / PDF | Ambas | [`sistema_impresion_termica.md`](./sistema_impresion_termica.md), `lib/src/tools/printers/`, `lib/widgets/pdf/` |

---

## 7. Observaciones conocidas

| Observación | Impacto |
| :--- | :--- |
| `lib/src/data/` **no existe** y `lib/src/domain/` está vacío. | La capa de datos/dominio vive en `packages/kardex_business/lib/src/`. Los documentos que digan lo contrario están desactualizados. |
| `agents.md` y `project_index.md` mencionan rutas antiguas (`lib/src/data/`, `lib/src/services/http_service.dart`). | Se corrigieron en esta actualización; si ves otra referencia, prioriza el código. |
| `DIRECTORY_INDEX.md` (raíz) está desactualizado: no incluye todos los módulos ni los widgets nuevos. | Úsalo como pista, no como fuente de verdad. El mapa de este INDEX es el vigente. |
| El repo tiene dos ediciones (`main` y `lite`) con módulos y menús distintos. | Verifica la rama antes de tocar código y evalúa el impacto en la otra edición. Tabla verificada en [`ramas_main_vs_lite.md`](./ramas_main_vs_lite.md). |
| En `lite`, `product-movements`, `product-price-catalog` y `/advanced-tools` están **comentadas** en el router; `commercial-product-movements` está registrada pero **no expuesta** en el Home. | No asumas que una ruta existe por encontrarla con `grep`; revisa el bloque de comentario y el `home_modules_registry.dart`. |
| La documentación anterior decía que `lite` no incluía Ajustes, Mermas ni Solicitudes de Ajuste. | Desde 2026-11-13 están activos en `lite`; la matriz de [`sistema_navegacion.md`](./sistema_navegacion.md) fue corregida. |
| `secrets.json`, `secrets_dev.json`, `secrets_prod.json` contienen defines de entorno. | No los commitees con credenciales reales ni los compartas. |
| `scripts/compile_web.py` incluye un token de Netlify embebido. | Trátalo como secreto; no lo reproduzcas en documentación pública. |

---

## 8. Cómo mantener esta wiki

1. **Módulo nuevo:** agrégalo a [`modules/modules_index.md`](./modules/modules_index.md) y crea su ficha si el flujo es complejo.
2. **Cambio de arquitectura o convención:** actualiza [`conventions.md`](./conventions.md) o [`project_index.md`](./project_index.md).
3. **Cambio de permisos o sesión:** actualiza [`security.md`](./security.md).
4. **Cambio de build, defines o scripts:** actualiza [`operations.md`](./operations.md).
5. **No dupliques contenido:** este INDEX enlaza; el detalle vive en el documento de su tema.
