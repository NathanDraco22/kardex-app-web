# Documentación del Módulo: Catálogo de Productos (`product_catalog`)

El módulo **Catálogo de Productos** gestiona el catálogo maestro de artículos, su clasificación taxonómica (categorías), las unidades de medida, las escalas de conversión estandarizadas y las reglas de fijación de precios en `kardex_app_front`.

---

## 1. Arquitectura y Submódulos

Ubicación: `lib/src/modules/product_catalog/`:

```text
lib/src/modules/product_catalog/
├── view/product_catalog_menu_screen.dart # Menú del catálogo de productos
├── product_list/                         # Listado maestro de productos (Global)
│   ├── cubit/                            # ReadProductCubit, WriteProductCubit
│   ├── dialogs/                          # CreateProductDialog, FormSection
│   └── view/product_list_screen.dart     # Pantalla maestra de productos
├── product_category/                     # Categorías y familias de productos
│   ├── cubit/                            # ProductCategoryCubit
│   ├── dialogs/                          # CreateCategoryDialog
│   └── view/product_category_screen.dart # Gestión de categorías
├── units/                                # Unidades de medida individuales
│   ├── cubit/                            # UnitsCubit
│   ├── dialog/                           # CreateUnitDialog
│   └── units_screen.dart                 # Gestión de unidades de medida
└── unit_scales/                          # Escalas y plantillas de conversión
    ├── cubit/                            # ReadUnitScalesCubit, WriteUnitScaleCubit
    ├── dialogs/                          # CreateUnitScaleDialog
    └── unit_scales_screen.dart           # Pantalla de gestión de escalas
```

---

## 2. Detalle de Submódulos Clave

### 2.1. Listado Maestro de Productos (`product_list`)
- **Propósito:** Creación, edición, consulta y archivo de productos a nivel global (independiente de sucursal).
- **Vistas:**
  - `ProductListScreen`: Tabla interactiva con búsqueda por texto, código de barras, SKU y código alternativo (`altCode`).
- **Cubits:**
  - `ReadProductCubit`: Consulta de productos con paginación, filtros de categoría y búsqueda rápida.
  - `WriteProductCubit`: Creación (`createProduct`) y actualización (`updateProduct`) de productos.
- **Diálogos Clave:**
  - `showCreateProductDialog`: Modal reutilizable para alta y edición de producto.
  - Campos soportados: Nombre, Código de barras, `altCode` (Código alternativo), Marca, Categoría, Unidad de medida base, Precio de venta sugerido y subida/selección de imagen.
- **Factoría de Integración con Sucursales:**
  - Utiliza `productInBranchFromProduct` y la extensión `ProductInDbInBranchUpdateX` en `lib/src/tools/factories/product_in_branch_factory.dart` para reflejar cambios inmediatamente en inventarios de sucursal sin duplicar llamadas.

### 2.2. Categorías de Productos (`product_category`)
- **Propósito:** Estructuración jerárquica de productos para facilitar búsquedas, reportes agrupados y filtrado en el POS.
- **Vistas:** `ProductCategoryScreen`.
- **Cubits:** `ProductCategoryCubit`.
- **Acciones:**
  - Creación, actualización y eliminación de categorías.
  - Asignación de iconos o colores identificativos.

### 2.3. Unidades de Medida (`units`)
- **Propósito:** Control de unidades físicas (unidad, caja, fardo, kg, litro, metro) y definición de factores de conversión individuales.
- **Vistas:** `UnitsScreen`.
- **Cubits:** `UnitsCubit`.
- **Integración:**
  - Trabaja estrechamente con `UnitConversionTool` (`lib/src/tools/unit_conversion_tool.dart`) para calcular equivalencias al ingresar compras por caja y vender al por menor por unidad.

### 2.4. Escalas de Unidades de Medida (`unit_scales`)
- **Propósito:** Plantillas reutilizables de conversión para productos que se comercializan bajo diferentes unidades y múltiplos (Peso, Volumen, Longitud, Tiempo y personalizadas). Evita tener que reconfigurar manualmente las unidades extras y factores producto por producto.
- **Vistas:** `UnitScalesScreen` (diseño responsivo con chips de equivalencias, badges de detalle y mayoreo).
- **Cubits:**
  - `ReadUnitScalesCubit`: Carga, filtrado local en tiempo real y refresco de escalas.
  - `WriteUnitScaleCubit`: Creación (`createNewUnitScale`), edición (`updateUnitScale`) y eliminación (`deleteUnitScale`).
- **Diálogo Interactivo:**
  - `showCreateOrEditUnitScaleDialog` (`CreateUnitScaleDialog`): Modal con validación de formularios, configuración de unidad base, adición dinámica de unidades adicionales (`ExtraUnit`) con factor entero multiplicador y selectores de unidad por defecto y mayorista sugeridas.
- **Sistema de Presets Automáticos:**
  - `UnitScalePresets`: Plantillas predeterminadas (Peso, Peso Agrícola, Volumen, Empaque, Longitud) cargables en 1 clic desde el modal `UnitScalePresetSelectorDialog`.
  - Integrado mediante el botón **"Usar Preset"** en los diálogos de alta de producto (`create_product_dialog.dart`, `create_product_with_data_dialog.dart`) y en el editor modal `extra_units_editor_dialog.dart`.
- **Fijación de Precios y Costos Bidireccionales:**
  - `ProductPriceEditorScreen` / `product_price_editor_dialog.dart`: Sincronización instantánea entre el precio base (ej. Gramos) y el precio comercial (ej. Libras), preselección automática de la unidad preferida (`defaultUnitIndex`) y visualización dinámica de los costos (Promedio, Última Compra, Máximo y Sugerido) para la unidad seleccionada.
- **Documentación Completa:** Ver [Guía Maestra de Unidades de Medida y Conversiones](./unit_scales.md).

---

## 3. Repositorios y Fuentes de Datos Involucrados

| Submódulo | DataSource | Repositorio |
| :--- | :--- | :--- |
| Productos | `ProductsDataSource` | `ProductsRepository` |
| Categorías | `ProductCategoriesDataSource` | `ProductCategoriesRepository` |
| Unidades | `UnitsDataSource` | `UnitsRepository` |
| Escalas de Unidades | `UnitScalesDataSource` | `UnitScalesRepository` |

---

## 4. Rutas en `app_router.dart`

- `/product-catalog`: Menú principal del catálogo (`ProductCatalogMenuScreen`).
- `/product-catalog/product-list`: Listado global de productos (`ProductListScreen`).
- `/product-catalog/product-category`: Catálogo de categorías (`ProductCategoryScreen`).
- `/product-catalog/units`: Unidades de medida individuales (`UnitsScreen`).
- `/product-catalog/unit-scales`: Escalas y plantillas de conversión (`UnitScalesScreen`).
