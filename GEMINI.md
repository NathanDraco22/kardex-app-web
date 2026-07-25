## Gemini Added Memories
- Se generó el archivo de documentación [DIRECTORY_INDEX.md](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/DIRECTORY_INDEX.md) en la raíz del proyecto, detallando el propósito, la arquitectura Onion/BLoC y la distribución de cada carpeta y subcarpeta dentro de `lib/`.
- Se realizó un análisis completo del estado del repositorio (`git status`) y de los cambios en los archivos modificados. Se verificó la implementación de `UnitConversionTool` en los módulos de inventario (entradas, salidas y transferencias) para centralizar la conversión de cantidades y costos base, confirmando que protege contra divisiones por cero. Se validó la corrección en `sale_item_row.dart` para evitar divisiones por cero (`conversionFactor > 1`) y el control de límites en `CommercialProductResult` para `extraUnits`. El análisis estático (`flutter analyze` y `dart analyze`) finalizó sin advertencias ni errores ("No issues found!").
- Se configuró el parámetro `restrictStock` (por defecto `true`) en los diálogos y modales de productos comerciales ([commercial_product_dialog.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/widgets/dialogs/search_products/commercial_product_dialog.dart), [commercial_product_modal.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/widgets/dialogs/search_products/commercial_product_modal.dart), [search_product_commercial_dialog.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/widgets/dialogs/search_products/search_product_commercial_dialog.dart) y [custom_product_commercial_search_delegate.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/widgets/dialogs/search_products/custom_product_commercial_search_delegate.dart)). Se corrigió el evento de teclado ENTER en `SearchProductCommercialDialog` para propagar de forma consistente `restrictStock: widget.restrictStock`. En modo Cotización / Proforma (`CommercialDocumentType.quote`), `restrictStock` se establece en `false`, permitiendo ingresar cantidades superiores a las existencias actuales tanto en Web como en Móvil por mouse o teclado, mientras que en Facturación normal se mantiene la restricción estricta de existencias.








- Se implementó el nuevo módulo **Reporte de Ventas y Flujos** ([FinanceRangeReportScreen](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/src/modules/finance/range_finance_report/range_finance_report_screen.dart)) que permite consultar información financiera consolidada en un rango de fechas. Utiliza el componente reutilizable [DatePickerListTile](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/widgets/date_picker_listile.dart) en duplas para la Fecha Inicio y Fin (manteniendo coherencia estética y de interacción con el historial de facturas liquidadas) y calcula ventas al contado y a crédito (con costos y utilidades), ingresos reales de caja (flujo de efectivo, tarjeta y transferencia), abonos recibidos y el estado de cuentas por cobrar (créditos liquidados vs pendientes).

