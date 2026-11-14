# Guía Operativa para Agentes de IA (Kardex App Front)

> [!IMPORTANT]
> ### 🛑 REGLA DE ORO OBLIGATORIA
> **Antes de realizar CUALQUIER acción, análisis, refactorización o modificación de código en este proyecto, el agente DEBE:**
> 0. **Determinar la edición activa** con `git branch --show-current` (`main` o `lite`). No asumas paridad entre ediciones. Ver [`wiki/ramas_main_vs_lite.md`](wiki/ramas_main_vs_lite.md).
> 1. 📖 [`wiki/INDEX.md`](wiki/INDEX.md): contexto rápido — estructura, dónde está cada cosa, qué hace y catálogo de enlaces.
> 2. 🏗️ [`wiki/project_index.md`](wiki/project_index.md): arquitectura Onion / BLoC y ciclo de vida.
> 3. 🗂️ [`wiki/modules/modules_index.md`](wiki/modules/modules_index.md): catálogo de módulos de la aplicación.
> 4. 📂 **La ficha del módulo correspondiente** dentro de [`wiki/modules/`](wiki/modules/) si existe.
> 5. 🧱 [`wiki/conventions.md`](wiki/conventions.md), 🔐 [`wiki/security.md`](wiki/security.md) y ⚙️ [`wiki/operations.md`](wiki/operations.md) según la tarea.
>
> **No explores el árbol a ciegas.** Si un módulo no tiene ficha, usa `modules_index.md` para ubicar su carpeta en `lib/src/modules/` y sigue el flujo vista → cubit → repositorio.

> [!WARNING]
> **Implementado ≠ registrado ≠ expuesto.** Que exista un archivo o una ruta en `app_router.dart` no significa que la pantalla esté disponible. Revisa si la ruta está dentro de un bloque `/* ... */` y confirma en `lib/src/modules/home/data/home_modules_registry.dart`. En `lite` hay rutas comentadas y una ruta activa que no está en el Home (`commercial-product-movements`).

> [!IMPORTANT]
> ### 🔄 REGLA DE SINCRONIZACIÓN `main` ↔ `lite`
> **Todo cambio que se haga en `main` debe evaluarse explícitamente para `lite` antes de considerarse terminado.** No se asume que `lite` lo heredará solo por existir en `main`.
>
> Al cerrar una tarea:
> 1. ¿El cambio aplica a la operación de `lite`?
> 2. Si aplica y es **código compartido** (modelos, data sources, repositories, `kardex_business`, widgets comunes), entra por `main` y luego se sincroniza con `git merge main` en `lite`.
> 3. Si aplica pero es **UI/arquitectura exclusiva de `lite`** (editor combinado, catálogo de inventario, cubits directos), se implementa en `lite`.
> 4. Si no aplica, se deja constancia del motivo en la tarea/PR.
> 5. Nunca se mergea `lite` completo hacia `main`.
> 6. **Ajustes y Mermas y Solicitudes de Ajuste:** activos en `lite`; se sincronizan desde `main` con el flujo estándar. **Movimientos de un Producto:** no habilitar en `lite`.
>
> **Checklist de cierre por edición:**
> - [ ] ¿Identifiqué la edición activa?
> - [ ] ¿El cambio aplica a la otra edición (sí / no / parcial)?
> - [ ] Si es compartido, ¿entra por `main` y se sincroniza a `lite`?
> - [ ] Si es lite-only, ¿se documentó el motivo?
> - [ ] Si no aplica, ¿quedó constancia?
> - [ ] ¿La ruta nueva está registrada **y** expuesta en `home_modules_registry.dart`?
>
> Consultar siempre [`wiki/ramas_main_vs_lite.md`](wiki/ramas_main_vs_lite.md).

---

## 1. Principios de Arquitectura Inquebrantables

1. **Separación Estricta de Capas:**
   - **DataSource (`packages/kardex_business/lib/src/data/`):** Clase con `with HttpService`. Solo retorna `Map<String, dynamic>`. No conoce modelos de dominio.
   - **Repositorio (`packages/kardex_business/lib/src/domain/repositories/`):** Mapea JSON a Modelos fuertemente tipados, gestiona caché y reactividad. Es la fuente de verdad.
   - **Cubit (`lib/src/modules/.../cubit/` o `lib/cubits/`):** Gestiona el estado de la vista y la lógica de negocio. Se comunica exclusivamente con el Repositorio (nunca directo con el DataSource ni hace peticiones HTTP).
   - **Vista (UI):** Consume el Cubit mediante `BlocBuilder` o `context.watch<TCubit>()`.
   - **Nota:** `lib/src/domain/` está vacío y `lib/src/data/` no existe; la capa de datos/dominio vive en `packages/kardex_business`.
