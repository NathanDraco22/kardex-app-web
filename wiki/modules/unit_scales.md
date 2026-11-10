# Guía Maestra de Unidades de Medida, Escalas y Fracciones Comerciales (`unit_scales`)

La gestión de **Unidades de Medida y Escalas de Conversión (`UnitScale`)** en `kardex_app_front` y `kardex_business` concilia dos mundos:

1. **Inventario contable 100% entero (`int`):** el stock, las cantidades de líneas y el kárdex se guardan en la **unidad base mínima** de la escala. No hay cantidades fraccionarias en MongoDB.
2. **Venta comercial flexible:** el cajero trabaja en la unidad comercial que entiende el negocio (Libra, Litro, Metro, Caja, Docena) y puede usar fracciones exactas de esa unidad.

La decisión central de esta versión es:

> **La unidad base es la fracción comercial mínima que el negocio vende, no necesariamente la unidad física más pequeña. Las unidades extra son los múltiplos mayores. El `scaleType` de la escala decide qué fracción mínima aplica.**

Ejemplos:

- Peso/Volumen/Longitud → la base es el **cuarto** (`Cuarto de Libra`, `Cuarto de Litro`, `Cuarto de Metro`).
- Empaque fraccionado (`fractionPack`) → la base es **media o cuarta parte del empaque**, según el tamaño.
- Empaque con venta por unidad (`pack`) → la base es la **unidad** y las cajas/docenas son extras.
- Personalizada (`custom`) → el usuario define la base y los factores.

Esto elimina la necesidad de una propiedad `fractionType` o de un enum de fracciones por producto: **la base ya es la fracción**.

---

## 1. Principios

> [!IMPORTANT]
> **El stock sigue siendo `int` y el dinero sigue siendo `int` (centavos).**
> Lo que cambia es la elección de la unidad base para que el factor comercial sea `2` o `4` en los casos comunes, en lugar de `454`, `1000`, `12`, `24` o `30`.

- La **unidad base** es indivisible en inventario.
- La **unidad comercial** es la que ve el cajero; se obtiene con `conversionFactor` respecto a la base.
- La **fracción mínima de venta** queda codificada por la base:
  - Base `Cuarto de Libra` → se vende en múltiplos de `0.25 Libra`.
  - Base `Media Caja x30` → se vende en múltiplos de `0.5 Caja x30`.
  - Base `Cuarto de Caja x12` → se vende en múltiplos de `0.25 Caja x12`.
  - Base `Unidad` → se vende en unidades enteras.
- El **paso de los botones `+`/`-` y del teclado** es siempre una unidad base: `1 / conversionFactor` de la unidad seleccionada.

---

## 2. `scaleType`: tipos de escala

`scaleType` vive **solo en la escala/plantilla**, no en el producto. El producto guarda su foto de `unitName`, `extraUnits`, `defaultUnitIndex` y `wholesaleUnitIndex`.

```dart
enum UnitScaleType {
  weight,       // Peso continuo: base cuarto de la unidad principal
  volume,       // Volumen continuo: base cuarto de la unidad principal
  length,       // Longitud continua: base cuarto de la unidad principal
  pack,         // Empaque con venta por unidad
  fractionPack, // Empaque fraccionado: media/cuarto de empaque
  custom,       // Escala personalizada
}
```

| `scaleType` | Unidad base | ¿Venta por unidad? | Uso típico |
| :--- | :--- | :---: | :--- |
| `weight` | `Cuarto de Libra` | No | Arroz, queso, carne, granos |
| `volume` | `Cuarto de Litro` (250 ml) | No | Líquidos a granel |
| `length` | `Cuarto de Metro` (25 cm) | No | Telas, cabos, rollos |
| `pack` | `Unidad` (1) | **Sí** | Medicamentos que se venden por unidad y por caja |
| `fractionPack` | Media/cuarto de empaque | No | Distribuidoras que venden media caja/cuarto de caja |
| `custom` | La que defina el usuario | Según factores | Casos especiales |

`time` no se incluye por ahora porque el negocio vende productos, no servicios. Queda documentado como pendiente para el futuro.

---

## 3. Escalas continuas: peso, volumen y longitud

La base es siempre el cuarto de la unidad principal. Las unidades extra son los múltiplos mayores.