- Se implementó la tercera card **Ingresos (Flujo de Caja)** en la pantalla de resumen de finanzas ([totals_summary_view.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/src/modules/finance/daily_operations_results/web/components/totals_summary_view.dart)), desglosando los montos reales ingresados clasificados por **Tarjetas**, **Transferencias**, **Facturas Contado** y **Abonos Contado** con su cantidad de movimientos y total consolidado general.
- Se actualizó el visor de recibos de pago ([receipt_viewer.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/widgets/dialogs/viewers/receipt_viewer.dart)) para mostrar el método de pago (`receipt.paymentMethod.display`) debajo del nombre de la sucursal, y si el método de pago no es Efectivo y cuenta con una referencia bancaria no vacía, visualizarla al lado con el formato `" - Ref: ${receipt.bankReference}"`, replicando el comportamiento estético del visor de facturas ([invoice_viewer.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/widgets/dialogs/viewers/invoice_viewer.dart)).
- Se integró el flujo de selección de método de pago (`showPaymentConfirmationDialog`) en la creación de facturas a clientes fijos ([client_invoices_screen.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/src/modules/commercial/client_invoices/client_invoices_screen.dart)) tanto en la versión Web como en la Móvil. Este diálogo se activa únicamente cuando se trata de una factura normal (`CommercialDocumentType.invoice`) y el tipo de pago seleccionado es al contado (`PaymentType.cash`), permitiendo al cajero registrar si el pago fue en efectivo, tarjeta o transferencia con su respectivo número de referencia.
- Se actualizó el cubit `WriteInvoiceCubit` ([write_invoice_cubit.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/src/modules/commercial/client_invoices/cubit/write_invoice_cubit.dart)) para marcar las facturas como pagadas y con monto total pagado en el backend si el método resultante es cualquier tipo que no sea crédito (`paymentType != PaymentType.credit`).
- Se agregaron los botones de Exportar PDF (A4), Compartir e Imprimir en los creadores de facturas web tanto para Proformas ([invoice_creator_screen.dart (Proformas)](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/src/modules/commercial/current_proforma/web/invoice_creator/invoice_creator_screen.dart)) como para Órdenes ([invoice_creator_screen.dart (Órdenes)](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/src/modules/commercial/current_orders/web/invoice_creator/invoice_creator_screen.dart)), integrando `SingleOrderTemplate` y `PdfExportTool` para generar el PDF A4.
- Se integraron las devoluciones en el visor de facturas a crédito ([invoice_acredit_viewer.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/widgets/dialogs/viewers/invoice_acredit_viewer.dart)). Ahora calcula correctamente el saldo restante restando las devoluciones asociadas a la factura, y añade una fila detallada de devoluciones en el desglose si su total es mayor a cero.
- Se solucionó un bug en [ReadProductCubit](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/src/modules/product_catalog/product_list/cubit/read_product_cubit.dart) al actualizar, agregar o eliminar productos mientras se visualiza un resultado de búsqueda. Se modificó el cubit para actualizar de forma segura e independiente tanto la caché en memoria como la lista visible actual (`currentState.products`), previniendo errores de rango (`RangeError`) y manteniendo la visualización de los resultados de búsqueda activos resaltando correctamente en azul los elementos modificados.
- Se investigaron las causas de incompatibilidad de `image_cropper` (`image_cropper_for_web` / `cropper.js`) en Flutter Web al ejecutarse en dispositivos iOS (Safari e iOS WebViews), identificando problemas de interceptación de gestos táctiles con CanvasKit, límites estrictos de memoria de canvas en Safari para imágenes de cámara de alta resolución, y errores de CORS (`SecurityError`) debido a políticas estrictas de blobs en WebKit. Se plantearon alternativas escritas puramente en Dart (`crop_your_image`, `crop_image` o `croppy`) como soluciones definitivas para eludir el puente HTML/JS en navegadores móviles.
- Se integró de manera global el `ImageViewerWidget` en 16 archivos críticos del sistema para desplegar previsualizaciones de imágenes de productos (en catálogo de precios, buscadores web/móvil, tarjetas de facturación móvil, diálogos de selección de cantidad/descuento comercial, y flujos de transferencias, ajustes de inventario, consulta por sucursal, edición de precios y consulta de inventario actual web/móvil), permitiendo a los usuarios tocar las miniaturas para abrirlas a pantalla completa con soporte táctil completo.
- Se implementó un visor de imágenes compuesto por un widget de previsualización (`ImageViewerWidget` en [image_viewer_widget.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/widgets/super_widgets/image_viewer_widget.dart)) y su diálogo a pantalla completa (`showImageViewerDialog` en [image_viewer_dialog.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/widgets/dialogs/viewers/image_viewer_dialog.dart)). El widget muestra la miniatura de la primera imagen con efecto hover, y si hay más de una, añade una insignia en la esquina inferior derecha (ej. `+2`). Al hacer tap, abre el diálogo a pantalla completa mostrando un carrusel de imágenes con soporte interactivo para hacer zoom con gestos táctiles (`InteractiveViewer`) y deslizar horizontalmente (`PageView`).
- Se integró la selección y carga de imágenes en el formulario de creación y edición de productos (`CreateProductDialog` en [create_product_dialog.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/src/modules/product_catalog/product_list/dialogs/create_product_dialog.dart) y [form_section.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/src/modules/product_catalog/product_list/dialogs/form_section.dart)). Se agregó el `ImageSelectorWidget` centrado en la parte superior del formulario, enlazando el flujo de estados con variables locales (`_currentImageProvider`, `_selectedImageBytes` y `_isImageDeleted`). Asimismo, se centralizó el envío del formulario en la función asíncrona transaccional `_submitForm()`, la cual realiza la subida de la imagen seleccionada mediante `ImageUploader` y actualiza la URL en el DTO de creación/actualización enviado al cubit, previniendo subidas huérfanas en caso de cancelación.
- Se diseñó e implementó un widget interactivo y premium de selección de imágenes (`ImageSelectorWidget`) en [image_selector_widget.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/widgets/super_widgets/image_selector_widget.dart) y su diálogo asociado (`showImageSelectorDialog`) en [image_selector_dialog.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/widgets/dialogs/selectors/image_selector_dialog.dart). Este diálogo integra `image_picker` e `image_cropper` configurados con un recorte cuadrado fijo de `1.0:1.0`, límites de resolución máxima de `800x800` píxeles para optimización de catálogo, y compresión forzada a formato **JPG** y calidad **80**. Se crearon las clases selladas de intenciones del usuario `NewImageIntent`, `ChangeImageIntent` y `DeleteImageIntent` para propagar el resultado del diálogo al callback `onIntent` de forma limpia y tipada, logrando una paridad completa de compatibilidad para Web y Móvil. Asimismo, se integró un botón temporal de acceso directo en el `AppBar` de `HomeScreen` (icono `image_search_outlined`) para probar interactivamente el flujo completo del diálogo y sus intenciones de salida.
- Se implementó un Buscador Calculadora interactivo estilo Spotlight de macOS en [spotlight_calculator.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/widgets/dialogs/spotlight_calculator.dart) que evalúa expresiones matemáticas en tiempo real mientras el usuario escribe, con soporte avanzado y personalizado para porcentajes comerciales (como "100 - 10%", "10 - 20%" y "(10 + 2) / 3 - 50%"). la tecla ENTER funciona de forma interactiva: si hay operaciones pendientes las calcula y actualiza el campo de texto (estilo "="), y si el campo ya muestra un resultado limpio, vuelve a presionar ENTER para copiarlo al portapapeles y cerrar el diálogo. Cuenta con soporte inteligente de análisis de comas (ej. remueve comas de miles en "15,000" y traduce comas de decimales en "15,5" a puntos) y los resultados se muestran formateados con un máximo de 2 decimales. Se resolvió un bug de doble pop al presionar Escape delegando el descarte al comportamiento nativo de rutas de Flutter.
- Se unificó la lógica del Numpad Calculator táctil en [numpad.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/widgets/calculator/numpad.dart) para heredar el mismo preprocesador de porcentajes comerciales y hacer que el botón check (`✓`) funcione interactively: calcula la expresión si hay operaciones pendientes, y retorna/cierra si la barra ya muestra un resultado limpio. Se removió el botón `=` por ser redundante, se configuró el botón `✓` a `flex: 2` para hacerlo el doble de ancho y se aumentó la tipografía general de los números y visualización para mayor legibilidad.
- Se añadió un botón de acceso directo (`IconButton` con icono `calculate_outlined`) en el `AppBar` de `HomeScreen` para permitir lanzar e interactuar con la calculadora de manera directa.
- Se implementó el atajo de teclado global `Ctrl + Space` (Control + Espacio) en [material_app_builder.dart](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/material_app_builder.dart) mediante widgets de `Shortcuts` y `Actions` combinados con la `rootNavigatorKey` de GoRouter. Esto permite llamar a la calculadora Spotlight flotante de forma global e interactiva desde cualquier pantalla de la aplicación.
- Se integró el soporte para el cuarto precio de venta (`salePrice4`) en el flujo de transferencias de inventario, actualizando el modelo `TransferItem` (constructor, `fromJson` y `toJson`) en `packages/kardex_business` y los mapeos web/móvil en el frontend.
- Se añadió la visualización de "Precio 4" en el diálogo informativo de stock del producto por sucursal (`product_in_branch_info_dialog.dart`).
- Se verificó y validó la migración completa al paquete local `kardex_business` (ubicado en `packages/kardex_business`). Tanto el análisis del paquete (`dart analyze`) como el del proyecto principal de Flutter (`flutter analyze`) se ejecutaron de manera exitosa y no reportaron ningún error ni advertencia estática ("No issues found!").
- Se movieron las constantes de `lib/constants/default_values.dart` (como `kSaleClientId` y `kOriginBranchId`) al paquete independiente `kardex_business` (dentro de `packages/kardex_business/lib/constants/default_values.dart`), eliminando el archivo local duplicado de la raíz y adaptando las importaciones en `auth_cubit.dart` de forma limpia.
- Se migró exitosamente la clase `TokenManager` (decodificación y control de expiración de tokens JWT) al subpaquete `kardex_business` (en `packages/kardex_business/lib/src/tools/token_manager.dart`), instalando la dependencia `dart_jsonwebtoken` en el paquete de lógica pura, eliminando el archivo duplicado del frontend y limpiando las importaciones correspondientes en `auth_cubit.dart` y `app_kardex_config.dart`.
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
- Se actualizó el formulario de creación y edición de proveedores (`create_supplier_dialog.dart`) para incluir el campo `creditDays` (Días de Crédito), validándolo y formateándolo mediante `IntegerTextInputFormatter` para permitir únicamente valores numéricos.
- Se actualizó la guía `agents.md` agregando una directriz que instruye a los agentes a verificar la disponibilidad de formateadores de entrada predefinidos en `input_formatters.dart` antes de crear nuevos campos de entrada numéricos o decimales.
- Se creó el componente `supplier_selection_dialog.dart` en `lib/widgets/dialogs/selectors/`, el cual funciona similar al selector de clientes, permitiendo buscar y seleccionar proveedores mediante `SuppliersRepository`.
- Se integró el endpoint POST `/products/branch/{branch_id}/by-ids` en el frontend, agregando la nueva entidad de petición `GetProductsInBranchRequest` en `product_model.dart`, el método correspondiente en `ProductsDataSource` y la llamada tipada en `ProductsRepository`.
- Se implementó la persistencia de borradores para la creación de transferencias utilizando `HiveService` en la box `transferDraftBox` a través de la clase [TransferDraftManager](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/src/core/transfer_draft_manager.dart).
- Los borradores se guardan de forma independiente por sucursal, utilizando como clave (`key`) de Hive el ID de la sucursal de origen actual (`getIt<AuthCubit>().currentBranchId`), previniendo inconsistencias al cambiar de sucursal.
- Se refactorizó [CreateTransferNotifier](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/src/modules/inventory/create_transfer/mediator.dart) para permitir una construcción dinámica, aceptando listas de productos, sucursal destino y observaciones previas.
- Se unificó la instanciación de [CreateTransferNotifier](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/src/modules/inventory/create_transfer/mediator.dart) convirtiendo la pantalla Web en un `StatelessWidget` y eliminando la duplicación del notifier, compartiendo el mismo mediador heredado con móvil.
- Se integró `PopScope` en [CreateTransferScreen](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/src/modules/inventory/create_transfer/create_transfer_screen.dart) para interceptar intentos de salida con cambios no vacíos, desplegando un diálogo de confirmación interactivo con las opciones exactas: "Salir y Guardar Borrador", "Salir y no guardar", y "Cancelar".
- Se sincronizó la eliminación del borrador de la sucursal actual cuando la transferencia se crea con éxito en el backend.
- Se crearon las funciones utilitarias `showCommercialProductDialogFromId` y `showCommercialProductModalFromId` en los respectivos diálogos comerciales de productos para encapsular el loader, la consulta del producto por ID y la apertura segura de los diálogos.
- Se integraron los campos de gastos (`expensesTotal`, `expensesPaid`) y el cálculo de gastos pendientes (`expensesOwed`) en el modelo `ExecutiveSummaryInDb`, asegurando total retrocompatibilidad con fallback seguro en `fromJson`.
- Se diseñó e integró la tarjeta de "Resumen de Gastos / Egresos" en `ExecutiveSummaryDetailScreen`, aplicando un estilo premium con fondo en degradado de tonos rojizos/naranjas sutiles y mostrando el desglose de gastos totales, pagados y pendientes.
- Se integraron los campos de gastos por sucursal en el modelo `CommercialBranchDetail` con fallback seguro en `fromJson` para retrocompatibilidad.
- Se implementó el gráfico de pastel de "Gastos por Sucursal" (`_ExpensesPieChartCard`) en el reporte global de administración en `ExecutiveSummaryDetailScreen`.
- Se agregó la sección de desglose de "Gastos / Egresos" en la tarjeta de resumen específico por sucursal en `BranchExecutiveSummaryScreen`.
- Se han implementado e integrado los componentes de visualización `showOperativeExpenseViewerDialog` y `showSupplierExpenseViewerDialog` en `lib/widgets/dialogs/viewers/`, que permiten cargar y visualizar los detalles de gastos operativos y a proveedores. Se integraron con gestos tap (`InkWell`) en los listados Web y Móvil de cada módulo.
- Se implementó el scroll automático centrado (mediante `Scrollable.ensureVisible` con `alignment: 0.5`) y enfoque del teclado para el primer producto móvil que tenga cantidad 0 al intentar guardar una transferencia en `create_transfer_screen_mobile.dart`. Las `GlobalKey<MobileProductCardState>` se aprovisionan a nivel de constructor de `MobileProductCard` para resolver problemas de `currentState == null` y permitir llamar a `setCardColorError()`, pintando la tarjeta de color rojo suave e invalidando el error al ingresar cantidades válidas.
- Se refactorizó la vista de creación de transferencia en móvil extrayendo la tarjeta del producto (`MobileProductCard`), el botón de guardado (`SaveButton`) y sus componentes relacionados al nuevo archivo `mobile/widgets.dart`, aligerando el archivo de pantalla principal. Asimismo, se incorporó la visualización del Stock Disponible (`availableStock`) y el Costo Unitario con iconos informativos estilizados dentro de la tarjeta móvil de cada producto.
- Se ha implementado el módulo **Historial de Entradas por Producto** en `lib/src/modules/inventory/product_entry_history/` con soporte responsivo para Web y Móvil. Permite seleccionar un producto y visualiza un listado con Fecha, Proveedor y Costo Unitario (formateado sin símbolo de moneda a través de `NumberFormatter.convertFromCentsToUnitsCurrency`) de todas las entradas asociadas a dicho producto. Al presionar sobre un elemento, se abre el visor detallado `showEntryHistoryViewerDialog(context, entryHistory)`.
- Se corrigió el problema en el diálogo y modal comercial (`showCommercialProductDialogFromId` y `showCommercialProductModalFromId`) donde al editar un ítem existente (`SaleItem`) no se seleccionaba automáticamente la unidad correspondiente ni la cantidad según el factor de conversión (`previousSaleItem.conversionFactor`). Ahora se busca e identifica la unidad de medida coincidente en `product.extraUnits` (o la unidad base), resolviendo de forma transparente `selectedUnitIndex`, `selectedUnitName`, `conversionFactor` y la cantidad por unidad (`quantity ~/ conversionFactor`). Asimismo, en `invoice_creator_screen.dart` (Proformas/Cotizaciones), se pasó adecuadamente `conversionFactor` y `unitName` al instanciar o actualizar el `SaleItem`.

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

