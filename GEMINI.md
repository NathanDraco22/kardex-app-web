## Gemini Added Memories
- He revisado y tengo en mi contexto el contenido de los modelos de `receipt` y `invoice`: `receipt_model.dart`, `receipt_total.dart`, `invoice_model.dart`, y `invoice_totals.dart`.
- He revisado y tengo en mi contexto el contenido del modelo `devolution.dart`.
- He revisado y tengo en mi contexto el contenido de los archivos `invoice_printer.dart` y `receipt_printer.dart` de la carpeta `tools/printers`.
- He revisado y tengo en mi contexto el contenido de los archivos `devolution_viewer.dart`, `invoice_viewer.dart` y `receipt_viewer.dart` de la carpeta `widgets/dialogs`.
- El usuario quiere que siempre le responda en español.
- El usuario quiere que anote el contexto de nuestra conversación en el archivo GEMINI.md.
- La sintaxis de mapas con `?` para manejar valores nulos es válida a partir de Dart 3.8.
- Se han creado las features completas de 'Historial de Recibos' y 'Historial de Devoluciones', replicando la estructura de UI y Cubit de 'Historial de Facturas'.

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