| Escala | Base | Extras | Default | Mayorista |
| :--- | :--- | :--- | :--- | :--- |
| **Libra** (`weight`) | `Cuarto de Libra` (4 oz) | `Libra` ×4, `Arroba 25 lb` ×100, `Quintal 100 lb` ×400 | Libra | Arroba o Quintal |
| **Litro** (`volume`) | `Cuarto de Litro` (250 ml) | `Litro` ×4, `Bidón 5 L` ×20, `Bidón 20 L` ×80 | Litro | Bidón 20 L |
| **Metro** (`length`) | `Cuarto de Metro` (25 cm) | `Metro` ×4, `Rollo 50 m` ×200, `Rollo 100 m` ×400 | Metro | Rollo 100 m |

No se incluyen `Media Libra`, `Medio Litro` ni `Medio Metro` como unidades extra: `0.5` de la unidad principal ya es una cantidad válida.

---

## 4. `fractionPack`: empaques fraccionados

Para un empaque de `N` unidades:

- Si `N % 4 == 0` → base **cuarto de empaque** (factor `4` al empaque).
- Si `N % 4 != 0` y `N % 2 == 0` → base **media parte del empaque** (factor `2`).
- Si `N` es impar → no hay fracción exacta; se usa empaque completo o `pack`.

### Presets por defecto

| Preset | Base | Extras | Default |
| :--- | :--- | :--- | :--- |
| **Caja x10** | `Media Caja x10 (5 u)` | `Caja x10 (10 u)` ×2 | Caja x10 |
| **Caja x12** | `Cuarto de Caja x12 (3 u)` | `Media Caja x12 (6 u)` ×2; `Caja x12 (12 u)` ×4 | Caja x12 |
| **Caja x20** | `Cuarto de Caja x20 (5 u)` | `Media Caja x20 (10 u)` ×2; `Caja x20 (20 u)` ×4 | Caja x20 |
| **Caja x24** | `Cuarto de Caja x24 (6 u)` | `Media Caja x24 (12 u)` ×2; `Caja x24 (24 u)` ×4 | Caja x24 |
| **Caja x30** | `Media Caja x30 (15 u)` | `Caja x30 (30 u)` ×2 | Caja x30 |
| **Caja x50** | `Media Caja x50 (25 u)` | `Caja x50 (50 u)` ×2 | Caja x50 |
| **Caja x60** | `Cuarto de Caja x60 (15 u)` | `Media Caja x60 (30 u)` ×2; `Caja x60 (60 u)` ×4 | Caja x60 |
| **Caja x100** | `Cuarto de Caja x100 (25 u)` | `Media Caja x100 (50 u)` ×2; `Caja x100 (100 u)` ×4 | Caja x100 |
| **Docena** | `Cuarto de Docena (3 u)` | `Media Docena (6 u)` ×2; `Docena (12 u)` ×4 | Docena |

`Caja x12` y `Docena` son numéricamente equivalentes; se puede usar una sola plantilla o dos nombres según el negocio.

El nombre de la unidad base siempre incluye el tamaño del empaque y las unidades: `Cuarto de Caja x12 (3 u)`. Así el inventario y los reportes no quedan ambiguos.

---

## 5. `pack` vs `fractionPack`: el tradeoff

No se puede tener al mismo tiempo venta por unidad suelta y precio de caja exacto con precio base entero:

| Tipo | Base | Venta por unidad | Precio de caja |
| :--- | :--- | :---: | :--- |
| `pack` | `Unidad` (1) | Sí | Se redondea contra `N`; puede perder/ganar centavos |
| `fractionPack` | Media/cuarto de empaque | No | Exacto si el precio es múltiplo de 2 o 4 ¢ |

Ejemplo:

- `pack` Caja x30 a `C$100.00` → `10000 / 30 = 333.33 → 333` → caja `C$99.90`.
- `fractionPack` Caja x30 (base media caja) a `C$100.00` → `10000 / 2 = 5000` → caja `C$100.00`.

La regla de negocio es:

- Si el producto se vende por unidad suelta → `pack`.
- Si solo se vende por media/cuarto de caja y se necesita precio exacto → `fractionPack`.

---

## 6. Precisión de precios y C1

Con precio base entero (`int` centavos por unidad base), el precio comercial se calcula como:

```text
precio_base = round(precio_comercial_en_centavos / factor)
precio_comercial_real = precio_base * factor
```

Por eso el factor importa:

| Factor | Precios exactos | Precios con error |
| :---: | :--- | :--- |
| `2` | Centavos pares; `.00`, `.50` | Centavos impares |
| `4` | Múltiplos de 4 ¢; córdobas enteros | `.50` → +2 ¢ por unidad; `.25` → -1 ¢; `.99` → +1 ¢ |

En 10 unidades el error se multiplica por 10; en un quintal de 100 lb, por 100. Los precios en córdobas enteros son exactos con factores `2` y `4`.

Esta es una **mitigación controlada de C1**, no una eliminación total. La solución definitiva sigue siendo precio unitario decimal o precio comercial por línea.

---

## 7. Modelos de datos

### 7.1. `ExtraUnit`

```dart
class ExtraUnit {
  final String name;
  final int conversionFactor; // factor respecto a la unidad base
}
```

### 7.2. Producto

El producto **no** guarda `scaleType`. Guarda su foto de la escala:

```dart
class BaseProduct {
  final String unitName;            // unidad base (ej. "Cuarto de Libra")
  final List<ExtraUnit> extraUnits; // unidades comerciales mayores
  final int defaultUnitIndex;       // 0 = base; 1..N = extraUnits
  final int wholesaleUnitIndex;     // 0 = usar default
}
```

### 7.3. Escala

```dart
class BaseUnitScale {
  final String name;
  final UnitScaleType scaleType;
  final String baseUnit;
  final List<ExtraUnit> units;
  final int defaultUnitIndex;
  final int wholesaleUnitIndex;
}
```

`CreateUnitScale`, `UpdateUnitScale` y `UnitScaleInDb` incluyen `scaleType`. Los documentos viejos sin el campo se interpretan como `custom`.

---

## 8. Fuente de verdad de las escalas por defecto

- Las escalas por defecto viven en el **backend** (`create_default_unit_scales.py`) y se exponen por `GET /api/v1/unit-scales`.
- El frontend **no mantiene** una lista duplicada de presets estándar. `UnitScalePresets.standardPresets` queda vacío; el selector consume las escalas del repositorio.
- Las escalas viejas (`Peso` con gramos, `Volumen` con mililitros, `Longitud` con centímetros, `Tiempo`) se eliminan de las semillas y se limpian de la base de datos de desarrollo. No hay producción con esas escalas.
- `create_unit_scale_if_absent` no actualiza escalas existentes; para los defaults nuevos se usan nombres nuevos y una limpieza explícita de los nombres viejos.
- El campo “Unidad de Medida” del formulario de producto usa `allowFreeText` para conservar la unidad base del preset (`Cuarto de Libra`, `Media Caja x30`, etc.) aunque no esté en el catálogo de unidades. El producto guarda `unitName` como texto libre; la unidad comercial se resuelve con `defaultUnitIndex`.

---

## 9. Selector de presets y editor de escalas

### 9.1. Selector

- `UnitScalePresetSelectorDialog` lista las escalas del backend (las por defecto y las creadas por el usuario).
- Cada tarjeta muestra el `scaleType` como etiqueta.
- Al seleccionar, asigna `baseUnit`, `units`, `defaultUnitIndex` y `wholesaleUnitIndex` al producto.
- El botón “Usar Preset” vuelve a estar visible (`SHOW_UNIT_SCALES=true`).

### 9.2. Editor

- Incluye un selector de **Tipo de escala**.
- Para `fractionPack` y `pack`, incluye un **generador**:
  - Nombre del empaque (Caja, Blíster, Frasco, Docena).
  - Unidades por empaque `N`.
  - Botón “Generar”: calcula base, extras, nombres y factores.
- Para `fractionPack` con `N` impar, muestra error y sugiere `pack` o empaque completo.
- Valida:
  - nombre y unidad base no vacíos;
  - factor entero > 1;
  - nombres de unidades no duplicados (incluida la base);
  - `defaultUnitIndex` y `wholesaleUnitIndex` dentro de rango.
- Al editar una escala existente, advierte que los productos ya creados conservan su copia (la escala es una plantilla, no una referencia viva).
- Al eliminar una escala, advierte que los productos existentes no se modifican.

### 9.3. C7: preset, texto libre y confirmación