## Submódulo de Categorías de Gastos (Mayo 2026)
- **Generación y Estructura**: Se utilizó `onion flutter-module expense_category --output-dir lib/src/modules/expenses` para generar la base estructurada en `lib/src/modules/expenses/expense_categories/`.
- **Capa de Lógica (Cubit)**: Se eliminó la carpeta local `cubit/` autogenerada dentro del submódulo, reutilizando los cubits globales existentes en `lib/src/cubits/expense_category_cubit` (`ReadExpenseCategoryCubit` y `WriteExpenseCategoryCubit`).
- **Inyección de Dependencias**: Se inyectó `ExpenseCategoriesRepository` y su DataSource en el `provider_container.dart` principal.
- **Vistas**: Se crearon las vistas `ExpenseCategoriesScreen`, `ExpenseCategoryWeb` y `ExpenseCategoryTable` en español. No se incluyó versión móvil ya que la vista sencilla no la requiere (sigue el mismo patrón que el catálogo de categorías de productos).
- **Diálogos**: Se implementó `CreateExpenseCategoryDialog` para gestionar la creación y edición de categorías de gastos con validaciones y confirmaciones.









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

## Submódulo de Categorías de Gastos (Mayo 2026)
- **Generación y Estructura**: Se utilizó `onion flutter-module expense_category --output-dir lib/src/modules/expenses` para generar la base estructurada en `lib/src/modules/expenses/expense_categories/`.
- **Capa de Lógica (Cubit)**: Se eliminó la carpeta local `cubit/` autogenerada dentro del submódulo, reutilizando los cubits globales existentes en `lib/src/cubits/expense_category_cubit` (`ReadExpenseCategoryCubit` y `WriteExpenseCategoryCubit`).
- **Inyección de Dependencias**: Se inyectó `ExpenseCategoriesRepository` y su DataSource en el `provider_container.dart` principal.
- **Vistas**: Se crearon las vistas `ExpenseCategoriesScreen`, `ExpenseCategoryWeb` y `ExpenseCategoryTable` en español. No se incluyó versión móvil ya que la vista sencilla no la requiere (sigue el mismo patrón que el catálogo de categorías de productos).
- **Diálogos**: Se implementó `CreateExpenseCategoryDialog` para gestionar la creación y edición de categorías de gastos con validaciones y confirmaciones.
- **Rutas y Menú**: Se registró la ruta `expense-categories` en `app_router.dart` y se añadió un botón de acceso directo en `expenses_menu_screen.dart`.
- **Autocompletado de Categorías en Gastos Operativos**: Se modificó `CreateExpenseDialog` de gastos operativos para utilizar `CustomAutocompleteTextfield<ExpenseCategoryInDb>` en el campo de categorías, permitiendo a los usuarios buscar y seleccionar categorías mediante autocompletado interactivo.
- **Carga Concurrente de Datos**: Se modificó `ReadExpenseCubit` (`getAll`) para cargar concurrentemente tanto los gastos como las categorías mediante `Future.wait`, asegurando que la lista de categorías esté lista al instante para el autocompletado.
- **Reestructuración y Diseño Adaptativo (Web vs. Móvil)**: Se dividió el archivo del diálogo de gastos operativos en `create_expense_dialog.dart` (controlador principal) y `form_section.dart` (parte conteniendo `_FormContent`), emulando la estructura de `product_list/dialogs`. El diálogo ahora es adaptativo utilizando `context.isMobile()`: muestra un `AlertDialog` emergente en Web/Escritorio y conserva la pantalla completa con Scaffold en dispositivos móviles.
- **Estado de Pago y Fecha de Vencimiento en Gastos**: Se agregaron los campos `status` y `expirationDate` al DTO `UpdateExpense`. En el formulario del diálogo de gastos operativos, se añadió un selector Switch "¿Pagado?" que al desactivarse (estado `open`) despliega un `DatePickerButton` adicional para seleccionar la fecha de vencimiento (`expirationDate`).
- **Resaltado de Filas en Lista Web de Gastos**: Se adaptó el listado web de gastos operativos en `_ExpensesRows` (`operative_expenses_screen.dart`) para evaluar `state.newItems` y `state.updatedItems`, resaltando visualmente los gastos agregados (en amarillo) o modificados (en azul) al igual que en la vista móvil y la lista de clientes.
- **Filtro por Estado en Gastos Operativos**: Se integró un selector dropdown (`DropdownButtonFormField`) en la vista Web (al lado del buscador) y en la vista Móvil (debajo del buscador) para filtrar los gastos operativos por su estado: **Todos**, **Pendiente** (`open`) y **Pagado** (`paid`). Este dropdown actualiza el objeto `queryParams` del cubit y refresca los resultados desde el backend.
- **Búsqueda por Palabra Clave en Repositorio de Gastos**: Se corrigió un bug en `ExpensesRepository.getAllExpenses` que no almacenaba el listado en la variable local `_expenses`. Ahora la búsqueda local por palabras clave (`searchByKeyword`) funciona correctamente en tiempo real sin arrojar listas vacías.
- **Flujo de Crédito en Gastos Operativos**: Se reemplazó el Switch "¿Pagado?" en el formulario de creación/edición de gastos por el Switch "¿Crédito?". Si es de crédito (`isCredit = true`), se despliega la opción de fecha de vencimiento (`expirationDate`) y el gasto se guarda con estado `open` (pendiente). Si no es crédito, se registra como de contado (`status = paid`) y sin vencimiento.
- **Acciones Rápidas y Pago Directo**: Se reemplazó el icono del lápiz de edición en el listado de gastos (tanto en Web como en Móvil) por un menú de 3 puntos (`PopupMenuButton`). Este menú permite:
  - **Editar**: Abre el formulario correspondiente.
  - **Marcar como Pagado** (solo disponible si el gasto tiene estado `open`): Pide confirmación al usuario y actualiza directamente el estado en el backend a `paid` (estableciendo la fecha de vencimiento en `null`), refrescando la interfaz local al instante.
