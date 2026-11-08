# Documentación del Módulo: Escalas de Unidades (`unit_scales`)

El módulo **Escalas de Unidades (`UnitScale`)** centraliza plantillas reutilizables de conversión de unidades de medida en `kardex_app_front`. Permite a los administradores del sistema definir escalas universales (como Peso, Volumen, Longitud y Tiempo) o personalizadas, simplificando la configuración de productos al evitar tener que ingresar manualmente unidades extras y factores multiplicadores repetitivos en cada ficha de artículo.

---

## 1. Arquitectura y Estructura de Archivos

```text
lib/
└── src/
    └── modules/product_catalog/
        └── unit_scales/
            ├── cubit/
            │   ├── read_unit_scales_cubit.dart    # Carga y filtrado de escalas
            │   ├── read_unit_scales_state.dart
            │   ├── write_unit_scale_cubit.dart    # Creación, edición y eliminación
            │   └── write_unit_scale_state.dart
            ├── dialogs/
            │   └── create_unit_scale_dialog.dart  # Diálogo de creación y edición con validaciones
            └── unit_scales_screen.dart            # Pantalla de gestión con búsqueda y tarjetas
```

En la capa de negocio (`packages/kardex_business`):
```text
packages/kardex_business/lib/src/
├── domain/models/unit_scale/
│   └── unit_scale_model.dart               # Modelos inmutables (UnitScaleInDb, BaseUnitScale, ExtraUnit)
├── domain/repositories/
│   └── unit_scales_repository.dart         # Repositorio de escalas con caché local
└── data/
    └── unit_scales_data_source.dart        # DataSource HTTP hacia /api/v1/unit-scales
```

---

## 2. Modelos de Dominio (`unit_scale_model.dart`)

```dart
class ExtraUnit {
  final String name;          // Nombre de la unidad (ej. "Libra", "Kilogramo")
  final int conversionFactor; // Factor respecto a la unidad base (ej. 454, 1000)
}

class BaseUnitScale {
  final String name;                  // Nombre de la escala (ej. "Peso")
  final String baseUnit;              // Unidad base mínima (ej. "Gramo", factor = 1)
  final List<ExtraUnit> units;        // Unidades hijas con sus factores
  final int defaultUnitIndex;         // Índice sugerido para venta al detalle
  final int wholesaleUnitIndex;       // Índice sugerido para venta mayorista
}

class UnitScaleInDb extends BaseUnitScale {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
}
```

---

## 3. Escalas por Defecto en Servidor

Al inicializarse el backend, se generan automáticamente 4 escalas estándar:

1. **Peso:** Base `Gramo` | `Onza` (x28), `Libra` (x454), `Kilogramo` (x1000), `Quintal` (x45400).
2. **Volumen:** Base `Mililitro` | `Litro` (x1000), `Galón` (x3785).
3. **Longitud:** Base `Centímetro` | `Metro` (x100), `Yarda` (x91).
4. **Tiempo:** Base `Segundo` | `Minuto` (x60), `Hora` (x3600), `Día` (x86400).

---

## 4. Interfaz de Usuario y Flujo de Operación

### 4.1. Pantalla de Administración (`unit_scales_screen.dart`)
- **Búsqueda en Vivo:** Filtra al instante por nombre de escala, unidad base o cualquiera de sus unidades derivadas.
- **Tarjetas Descriptivas:** Muestran el nombre de la escala, la unidad base mínima resaltada con chip azul y las equivalencias multiplicadoras en chips ordenados (ej. `1 Libra = 454 Gramo`).
- **Acciones:**
  - Botón flotante para crear nuevas escalas.
  - Botón de edición en cada tarjeta que abre el diálogo pre-cargado.
  - Botón de eliminación con confirmación interactiva mediante `DialogManager.showConfirmDialog`.

### 4.2. Diálogo Interactivo (`create_unit_scale_dialog.dart`)
- **Unidad Base:** Configuración de nombre y unidad mínima indivisible.
- **Lista Dinámica de Unidades:** Permite agregar o remover unidades adicionales especificando su nombre y factor multiplicador entero (ej. `Caja` con factor `24`).
- **Configuración de Sugerencias:**
  - Selector de unidad por defecto para ventas comunes (dropdown interactivo).
  - Selector de unidad sugerida para tarifas de mayoreo.
- **Validaciones:**
  - El factor multiplicador debe ser mayor a 1.
  - No se permiten nombres de unidades duplicados dentro de la misma escala.
  - Requiere al menos una unidad adicional además de la unidad base.

---

## 5. Navegación y Rutas

- **Ruta GoRouter:** `/product-catalog/unit-scales` (nombre canónico: `RouteNames.unitScales`).
- **Acceso:** Disponible como tarjeta en el menú principal del catálogo de productos ([`product_catalog_menu_screen.dart`](file:///c:/Users/sytru/Developer/Projects/kardex_app/kardex_app_front/lib/src/modules/product_catalog/view/product_catalog_menu_screen.dart)).