El botón “Cargar Preset” dentro de `ExtraUnitsEditorDialog` devuelve también la **unidad base** del preset y el formulario padre actualiza su controlador. La ruta del preset funciona; el flujo de **texto libre** se completa con estas reglas cerradas:

- El campo de unidad libre guarda el **texto visible completo** del controlador (`controller.text.trim()`), no un valor parcial.
- El `validator` se toma desde el controlador: `unitName` debe ser igual al texto visible al guardar; si el controlador está vacío, se rechaza.
- La sincronización se hace **al guardar**: `creationMap['unitName'] = controller.text.trim()`.
- El placeholder `Unidad Base` es solo UI y **no se persiste**.
- **Confirmación única** al aplicar un preset; no duplicar entre el editor de unidades extra y la sección.
- **Criterio de aceptación:** al guardar, `unitName` debe ser igual al texto visible del controlador.

Sin esto, el bug real es que puede guardarse `unitName = "C"`: el primer carácter queda congelado y el validator lo ve no vacío.

---

## 10. `QuantityField`: paso por unidad mínima

`QuantityField` calcula el paso como:

```dart
step = 1 / conversionFactor
```

Eso equivale a una unidad base de la escala:

| Escala | Unidad seleccionada | Factor | Paso |
| :--- | :--- | ---: | ---: |
| Libra | Libra | 4 | `0.25 Libra` |
| Libra | Arroba | 100 | `0.01 Arroba` |
| Libra | Quintal | 400 | `0.0025 Quintal` |
| Litro | Litro | 4 | `0.25 Litro` |
| Metro | Metro | 4 | `0.25 Metro` |
| `fractionPack` x30 | Caja x30 | 2 | `0.5 Caja` |
| `fractionPack` x12 | Caja x12 | 4 | `0.25 Caja` |
| `pack` x30 | Unidad | 1 | `1 u` |
| `pack` x30 | Caja x30 | 30 | `1/30 Caja` (= 1 u) |

- Los botones `+`/`-` y las teclas `+`/`-` usan el mismo paso.
- El campo muestra la equivalencia en unidad base (`= 1 u`, `= 1 Cuarto de Libra`).
- Para pasos con más de 3 decimales, el formateo debe conservar la precisión suficiente para que la cantidad base siga siendo exacta.
- El paso no es global `1.0`; se deriva del factor de la unidad seleccionada.

### 10.1. Regla P1 de múltiplos (implementada)

`QuantityField` aplica una **regla global de múltiplos** sobre la unidad seleccionada:

- La cantidad escrita debe cumplir `displayQuantity × conversionFactor` como entero (con tolerancia de redondeo).
- Si no es múltiplo exacto, muestra un error inline (`Debe ser múltiplo de 0.25`, `Debe ser múltiplo de 0.0025`, etc.) y el formulario no debe guardar.
- La operación de `+`/`-` se hace en **unidades base enteras** cuando no hay `step` explícito: `base = round(current × factor) + direction`, luego `base / factor`. Así el factor 30 llega a `1` y no a `0.99999`.
- `readOnly` ignora botones y teclas.
- La precisión del texto se deriva del paso (`0.25` → 2 decimales; `0.0025` → 4 decimales), no de un mínimo fijo de 3.
- En los flujos de producción revisados, `showButtons: false`: la captura es solo por teclado.

La validación de notas de crédito comparte la misma regla: rechaza cantidades no múltiplas y base `0` en lugar de omitir la línea en silencio.

---

## 11. Precios y edición

- El editor de precios mantiene la edición bidireccional entre precio base y precio comercial.
- La unidad comercial por defecto es `defaultUnitIndex` (Libra, Litro, Metro, Caja).
- Para factores `2`/`4` los precios en córdobas enteros son exactos; los `.50`/`.25`/`.99` pueden redondear. Mostrar el precio comercial real luego del redondeo cuando sea relevante.
- C1 no queda eliminado para `pack` ni para factores personalizados; la wiki lo documenta como limitación.

---

## 12. Reactivación de escalas

- `FeatureFlags.showUnitScales` vuelve a `true` por defecto.
- Se restauran la pestaña “Escalas”, el botón “Usar Preset”, “Cargar Preset”, las rutas y los atajos.
- Se eliminan de las semillas las escalas viejas de gramos/mililitros/centímetros/tiempo.
- La base de datos de desarrollo debe limpiarse de esos documentos viejos; si no, seguirán apareciendo en el selector.
- `time` queda en una nota de wiki para cuando se vendan servicios.