- **Eliminación y Marcado Visual en Rojo Suave**: Se añadió la opción **Eliminar** en el menú de 3 puntos (`PopupMenuButton`) de la lista de gastos operativos. Al eliminar un gasto, se solicita confirmación deslizante (`slideToConfirmActionDialog`), se realiza el borrado en el backend y visualmente la fila del gasto no se elimina de la pantalla, sino que se resalta con un fondo rojo suave (`Colors.red.shade200`) y se oculta su menú de acciones rápidas para evitar interacciones adicionales.
- **Sincronización Reactiva de Cubits vía UI (Estándar)**: Se documentó formalmente en `agents.md` la recomendación de envolver los listados en un `BlocListener<WriteCubit, WriteState>` para capturar la creación, edición o eliminación de entidades y actualizar reactivamente el `ReadCubit`. Se refinó este patrón en la pantalla de gastos operativos moviendo el `BlocListener` "hasta arriba" en `_BaseScaffold` (`operative_expenses_screen.dart`), cubriendo de forma limpia y centralizada tanto la vista Web como la Móvil, y eliminándolo de las tablas y listas individuales.
- **Modularización de Widgets en Gastos Operativos**: Se crearon los widgets públicos `ExpensesTable`, `ExpensesRows` y `StatusBadge` en `lib/src/modules/expenses/operative_expenses/widgets/operative_expenses_widgets.dart` y se eliminaron las implementaciones privadas redundantes dentro de `operative_expenses_screen.dart`, actualizando sus llamadas y mejorando la legibilidad.
- **Rutas y Menú**: Se registró la ruta `expense-categories` en `app_router.dart` y se añadió un botón de acceso directo en `expenses_menu_screen.dart`.
- **Autocompletado de Categorías en Gastos Operativos**: Se modificó `CreateExpenseDialog` de gastos operativos para utilizar `CustomAutocompleteTextfield<ExpenseCategoryInDb>` en el campo de categorías, permitiendo a los usuarios buscar y seleccionar categorías mediante autocompletado interactivo.
- **Carga Concurrente de Datos**: Se modificó `ReadExpenseCubit` (`getAll`) para cargar concurrentemente tanto los gastos como las categorías mediante `Future.wait`, asegurando que la lista de categorías esté lista al instante para el autocompletado.
- **Reestructuración y Diseño Adaptativo (Web vs. Móvil)**: Se dividió el archivo del diálogo de gastos operativos en `create_expense_dialog.dart` (controlador principal) y `form_section.dart` (parte conteniendo `_FormContent`), emulando la estructura de `product_list/dialogs`. El diálogo ahora es adaptativo utilizando `context.isMobile()`: muestra un `AlertDialog` emergente en Web/Escritorio y conserva la pantalla completa con Scaffold en dispositivos móviles.
- **Estado de Pago y Fecha de Vencimiento en Gastos**: Se agregaron los campos `status` y `expirationDate` al DTO `UpdateExpense`. En el formulario del diálogo de gastos operativos, se añadió un selector Switch "¿Pagado?" que al desactivarse (estado `open`) despliega un `DatePickerButton` adicional para seleccionar la fecha de vencimiento (`expirationDate`).
- **Resaltado de Filas en Lista Web de Gastos**: Se adaptó el listado web de gastos operativos en `_ExpensesRows` (`operative_expenses_screen.dart`) para evaluar `state.newItems` y `state.updatedItems`, resaltando visualmente los gastos agregados (en amarillo) o modificados (en azul) al igual que en la vista móvil y la lista de clientes.
- **Filtro por Estado en Gastos Operativos**: Se integró un selector dropdown (`DropdownButtonFormField`) en la vista Web (al lado del buscador) y en la vista Móvil (debajo del buscador) para filtrar los gastos operativos por su estado: **Todos**, **Pendiente** (`open`) y **Pagado** (`paid`). Este dropdown actualiza el objeto `queryParams` del cubit y refresca los resultados desde el backend.
- **Búsqueda por Palabra Clave en Repositorio de Gastos**: Se corrigió un bug en `ExpensesRepository.getAllExpenses` que no almacenaba el listado en la variable local `_expenses`. Ahora la búsqueda local por palabras clave (`searchByKeyword`) funciona correctamente en tiempo real sin arrojar listas vacías.
- **Flujo de Crédito en Gastos Operativos**: Se reemplazó el Switch "¿Pagado?" en el formulario de creación/edición de gastos por el Switch "¿Crédito?". Si es de crédito (`isCredit = true`), se despliega la opción de fecha de vencimiento (`expirationDate`) y el gasto se guarda con estado `open` (pendiente). Si no es crédito, se registra como de contado (`status = paid`) y sin vencimiento.
- **Acciones Rápidas y Pago Directo**: Se reemplazó el icono del lápiz de edición en el listado de gastos (tanto en Web como en Móvil) por un menú de 3 puntos (`PopupMenuButton`). Este menú permite:
  - **Editar**: Abre el formulario correspondiente.
  - **Marcar como Pagado** (solo disponible si el gasto tiene estado `open`): Pide confirmación al usuario y actualiza directamente el estado en el backend a `paid` (estableciendo la fecha de vencimiento en `null`), refrescando la interfaz local al instante.