2. **Convenciones de Nombrado:**
   - DataSources: `<nombre>_data_source.dart` (clase `<Nombre>DataSource`).
   - Repositorios: `<nombre>_repository.dart` (clase `<Nombre>Repository`).
   - Cubits: `<nombre>_cubit.dart` y `<nombre>_state.dart`.
   - Vistas: `<nombre>_screen.dart` (o divididas por plataforma en carpetas `web/`, `mobile/`, `tablet/`, `desktop/`).
3. **Validación de Tipos y Linters:**
   - Todo cambio debe ser verificado ejecutando `flutter analyze` o `dart analyze`.
   - No introducir errores de lint ni suprimir advertencias sin justificación arquitectónica.

---

## 2. Mapa Rápido a la Documentación Técnica (`wiki/`)

| Área | Documento de Consulta |
| :--- | :--- |
| **Contexto rápido / estructura / enlaces** | [`wiki/INDEX.md`](wiki/INDEX.md) |
| **Arquitectura Global y Ciclo de Vida** | [`wiki/project_index.md`](wiki/project_index.md) |
| **Convenciones de código y UI** | [`wiki/conventions.md`](wiki/conventions.md) |
| **Seguridad, sesión y permisos** | [`wiki/security.md`](wiki/security.md) |
| **Operación, defines y builds** | [`wiki/operations.md`](wiki/operations.md) |
| **Mapa Panorámico de Módulos** | [`wiki/modules/modules_index.md`](wiki/modules/modules_index.md) |
| **Ventas, POS y Facturación** | [`wiki/modules/commercial.md`](wiki/modules/commercial.md) |
| **Notas de Crédito** | [`wiki/modules/credit_notes.md`](wiki/modules/credit_notes.md) |
| **Almacén, Entradas, Salidas y Kárdex** | [`wiki/modules/inventory.md`](wiki/modules/inventory.md) |
| **Productos, Códigos Alternativos y Categorías** | [`wiki/modules/product_catalog.md`](wiki/modules/product_catalog.md) |
| **Escalas de Unidades** | [`wiki/modules/unit_scales.md`](wiki/modules/unit_scales.md) |
| **Cuentas por Cobrar y Abonos** | [`wiki/modules/pending_accounts.md`](wiki/modules/pending_accounts.md) |
| **Finanzas, Arqueos y Balances** | [`wiki/modules/finance.md`](wiki/modules/finance.md) |
| **Gastos Operativos y Proveedores** | [`wiki/modules/expenses.md`](wiki/modules/expenses.md) |
| **Clientes y Geolocalización** | [`wiki/modules/client_catalog.md`](wiki/modules/client_catalog.md) |
| **Proveedores de Mercancía** | [`wiki/modules/suppliers_catalog.md`](wiki/modules/suppliers_catalog.md) |
| **Sucursales (`isCommerce`), Usuarios y Ajustes** | [`wiki/modules/settings.md`](wiki/modules/settings.md) |
| **Importaciones CSV** | [`wiki/modules/imports.md`](wiki/modules/imports.md) |
| **Navegación, Sesión y Atajos** | [`wiki/modules/home_and_navigation.md`](wiki/modules/home_and_navigation.md) |
| **Estadísticas y Proyecciones** | [`wiki/modules/advanced_tools.md`](wiki/modules/advanced_tools.md) |
| **Identidad visual y estilos** | [`wiki/diseno_e_identidad_visual.md`](wiki/diseno_e_identidad_visual.md) |
| **Navegación y arquitectura de rutas** | [`wiki/sistema_navegacion.md`](wiki/sistema_navegacion.md) |
| **Impresión térmica** | [`wiki/sistema_impresion_termica.md`](wiki/sistema_impresion_termica.md) |
| **Ediciones main vs lite y sincronización** | [`wiki/ramas_main_vs_lite.md`](wiki/ramas_main_vs_lite.md) |