---

## 13. Archivos principales

```text
kardex_app_front/
├── lib/
│   ├── constants/feature_flags.dart                         # SHOW_UNIT_SCALES=true
│   ├── widgets/dialogs/
│   │   ├── unit_scale_preset_selector_dialog.dart           # Selector de escalas del backend
│   │   ├── extra_units_editor_dialog.dart                   # C7 + resultado con baseUnitName
│   │   └── create_product_with_data_dialog.dart             # C7 + preset
│   ├── src/modules/product_catalog/
│   │   ├── units_and_scales/units_and_scales_screen.dart   # Pestaña Escalas visible
│   │   ├── unit_scales/dialogs/create_unit_scale_dialog.dart # Tipo + generador
│   │   ├── unit_scales/panels/unit_scales_panel.dart       # Badge de scaleType
│   │   └── product_list/dialogs/
│   │       ├── extra_units_section.dart                    # C7 + botón preset
│   │       └── form_section.dart                           # Unidad libre (allowFreeText)
│   └── widgets/elements/quantity_field.dart                 # Paso 1/factor
└── packages/kardex_business/lib/src/
    ├── domain/models/unit_scale/unit_scale_model.dart       # scaleType
    └── tools/
        ├── unit_scale_presets.dart                          # Sin presets estándar duplicados
        └── unit_conversion_tool.dart                        # minimumStep / formato
```

---

## 14. Pendientes y límites conocidos

- **`time`:** no se incluye; nota para escalas de servicios (segundo, minuto, hora, día).
- **Etiquetas de unidad en reportes/CSV:** usar la unidad comercial por defecto; no mostrar cantidades base crudas sin unidad.
- **Cambio de base en producto con stock (H9):** advertir/bloquear; la escala es una foto y el stock no se convierte automáticamente.
- **Escalas usadas por productos (M10/M11):** editar/eliminar una escala no propaga a productos existentes; advertir.
- **C1 en `pack` y escalas personalizadas:** el redondeo sigue existiendo; no prometer cero error.
- **Import/export:** las columnas de unidad/factor siguen pendientes (M8/M15).
- **Limpieza de BD de desarrollo:** eliminar `Peso`, `Volumen`, `Longitud`, `Tiempo` viejos.
- **Producción:** la maneja el usuario; no se agrega migración ni guard de producción en este alcance.
- **P1 — tablas/list views `int`:** inventario y transferencia no admiten fracciones en unidad estándar; límite estructural para un bloque futuro.
- **P1 — `defaultUnitIndex = 0`:** la regla considera “superiores” a todas las unidades extra; revisar en escalas personalizadas.
- **P1 — verificación:** `flutter analyze` limpio y `flutter test` 83/83; sin hot reload ni prueba manual de UI.

### Pendiente: bonificaciones en devoluciones y notas de crédito

**En espera.** La app aún no muestra ni explota visualmente las bonificaciones (`bonQuantity`). No se modifica el flujo actual. Cuando se active la UI, se debe definir si son retornables y aplicar simetría de stock/costo en venta, devolución y nota de crédito:

- Si son retornables: reingresar `abs(quantity + bonQuantity)` al stock y usar `cost * (quantity + bonQuantity)` en el costo de devolución.
- Si no son retornables: forzar `bonQuantity: 0` en los ítems devueltos y no mostrarla en el documento.

### Devoluciones directas (deprecadas)

Las devoluciones directas no se tocan en esta fase: se consideran **deprecadas** y serán reemplazadas por **notas de crédito**, que son el flujo objetivo. Cualquier corrección de devoluciones debe hacerse sobre notas de crédito.

---

## 15. Pruebas manuales sugeridas