- **Eliminación y Marcado Visual en Rojo Suave**: Se añadió la opción **Eliminar** en el menú de 3 puntos (`PopupMenuButton`) de la lista de gastos operativos. Al eliminar un gasto, se solicita confirmación deslizante (`slideToConfirmActionDialog`), se realiza el borrado en el backend y visualmente la fila del gasto no se elimina de la pantalla, sino que se resalta con un fondo rojo suave (`Colors.red.shade200`) y se oculta su menú de acciones rápidas para evitar interacciones adicionales.
- **Sincronización Reactiva de Cubits vía UI (Estándar)**: Se documentó formalmente en `agents.md` la recomendación de envolver los listados en un `BlocListener<WriteCubit, WriteState>` para capturar la creación, edición o eliminación de entidades y actualizar reactivamente el `ReadCubit`. Se refinó este patrón en la pantalla de gastos operativos moviendo el `BlocListener` "hasta arriba" en `_BaseScaffold` (`operative_expenses_screen.dart`), cubriendo de forma limpia y centralizada tanto la vista Web como la Móvil, y eliminándolo de las tablas y listas individuales.
- **Modularización de Widgets en Gastos Operativos**: Se crearon los widgets públicos `ExpensesTable`, `ExpensesRows` y `StatusBadge` en `lib/src/modules/expenses/operative_expenses/widgets/operative_expenses_widgets.dart` y se eliminaron las implementaciones privadas redundantes dentro de `operative_expenses_screen.dart`, actualizando sus llamadas y mejorando la legibilidad.
- **Patrón de Carga Condicional para Evitar Parpadeos en Read Cubits**: Se documentó formalmente en `agents.md` la práctica de evaluar si el estado actual es `ReadSuccess` antes de emitir un `ReadLoading()` en `getAll()`. Si ya hay datos exitosos, se emite un estado de transición como `ReadSearching` conservando las listas en memoria. Esto permite mostrar un indicador de carga superior sutil en la UI en lugar de borrar toda la pantalla y mostrar un spinner principal, mejorando radicalmente la experiencia de usuario.
- **Módulo de Gastos de Proveedores (Supplier Expenses)**: Se creó el módulo de gastos por proveedor en `lib/src/modules/expenses/supplier_expenses/` replicando la arquitectura modular de Gastos Operativos. Se adaptaron los componentes de listado Web y Móvil para mostrar `supplierName` en lugar de la categoría, y se integró el diálogo selector `showSupplierSelectionDialog` en el formulario para asociar los gastos al proveedor correspondiente. Se configuró para iniciar con crédito activo por defecto y calcular automáticamente la fecha de vencimiento sumando los días de crédito del proveedor (`supplier.creditDays`) a la fecha del documento, recalculando interactivamente en tiempo real si se cambia la fecha o el estado del crédito. Además, se integró el widget reutilizable `SupplierSelector` como filtro interactivo superior en Web y Móvil a través del query param `supplierId`, logrando simplificar los listados de vuelta a `StatelessWidget`. Se mantiene la misma lógica reactiva con `WriteExpenseCubit` y `ReadExpenseCubit`.
- **Selector de Proveedores (Junio 2026)**: Se implementó `supplier_selection_dialog.dart` en `lib/widgets/dialogs/selectors/`, diseñado para realizar búsquedas de proveedores usando la palabra clave de búsqueda de `SuppliersRepository` y ofreciendo una interfaz limpia y similar al diálogo de selección de clientes.
- **Módulo de Reporte de Gastos (Expenses Reports - Junio 2026)**: Se creó el módulo de reportes de gastos en `lib/src/modules/expenses/expenses_reports/` con un diseño adaptativo Web y Móvil. Integra un selector de fechas de inicio y fin (BOM UTF-8 para Excel), segmented button para alternar entre vista detallada (tabla con tipo de gasto, número, concepto, fecha y monto) y consolidada (gastos agrupados y sumados por categoría para operativos y por proveedor para proveedores, subtotalizados y con gran total general), y soporte para exportación en formato CSV y PDF (A4) compartiendo el `ReadExpenseCubit` global sin repeticiones de red innecesarias.
- **Límite de Tiempo para Eliminar Gastos (Junio 2026)**: Se implementó una validación en los listados de gastos operativos y de proveedores (tanto en Web como en Móvil) para ocultar la opción "Eliminar" del menú si el gasto tiene más de 12 horas de haber sido creado (`createdAt`), garantizando consistencia en las políticas de auditoría del sistema.
- **Rango de Fechas por Defecto en Reporte de Gastos (Junio 2026)**: Se configuró el reporte de gastos para que, de forma inicial y al limpiar filtros, use la fecha actual filtrando desde `startOfDay()` hasta `endOfDay()`, aprovechando las extensiones del objeto `DateTime`.
- Se implementó un widget dropdown reusable de categorías de gastos (`ExpenseCategoryDropdown`) en `lib/widgets/dropdown/expense_category_dropdown.dart` que filtra las categorías activas (`isActive && !isDeleted`) y ordenadas alfabéticamente.
- Se integró `ExpenseCategoryDropdown` en los listados Web (`operative_expenses_widgets.dart`) y Móvil (`operative_expenses_mobile.dart`) como filtro por categoría, y se reemplazó el autocomplete de categorías (`CustomAutocompleteTextfield`) en el formulario de creación/edición de gastos operativos (`form_section.dart`), simplificando la interfaz del usuario.


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

