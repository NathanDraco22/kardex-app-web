# Guía Operativa para Agentes de IA (Kardex App Front)

> [!IMPORTANT]
> ### 🛑 REGLA DE ORO OBLIGATORIA
> **Antes de realizar CUALQUIER acción, análisis, refactorización o modificación de código en este proyecto, el agente DEBE leer obligatoriamente:**
> 1. 📖 [`wiki/project_index.md`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/wiki/project_index.md): Estructura global, flujo de datos y arquitectura Onion / BLoC.
> 2. 🧭 [`wiki/modules/modules_index.md`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/wiki/modules/modules_index.md): Resumen de los módulos de la aplicación.
> 3. 📂 **El archivo del módulo correspondiente** dentro de [`wiki/modules/`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/wiki/modules/) relacionado con la tarea en curso.
> 4. 🔄 [`wiki/ramas_main_vs_lite.md`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/wiki/ramas_main_vs_lite.md): regla de sincronización `main` ↔ `lite` y diferencias entre ediciones.

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
> Consultar siempre [`wiki/ramas_main_vs_lite.md`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/wiki/ramas_main_vs_lite.md).

---

## 1. Principios de Arquitectura Inquebrantables

1. **Separación Estricta de Capas:**
   - **DataSource (`lib/src/data/`):** Singleton con `HttpService`. Solo retorna `Map<String, dynamic>`. No conoce modelos de dominio.
   - **Repositorio (`lib/src/domain/repositories/`):** Mapea JSON a Modelos fuertemente tipados, gestiona caché y reactividad. Es la fuente de verdad.
   - **Cubit (`lib/src/modules/.../cubit/` o `lib/cubits/`):** Gestiona el estado de la vista y la lógica de negocio. Se comunica exclusivamente con el Repositorio (nunca directo con el DataSource ni hace peticiones HTTP).
   - **Vista (UI):** Consume el Cubit mediante `BlocBuilder` o `context.watch<TCubit>()`.
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
| **Arquitectura Global y Ciclo de Vida** | [`wiki/project_index.md`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/wiki/project_index.md) |
| **Mapa Panorámico de Módulos** | [`wiki/modules/modules_index.md`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/wiki/modules/modules_index.md) |
| **Ventas, POS y Facturación** | [`wiki/modules/commercial.md`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/wiki/modules/commercial.md) |
| **Almacén, Entradas, Salidas y Kárdex** | [`wiki/modules/inventory.md`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/wiki/modules/inventory.md) |
| **Productos, Códigos Alternativos y Categorías** | [`wiki/modules/product_catalog.md`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/wiki/modules/product_catalog.md) |
| **Cuentas por Cobrar y Abonos** | [`wiki/modules/pending_accounts.md`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/wiki/modules/pending_accounts.md) |
| **Finanzas, Arqueos y Balances** | [`wiki/modules/finance.md`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/wiki/modules/finance.md) |
| **Gastos Operativos y Proveedores** | [`wiki/modules/expenses.md`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/wiki/modules/expenses.md) |
| **Clientes y Geolocalización** | [`wiki/modules/client_catalog.md`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/wiki/modules/client_catalog.md) |
| **Proveedores de Mercancía** | [`wiki/modules/suppliers_catalog.md`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/wiki/modules/suppliers_catalog.md) |
| **Sucursales (`isCommerce`), Usuarios y Ajustes** | [`wiki/modules/settings.md`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/wiki/modules/settings.md) |
| **Navegación, Sesión y Atajos** | [`wiki/modules/home_and_navigation.md`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/wiki/modules/home_and_navigation.md) |
| **Estadísticas y Proyecciones** | [`wiki/modules/advanced_tools.md`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/wiki/modules/advanced_tools.md) |
| **Ediciones main vs lite y sincronización** | [`wiki/ramas_main_vs_lite.md`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/wiki/ramas_main_vs_lite.md) |