1. Crear un producto con escala `Libra`: la base debe ser `Cuarto de Libra`, la unidad por defecto `Libra` y el `+` debe sumar `0.25`.
2. Vender `0.25`, `0.5`, `0.75` y `1` Libra; verificar que la cantidad base sea `1`, `2`, `3`, `4`.
3. Cambiar a `Arroba` y verificar que `+` sume `0.01 Arroba` (= 0.25 lb).
4. Crear una escala `fractionPack` para Caja x30: base `Media Caja x30 (15 u)`, extra `Caja x30 (30 u)`, `+` suma `0.5 Caja`.
5. Crear una escala `fractionPack` para Caja x12: base `Cuarto de Caja x12 (3 u)`, `+` suma `0.25 Caja`.
6. Crear una escala `pack` para Caja x30: base `Unidad`, `+` suma `1 u`; al cambiar a Caja, `+` suma `1/30 Caja` y muestra `= 1 u`.
7. Aplicar un preset desde el editor de unidades extra (C7): la unidad base del formulario debe cambiar.
8. Verificar que las escalas viejas de gramos/mililitros/centímetros ya no aparezcan.
9. Verificar que el selector de presets muestre las escalas del backend y las creadas por el usuario.
10. Verificar precios: `C$18.00` exacto, `C$18.50` en factor 4 con +2 ¢/unidad; documentar el resultado.
11. Escribir una unidad libre (“Cuarto de Libra”), cerrar el popup y guardar; verificar que `unitName` sea exactamente el texto visible y no `"C"`.

---

## 16. Reglas P1 implementadas (noviembre 2026)

> Esta sección documenta el comportamiento vigente de cantidades, presentación y borradores. **No cambia los tipos `int` de stock, cantidades base ni dinero.** El working tree sigue **sin commit**.

### 16.1. Base, estándar y superior

| Nivel | Definición | Admite fracciones | Ejemplos |
| :--- | :--- | :---: | :--- |
| **Base** | Fracción comercial mínima; factor `1`; se guarda como `int` | No; es la unidad indivisible | `Cuarto de Libra`, `Media Caja x30`, `Unidad` |
| **Estándar** | Unidad comercial principal de la escala; `product.defaultUnitIndex` | **Sí** | `Libra`, `Litro`, `Metro`, `Caja xN` |
| **Superior** | Unidad extra con factor mayor al estándar | **Solo enteros** | `Arroba`, `Quintal`, `Bidón`, `Rollo` |

La cantidad base siempre es entera. La unidad estándar puede mostrar fracciones (`0.25 Libra`, `1.5 Libra`); las superiores solo se usan cuando la cantidad base es divisible por su factor.

### 16.2. Cambio de unidad: conversión exacta o reset a `0`

Al cambiar la unidad seleccionada:

```text
baseQuantity = displayQuantityAnterior × factorAnterior
nuevaCantidad = baseQuantity / factorNuevo
```

- Si la unidad nueva es **superior**, solo se convierte cuando `nuevaCantidad` es un entero exacto: `25 Libra → 1 Arroba`, `100 Libra → 1 Quintal`.
- Si la unidad nueva es **superior** y la conversión no es exacta, la cantidad se **reinicia a `0`**: `0.5 Libra → 0`, `4 Libra → 0` al pasar a Arroba.
- Si la unidad nueva es la **estándar** o la **base**, se admite la fracción resultante (`1 Libra → 4 Cuarto de Libra` al pasar a la base; `1 Cuarto de Libra → 0.25 Libra` al pasar a la estándar).
- No se muestra una fracción de una unidad superior ni se redondea silenciosamente a la unidad más cercana.
- **Nota:** la semilla estándar define `Arroba = 25 lb`; `4 Libra` no equivale a `1 Arroba`. El caso `4 Libra → 1 Arroba` solo sería válido con una escala personalizada que defina `Arroba = 4 Libra`.

### 16.3. Display con fallback a la unidad estándar

`UnitDisplayFormatter.formatUnitQuantity` decide la unidad de presentación:

1. Si la unidad seleccionada es **superior** (`factor > standardUnitFactor`):
   - Si `baseQuantity % factor == 0`, muestra la cantidad entera en la unidad superior.
   - Si no, muestra `baseQuantity / standardUnitFactor` en la **unidad estándar**.
2. Si la unidad seleccionada es la **estándar** o la **base**, muestra `baseQuantity / factor` (fracciones permitidas).
3. Si faltan metadatos (documentos viejos), conserva el fallback decimal en la unidad seleccionada.

Ejemplos:

- Base `600`, seleccionada `Quintal`, estándar `Libra` (factor 4) → `150 Libra`.
- Base `400`, seleccionada `Quintal` → `1 Quintal`.
- Base `4`, seleccionada `Libra` → `1 Libra`.