## Submódulo de Categorías de Gastos (Mayo 2026)
- **Generación y Estructura**: Se utilizó `onion flutter-module expense_category --output-dir lib/src/modules/expenses` para generar la base estructurada en `lib/src/modules/expenses/expense_categories/`.
- **Capa de Lógica (Cubit)**: Se eliminó la carpeta local `cubit/` autogenerada dentro del submódulo, reutilizando los cubits globales existentes en `lib/src/cubits/expense_category_cubit` (`ReadExpenseCategoryCubit` y `WriteExpenseCategoryCubit`).
- **Inyección de Dependencias**: Se inyectó `ExpenseCategoriesRepository` y su DataSource en el `provider_container.dart` principal.
- **Vistas**: Se crearon las vistas `ExpenseCategoriesScreen`, `ExpenseCategoryWeb` y `ExpenseCategoryTable` en español. No se incluyó versión móvil ya que la vista sencilla no la requiere (sigue el mismo patrón que el catálogo de categorías de productos).
- **Diálogos**: Se implementó `CreateExpenseCategoryDialog` para gestionar la creación y edición de categorías de gastos con validaciones y confirmaciones.
- **Rutas y Menú**: Se registró la ruta `expense-categories` en `app_router.dart` y se añadió un botón de acceso directo en `expenses_menu_screen.dart`.
- **Autocompletado de Categorías en Gastos Operativos**: Se modificó `CreateExpenseDialog` de gastos operativos para utilizar `CustomAutocompleteTextfield<ExpenseCategoryInDb>` en el campo de categorías, permitiendo a los usuarios buscar y seleccionar categorías mediante autocompletado interactivo.
- **Carga Concurrente de Datos**: Se modificó `ReadExpenseCubit` (`getAll`) para cargar concurrentemente tanto los gastos como las categorías mediante `Future.wait`, asegurando que la lista de categorías esté lista al instante para el autocompletado.
- **Reestructuración y Diseño Adaptativo (Web vs. Móvil)**: Se dividió el archivo del diálogo de gastos operativos en `create_expense_dialog.dart` (controlador principal) y `form_section.dart` (parte conteniendo `_FormContent`), emulando la estructura de `product_list/dialogs`. El diálogo ahora es adaptativo utilizando `context.isMobile()`: muestra un `AlertDialog` emergente en Web/Escritorio y conserva la pantalla completa con Scaffold en dispositivos móviles.
- **Estado de Pago y Fecha de Vencimiento en Gastos**: Se agregaron los campos `status` y `expirationDate` al DTO `UpdateExpense`. En el formulario del diálogo de gastos operativos, se añadió un selector Switch "¿Pagado?" que al desactivarse (estado `open`) despliega un `DatePickerButton` adicional para seleccionar la fecha de vencimiento (`expirationDate`).
- **Resaltado de Filas en Lista Web de Gastos**: Se adaptó el listado web de gastos operativos en `_ExpensesRows` (`operative_expenses_screen.dart`) para evaluar `state.newItems` y `state.updatedItems`, resaltando visualmente los gastos agregados (en amarillo) o modificados (en azul) al igual que en la vista móvil y la lista de clientes.
- **Filtro por Estado en Gastos Operativos**: Se integró un selector dropdown (`DropdownButtonFormField`) en la vista Web (al lado del buscador) y en la vista Móvil (debajo del buscador) para filtrar los gastos operativos por su estado: **Todos**, **Pendiente** (`open`) y **Pagado** (`paid`). Este dropdown actualiza el objeto `queryParams` del cubit y refresca los resultados desde el backend.
- **Búsqueda por Palabra Clave en Repositorio de Gastos**: Se corrigió un bug en `ExpensesRepository.getAllExpenses` que no almacenaba el listado en la variable local `_expenses`. Ahora la búsqueda local por palabras clave (`searchByKeyword`) funciona correctamente en tiempo real sin arrojar listas vacías.
- **Flujo de Crédito en Gastos Operativos**: Se reemplazó el Switch "¿Pagado?" en el formulario de creación/edición de gastos por el Switch "¿Crédito?". Si es de crédito (`isCredit = true`), se despliega la opción de fecha de vencimiento (`expirationDate`) y el gasto se guarda con estado `open` (pendiente). Si no es crédito, se registra como de contado (`status = paid`) y sin vencimiento.
- **Acciones Rápidas y Pago Directo**: Se reemplazó el icono del lápiz de edición en el listado de gastos (tanto en Web como en Móvil) por un menú de 3 puntos (`PopupMenuButton`). Este menú permite:
  - **Editar**: Abre el formulario correspondiente.
  - **Marcar como Pagado** (solo disponible si el gasto tiene estado `open`): Pide confirmación al usuario y actualiza directamente el estado en el backend a `paid` (estableciendo la fecha de vencimiento en `null`), refrescando la interfaz local al instante.
