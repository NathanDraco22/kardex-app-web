# Documentación del Módulo: Herramientas Avanzadas (`advanced_tools`)

El módulo **Herramientas Avanzadas** proporciona funcionalidades de análisis predictivo, estadísticas detalladas de rotación de productos y proyecciones de venta para la toma de decisiones estratégicas en `kardex_app_front`.

---

## 1. Arquitectura y Submódulos

Ubicación: `lib/src/modules/advanced_tools/`:

```text
lib/src/modules/advanced_tools/
├── advanced_tools_screen.dart           # Menú principal de herramientas avanzadas
├── product_stats/                       # Estadísticas avanzadas de rotación y comportamiento
│   └── product_stats_screen.dart        # Gráficas de ventas, devoluciones y demanda
└── sale_projection/                     # Modelos de proyección de ventas e inventario
    └── sale_projection_screen.dart      # Estimación de requerimientos de abastecimiento
```

---

## 2. Detalle de Submódulos Clave

### 2.1. Estadísticas de Producto (`product_stats`)
- **Propósito:** Analizar el rendimiento histórico de artículos seleccionados:
  - Frecuencia de compra de clientes por producto.
  - Tasa de devolución y reclamos.
  - Velocidad de rotación y días promedio de inventario en bodega.
- **Vistas:** `ProductStatsScreen`.
- **Integraciones:** Gráficos estadísticos y métricas de consumo temporal.

### 2.2. Proyección de Ventas (`sale_projection`)
- **Propósito:** Predecir cuándo se agotará un producto según el ritmo de ventas actual y calcular la fecha sugerida de reorden para evitar quiebres de stock.
- **Vistas:** `SaleProjectionScreen`.
- **Utilidad Operativa:** Asiste al área de compras e inventario al generar pedidos sugeridos hacia los proveedores.

---

## 3. Repositorios y Fuentes de Datos Involucrados

| Submódulo | DataSource | Repositorio |
| :--- | :--- | :--- |
| Estadísticas y Proyecciones | `StatsDataSource` / `ReportsDataSource` | `ReportsRepository` |

---

## 4. Rutas en `app_router.dart`

- `/advanced-tools`: Menú de herramientas avanzadas.
- `/advanced-tools/product-stats`: Estadísticas de productos.
- `/advanced-tools/sale-projection`: Proyecciones de venta.