La misma regla se aplica a visores, impresoras térmicas, PDFs y stock. Cuando el display cae a la unidad estándar, el precio/costo debe usar el factor estándar (`displayUnitFactor`), no el factor de la unidad seleccionada.

### 16.4. Metadata de línea

Para que el formatter pueda hacer el fallback, las líneas guardan:

| Modelo | Campos |
| :--- | :--- |
| `SaleItem` | `selectedUnitName`, `standardUnitName`, `standardUnitFactor` |
| `EntryItem` | `standardUnitName`, `standardUnitFactor` |
| `ExitItem` | `standardUnitName`, `standardUnitFactor` |
| `AdjustExitItem` | `standardUnitName`, `standardUnitFactor` |
| `TransferItem` | `selectedUnitName`, `standardUnitName`, `standardUnitFactor` |

- Los campos son opcionales y solo se serializan si tienen valor; los documentos viejos siguen siendo válidos.
- `SaleItem.displayUnitFactor` devuelve el factor estándar cuando hubo fallback; así los totales y precios no se calculan con la unidad equivocada.
- `standardUnitFactor` es el factor de la unidad estándar respecto a la base (`Libra = 4`, `Caja x30 = 30` en `pack`).

### 16.5. Búsqueda rápida: no inserta base `0`

`resolveQuickItemQuantity` devuelve `null` (no inserta) cuando:

- La cantidad display es `<= 0`.
- `restrictStock` está activo y el stock disponible es `0`.
- La cantidad base resultante es `<= 0` (ej. `0.1 × 4 = 0.4 → round = 0`).

Con `restrictStock` activo, una cantidad que excede el stock se ajusta al máximo disponible. Sin `restrictStock` (cotización/proforma), se permite una cantidad positiva aunque el stock sea `0`; el backend decide con `LET_NEGATIVE`/LITE.

**La política de stock no cambió:** el frontend mantiene sus bloqueos existentes y el backend sigue siendo la autoridad final. Solo se corrigió la inserción de ítems con base `0`.

### 16.6. Borradores de transferencia `v3`

Formato actual:

```json
{
  "version": 3,
  "rows": [
    {
      "quantity": 1,
      "unitaryCost": 10000,
      "selectedUnitIndex": 2,
      "conversionFactor": 4,
      "selectedUnitName": "Caja x12",
      "baseUnitName": "Cuarto de Caja x12 (3 u)",
      "standardUnitName": "Caja x12",
      "standardUnitFactor": 4
    }
  ]
}
```

- `quantity` y `unitaryCost` siguen siendo **comerciales** (unidad seleccionada), no base.
- Al restaurar: `baseQuantity = savedQuantity × savedFactor`; si hay `averageCost > 0`, `unitaryCost = averageCost × factorSeleccionado`.
- `v2`: reconvierte cantidad con el factor guardado; si la unidad ya no existe, cae a base. No guarda `baseUnitName`, así que un cambio de base en índice `0` se detecta por `selectedUnitName`.
- `v1` (sin unidad) o base cambiada: infiere `defaultUnitIndex`, marca `needsUnitReview` y **permite continuar con advertencia**.
- Si la cantidad base no es divisible por la unidad restaurada, se muestra en unidad base y se explica en la revisión.
- La pantalla muestra el detalle de `TransferDraftUnitReview` (producto, cantidad, base, unidad, costo y motivos).

### 16.7. Limitaciones residuales

- **Tablas/list views `int`:** las tablas y list views de inventario y transferencia guardan cantidad display `int`; no admiten fracciones en la unidad estándar. Es un límite estructural para un bloque futuro.
- **`defaultUnitIndex = 0`:** si el producto usa la base como unidad por defecto, `standardUnitFactor = 1` y la regla considera “superiores” a **todas** las unidades extra. Revisar en escalas personalizadas.
- **Documentos viejos:** sin `standardUnitName`/`standardUnitFactor`, el display conserva el fallback decimal en la unidad seleccionada; no se puede reconstruir la unidad estándar.
- **Pruebas:** `flutter analyze` limpio y `flutter test` 83/83; no se ejecutó hot reload ni prueba manual de UI.
- **Commit:** no se realizó.
