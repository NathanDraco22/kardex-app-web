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
