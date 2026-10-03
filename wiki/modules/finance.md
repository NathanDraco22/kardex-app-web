# Documentación del Módulo: Finanzas (`finance`)

El módulo **Finanzas** proporciona analítica financiera, balances diarios, resúmenes ejecutivos por sucursal, control de ingresos/egresos, auditoría de facturas pagadas y estados de cuenta en `kardex_app_front`.

---

## 1. Arquitectura y Submódulos

Ubicación: `lib/src/modules/finance/`:

```text
lib/src/modules/finance/
├── finances_menu_screen.dart            # Menú principal de finanzas
├── branch_daily_summary/                # Cierre diario por sucursal
├── branch_executive_summary/            # Resumen ejecutivo consolidado
├── daily_operations_results/            # Resultados de operaciones diarias (Caja)
├── range_finance_report/                # Reporte financiero por rango de fechas
├── client_accounts/                     # Cuentas corrientes y saldos de clientes
├── client_movements/                    # Estado de cuenta y movimientos detallados
├── paid_invoices/                       # Facturas completamente liquidadas
└── detail_invoice_history/              # Auditoría detallada con desglose contable
```

---

## 2. Detalle de Submódulos Clave

### 2.1. Resumen Diario de Sucursal (`branch_daily_summary`)
- **Propósito:** Mostrar las métricas consolidadas del día en curso para la sucursal seleccionada:
  - Total de ventas brutas y netas.
  - Cobros en efectivo, transferencias y tarjetas.
  - Monto otorgado a crédito.
  - Total de devoluciones y salidas extraordinarias.
- **Vistas:** `BranchDailySummaryScreen`.
- **Cubits:** `BranchDailySummaryCubit`.

### 2.2. Resumen Ejecutivo (`branch_executive_summary`)
- **Propósito:** Tablero de control de alto nivel para dueños o administradores, integrando márgenes de utilidad estimada, costos de mercancía vendida y comparación entre períodos.
- **Vistas:** `BranchExecutiveSummaryScreen`.

### 2.3. Resultados de Operaciones Diarias (`daily_operations_results`)
- **Propósito:** Control operativo de caja y arqueo. Compara los ingresos reportados por el sistema frente a los montos físicos contados por los cajeros al cierre de jornada.
- **Vistas:** `DailyOperationsResultsScreen`.
- **Integración con Usuarios:** Soporta filtrado por `userId` para ver el balance individual de cada cajero/vendedor.

### 2.4. Reporte Financiero por Rango (`range_finance_report`)
- **Propósito:** Generación de balances consolidados entre dos fechas arbitrarias (`startDate`, `endDate`), con exportación a PDF y Excel.
- **Vistas:** `RangeFinanceReportScreen`.
- **Cubits:** `RangeFinanceReportCubit`.

### 2.5. Cuentas y Movimientos de Clientes (`client_accounts` & `client_movements`)
- **Propósito:** Visualización del libro mayor de cada cliente: facturas emitidas, recibos aplicados, notas de devolución y saldo acumulado.
- **Vistas:** `ClientAccountScreen`, `ClientMovementsScreen`.

---

## 3. Repositorios y Fuentes de Datos Involucrados

| Submódulo | DataSource | Repositorio |
| :--- | :--- | :--- |
| Reportes Financieros | `ReportsDataSource` | `ReportsRepository` |
| Facturas y Cobros | `InvoiceDataSource`, `ReceiptDataSource` | `InvoiceRepository`, `ReceiptRepository` |
| Movimientos de Cliente | `ClientDataSource` | `ClientRepository` |

---

## 4. Rutas en `app_router.dart`

- `/finances`: Menú principal del módulo financiero.
- `/finances/branch-daily-summary`: Cierre diario de la sucursal.
- `/finances/branch-executive-summary`: Resumen ejecutivo.
- `/finances/daily-operations-results`: Resultados de operaciones diarias.
- `/finances/range-report`: Reporte financiero por rango de fechas.
- `/finances/client-accounts`: Estados de cuenta de clientes.
- `/finances/paid-invoices`: Facturas pagadas.
