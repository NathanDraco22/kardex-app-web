# Documentación del Módulo: Cuentas Pendientes (`pending_accounts`)

El módulo **Cuentas Pendientes** (Cuentas por Cobrar) controla las líneas de crédito otorgadas a clientes, las facturas pendientes de pago, el registro de abonos y el seguimiento de transacciones por sesión de crédito en `kardex_app_front`.

---

## 1. Arquitectura y Submódulos

Ubicación: `lib/src/modules/pending_accounts/`:

```text
lib/src/modules/pending_accounts/
├── pending_accounts_menu_screen.dart            # Menú principal de cuentas por cobrar
├── unpaid_clients/                              # Cartera de clientes con deuda activa
│   ├── cubit/                                   # UnpaidClientsCubit
│   └── unpaid_clients_screen.dart               # Pantalla de clientes deudores
├── invoice_payments/                            # Registro y detalle de pagos a facturas
│   ├── cubit/                                   # InvoicePaymentsCubit
│   ├── invoice_payments_menu_screen.dart        # Menú de gestión de pagos
│   └── invoice_payments_detail_screen.dart      # Detalle y aplicación de abonos por factura
└── pending_client_transactions/                 # Sesiones de crédito y transacciones
    ├── cubit/                                   # CreditSessionTransactionsCubit
    ├── pending_client_transactions_menu_screen.dart
    └── credit_session_transactions_screen.dart
```

---

## 2. Detalle de Submódulos Clave

### 2.1. Clientes Deudores (`unpaid_clients`)
- **Propósito:** Mostrar una vista consolidada de todos los clientes que tienen un saldo pendiente (`balance > 0`).
- **Vistas:** `UnpaidClientsScreen`.
- **Cubits:** `UnpaidClientsCubit`.
- **Métricas:**
  - Monto total adeudado.
  - Fecha de la factura más antigua (antigüedad de saldo).
  - Límite de crédito disponible vs utilizado.
- **Acciones:**
  - Acceso directo al estado de cuenta del cliente y al historial de movimientos.
  - Botón de cobro rápido para abrir el diálogo de registro de abono.

### 2.2. Pagos y Abonos de Facturas (`invoice_payments`)
- **Propósito:** Registrar ingresos de dinero asociados a una o varias facturas a crédito pendientes.
- **Vistas:** `InvoicePaymentsMenuScreen`, `InvoicePaymentsDetailScreen`.
- **Cubits:** `InvoicePaymentsCubit`.
- **Flujo de Pago:**
  1. Selección de factura o selección de cliente con saldo.
  2. Definición del monto del abono y método de pago (Efectivo, Transferencia, Cheque).
  3. Emisión automática de recibo de caja (`ReceiptInDb`).
  4. Reducción proporcional del saldo de la factura y del balance global del cliente.
  5. Impresión de comprobante de pago mediante `ReceiptPrinter`.

### 2.3. Transacciones por Sesión de Crédito (`pending_client_transactions`)
- **Propósito:** Trazabilidad detallada de los cargos y abonos efectuados dentro de una sesión o período crediticio específico de un cliente.
- **Vistas:** `PendingClientTransactionsMenuScreen`, `CreditSessionTransactionsScreen`.
- **Cubits:** `CreditSessionTransactionsCubit`.

---

## 3. Repositorios y Fuentes de Datos Involucrados

| Concepto | DataSource | Repositorio |
| :--- | :--- | :--- |
| Facturas a Crédito | `InvoiceDataSource` | `InvoiceRepository` |
| Recibos y Abonos | `ReceiptDataSource` | `ReceiptRepository` |
| Cuentas de Cliente | `ClientDataSource` | `ClientRepository` |

---

## 4. Rutas en `app_router.dart`

- `/pending-accounts`: Menú principal de cuentas por cobrar (restringido a sucursales comerciales).
- `/pending-accounts/unpaid-clients`: Clientes con saldo pendiente.
- `/pending-accounts/invoice-payments`: Listado y aplicación de abonos.
- `/pending-accounts/pending-client-transactions`: Transacciones de crédito.
