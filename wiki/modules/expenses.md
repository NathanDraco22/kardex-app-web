# Documentación del Módulo: Gastos (`expenses`)

El módulo **Gastos** administra el registro, control, clasificación y reporte de todas las salidas de dinero no relacionadas directamente con costos de mercancía vendida inmediata (gastos operativos generales y pagos directos a proveedores) en `kardex_app_front`.

---

## 1. Arquitectura y Submódulos

Ubicación: `lib/src/modules/expenses/`:

```text
lib/src/modules/expenses/
├── expenses_menu_screen.dart            # Menú principal de gastos
├── operative_expenses/                  # Gastos corrientes y operativos de la empresa
│   ├── cubit/                           # OperativeExpensesCubit
│   ├── dialogs/                         # CreateOperativeExpenseDialog
│   └── view/operative_expenses_screen.dart
├── supplier_expenses/                   # Pagos de servicios o gastos a proveedores
│   ├── cubit/                           # SupplierExpensesCubit
│   └── view/supplier_expenses_view.dart
├── expense_categories/                  # Categorización y centros de costos de gastos
│   ├── cubit/                           # ExpenseCategoriesCubit
│   └── view/expense_categories_view.dart
└── expenses_reports/                    # Reportes y gráficos analíticos de gastos
    ├── cubit/                           # ExpensesReportsCubit
    └── view/expenses_reports_view.dart
```

---

## 2. Detalle de Submódulos Clave

### 2.1. Gastos Operativos (`operative_expenses`)
- **Propósito:** Registro diario de egresos de caja chica o banco para mantenimiento, servicios públicos (luz, agua, internet), alquileres, viáticos o salarios.
- **Vistas:** `OperativeExpensesScreen`.
- **Cubits:** `OperativeExpensesCubit`.
- **Campos del Gasto:** Concepto, Categoría, Monto, Fecha, Método de pago, Sucursal y Comprobante adjunto.

### 2.2. Gastos a Proveedores (`supplier_expenses`)
- **Propósito:** Gestión de egresos asociados a facturas de proveedores por conceptos de transporte, servicios de flete, logística o compras complementarias.
- **Vistas:** `SupplierExpensesView`.
- **Cubits:** `SupplierExpensesCubit`.

### 2.3. Categorías de Gastos (`expense_categories`)
- **Propósito:** Creación y mantenimiento de las etiquetas o categorías contables (ej. "Servicios Básicos", "Nómina", "Mantenimiento", "Logística").
- **Vistas:** `ExpenseCategoriesView`.
- **Cubits:** `ExpenseCategoriesCubit`.

### 2.4. Reportes de Gastos (`expenses_reports`)
- **Propósito:** Análisis agregado de egresos por período y por categoría para identificar desviaciones presupuestarias.
- **Vistas:** `ExpensesReportsView`.
- **Cubits:** `ExpensesReportsCubit`.

---

## 3. Repositorios y Fuentes de Datos Involucrados

| Submódulo | DataSource | Repositorio |
| :--- | :--- | :--- |
| Gastos | `ExpensesDataSource` | `ExpensesRepository` |
| Categorías de Gastos | `ExpenseCategoriesDataSource` | `ExpenseCategoriesRepository` |

---

## 4. Rutas en `app_router.dart`

- `/expenses`: Menú principal del módulo de gastos.
- `/expenses/operative`: Gastos operativos.
- `/expenses/supplier`: Gastos asociados a proveedores.
- `/expenses/categories`: Categorías de gastos.
- `/expenses/reports`: Reportes y análisis de gastos.