- **Eliminación y Marcado Visual en Rojo Suave**: Se añadió la opción **Eliminar** en el menú de 3 puntos (`PopupMenuButton`) de la lista de gastos operativos. Al eliminar un gasto, se solicita confirmación deslizante (`slideToConfirmActionDialog`), se realiza el borrado en el backend y visualmente la fila del gasto no se elimina de la pantalla, sino que se resalta con un fondo rojo suave (`Colors.red.shade200`) y se oculta su menú de acciones rápidas para evitar interacciones adicionales.
- **Sincronización Reactiva de Cubits vía UI (Estándar)**: Se documentó formalmente en `agents.md` la recomendación de envolver los listados en un `BlocListener<WriteCubit, WriteState>` para capturar la creación, edición o eliminación de entidades y actualizar reactivamente el `ReadCubit`. Se refinó este patrón en la pantalla de gastos operativos moviendo el `BlocListener` "hasta arriba" en `_BaseScaffold` (`operative_expenses_screen.dart`), cubriendo de forma limpia y centralizada tanto la vista Web como la Móvil, y eliminándolo de las tablas y listas individuales.
- **Modularización de Widgets en Gastos Operativos**: Se crearon los widgets públicos `ExpensesTable`, `ExpensesRows` y `StatusBadge` en `lib/src/modules/expenses/operative_expenses/widgets/operative_expenses_widgets.dart` y se eliminaron las implementaciones privadas redundantes dentro de `operative_expenses_screen.dart`, actualizando sus llamadas y mejorando la legibilidad.
- **Patrón de Carga Condicional para Evitar Parpadeos en Read Cubits**: Se documentó formalmente en `agents.md` la práctica de evaluar si el estado actual es `ReadSuccess` antes de emitir un `ReadLoading()` en `getAll()`. Si ya hay datos exitosos, se emite un estado de transición como `ReadSearching` conservando las listas en memoria. Esto permite mostrar un indicador de carga superior sutil en la UI en lugar de borrar toda la pantalla y mostrar un spinner principal, mejorando radicalmente la experiencia de usuario.
- **Módulo de Gastos de Proveedores (Supplier Expenses)**: Se creó el módulo de gastos por proveedor en `lib/src/modules/expenses/supplier_expenses/` replicando la arquitectura modular de Gastos Operativos. Se adaptaron los componentes de listado Web y Móvil para mostrar `supplierName` en lugar de la categoría, y se integró el diálogo selector `showSupplierSelectionDialog` en el formulario para asociar los gastos al proveedor correspondiente. Se configuró para iniciar con crédito activo por defecto y calcular automáticamente la fecha de vencimiento sumando los días de crédito del proveedor (`supplier.creditDays`) a la fecha del documento, recalculando interactivamente en tiempo real si se cambia la fecha o el estado del crédito. Además, se integró el widget reutilizable `SupplierSelector` como filtro interactivo superior en Web y Móvil a través del query param `supplierId`, logrando simplificar los listados de vuelta a `StatelessWidget`. Se mantiene la misma lógica reactiva con `WriteExpenseCubit` y `ReadExpenseCubit`.
- **Selector de Proveedores (Junio 2026)**: Se implementó `supplier_selection_dialog.dart` en `lib/widgets/dialogs/selectors/`, diseñado para realizar búsquedas de proveedores usando la palabra clave de búsqueda de `SuppliersRepository` y ofreciendo una interfaz limpia y similar al diálogo de selección de clientes.
- **Módulo de Reporte de Gastos (Expenses Reports - Junio 2026)**: Se creó el módulo de reportes de gastos en `lib/src/modules/expenses/expenses_reports/` con un diseño adaptativo Web y Móvil. Integra un selector de fechas de inicio y fin (BOM UTF-8 para Excel), segmented button para alternar entre vista detallada (tabla con tipo de gasto, número, concepto, fecha y monto) y consolidada (gastos agrupados y sumados por categoría para operativos y por proveedor para proveedores, subtotalizados y con gran total general), y soporte para exportación en formato CSV y PDF (A4) compartiendo el `ReadExpenseCubit` global sin repeticiones de red innecesarias.
- **Límite de Tiempo para Editar y Eliminar Gastos (Junio 2026)**: Se implementó una validación en los listados de gastos operativos y de proveedores (tanto en Web como en Móvil) para ocultar las opciones "Editar" y "Eliminar" del menú si el gasto supera las 4 horas de haber sido creado (`createdAt`), garantizando consistencia en las políticas de auditoría del sistema.
- **Rango de Fechas por Defecto en Reporte de Gastos (Junio 2026)**: Se configuró el reporte de gastos para que, de forma inicial y al limpiar filtros, use la fecha actual filtrando desde `startOfDay()` hasta `endOfDay()`, aprovechando las extensiones del objeto `DateTime`.
- Se implementó un widget dropdown reusable de categorías de gastos (`ExpenseCategoryDropdown`) en `lib/widgets/dropdown/expense_category_dropdown.dart` que filtra las categorías activas (`isActive && !isDeleted`) y ordenadas alfabéticamente.
- Se integró `ExpenseCategoryDropdown` en los listados Web (`operative_expenses_widgets.dart`) y Móvil (`operative_expenses_mobile.dart`) como filtro por categoría, y se reemplazó el autocomplete de categorías (`CustomAutocompleteTextfield`) en el formulario de creación/edición de gastos operativos (`form_section.dart`), simplificando la interfaz del usuario.
- Se corrigió una excepción de claves duplicadas (`Duplicate keys found`) en los listados de filtros de gastos Web y Móvil (tanto operativos como de proveedores). La colisión ocurría cuando múltiples filtros evaluaban a `ValueKey(null)` al estar vacíos. Se solucionó asignando prefijos de string únicos a los `ValueKey` correspondientes (ej. `"status_..."`, `"category_..."`).
- Se actualizó la restricción temporal de auditoría en todos los listados de gastos (operativos y proveedores, Web y Móvil) para limitar tanto la edición como la eliminación únicamente a las primeras 4 horas tras la creación del documento. Además, se oculta el botón del menú contextual completo si no hay acciones válidas que realizar para mejorar la experiencia de usuario.

## Refactorización de HomeScreen para Responsive (Junio 2026)
- Se refactorizó la vista del Home en `lib/src/modules/home/view/home_screen.dart` utilizando el patrón de partes para separar la UI de Web y Mobile.
- Se implementó la vista Web en `lib/src/modules/home/view/web/home_web.dart` manteniendo el diseño original de `Wrap` alineado para pantallas de más de 600px.
- Se implementó la vista Móvil en `lib/src/modules/home/view/mobile/home_mobile.dart` empleando una estructura de `ListView` y un widget de tarjetas personalizado premium (`HomeMobileOptionCard`) con icono grande a la izquierda (contenedor de 64x64, tamaño de icono 36px, sin color explícito para heredar el color por defecto oscuro de la versión Web), título del módulo a la derecha e indicador de flecha en el extremo.
- Se centralizó el listado de opciones de menú mediante la clase `HomeOption` y el método `getHomeOptions(context)` en `home_screen.dart` para evitar la duplicación de rutas y lógica entre Web y Mobile.

## Guía de Estilo Onion Fullstack (Junio 2026)
- Se creó la guía de estilo unificada `ONION_FULLSTACK_STYLE_GUIDE.md` en la raíz del monorepo.
- Se consolidaron los flujos de capas, transaccionalidad atómica con sesiones de MongoDB y manejo de excepciones desacoplado para el Backend.
- Se especificaron los dos patrones de sincronización de datos de Flutter: el enfoque estándar coordinado por UI y el enfoque avanzado desacoplado con `ReactiveRepository`.
- Se documentó el uso de la herramienta `onion` CLI, detallando todos sus comandos de generación para FastAPI y Flutter y los pasos de ajuste manual post-generación.

## Corrección de Reordenamiento en Accesos Directos (Junio 2026)
- Se corrigió un parpadeo visual molesto al arrastrar y soltar elementos para reordenar la lista en la pantalla de Accesos Directos (`ShortcutsMenuScreen`).
- El problema inicial se debía a que `buildWhen` en el `BlocBuilder` de la lista de accesos directos comparaba los conjuntos desordenados de rutas (`prev.routes.toSet() != curr.routes.toSet()`), lo que provocaba que evaluara a `false` al reordenar los mismos elementos, bloqueando la reconstrucción del árbol de widgets. Se solucionó utilizando `listEquals` de `package:flutter/foundation.dart` en `buildWhen`.
- El parpadeo remanente ocurría por el comportamiento asíncrono de `ShortcutsCubit.updateOrder` (y métodos similares). Dado que se realizaba un `await` a la persistencia de Hive antes de emitir el estado (`emit`), había una desincronización temporal (de unos milisegundos) donde la UI se reconstruía con los datos viejos y luego saltaba a los nuevos. Se resolvió emitiendo el estado modificado inmediatamente de forma síncrona en el Cubit, delegando el guardado en Hive en segundo plano sin retrasar el flujo de la UI.

## Corrección de Advertencias de Importación tras Migración a Paquete (Junio 2026)
- Se identificó y resolvió una masiva cantidad de advertencias de linter (`implementation_imports`) que surgieron al migrar la lógica de negocio al paquete local `kardex_business`.
- La causa era la importación directa de archivos privados de la carpeta `src` de otro paquete (ej. `package:kardex_business/src/...`).
- Se desarrolló e implementó un script de automatización en Python (`fix_imports.py`) para refactorizar recursivamente todos los archivos `.dart` en la carpeta `lib/` de `kardex_app_front`.
- El script consolidó todas las importaciones privadas en una única importación pública autorizada: `package:kardex_business/kardex_business.dart`, afectando exitosamente a 387 archivos y eliminando las advertencias del linter en la aplicación principal sin romper la compilación.

## Botón de Salida y Diálogo con Temporizador en Login (Julio 2026)
- Se hizo visible el botón de salida del negocio (icono de cerrar `Icons.close` en color `Colors.white70` en lugar de `Colors.transparent`) en el `AppBar` de `login_screen.dart`.
- Se eliminó el flujo anterior que requería pulsar 5 veces de forma invisible más una pulsación larga (`secretCounter`) para poder salir del negocio.
- Se implementó un diálogo modal privado `_ExitBusinessDialog` (`StatefulWidget`) que se abre al pulsar directamente el botón de salida.
- El diálogo inicia una cuenta regresiva interactiva de 5 segundos utilizando un `Timer.periodic`. Muestra un indicador circular de progreso rojo con el mensaje "Espera X segundos..." y mantiene deshabilitado el botón "Aceptar".
- Al llegar a 0 segundos, el diálogo cambia a un estado verde de confirmación ("Ya puedes confirmar la salida.") y habilita el botón "Aceptar" para ejecutar `authCubit.exitFromBusiness()` y redirigir a la pantalla de activación.
