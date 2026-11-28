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
- **Flujo de Pago (Crear Recibo → Abonar / Liquidar):**
  1. Selección de factura o selección de cliente con saldo.
  2. Definición del monto a abonar por factura.
  3. Captura del pago con el mismo diálogo de facturación: Efectivo, Tarjeta o Transferencia; en efectivo permite moneda primaria o secundaria, monto recibido y cambio; en tarjeta/transferencia exige banco y referencia.
  4. Emisión automática de recibo de caja (`ReceiptInDb`) con `paymentMethod`, `bankReference` y `paymentDetail`.
  5. Reducción proporcional del saldo de la factura y del balance global del cliente.
  6. Impresión de comprobante de pago mediante `ReceiptPrinter`; el recibo muestra `Recibido`, `Cambio` y `Total Cobrado`.

- **Flujo de Abono Rápido:** el botón `Abono` de la cabecera captura el pago con `FastPaymentModal`. La decisión y los montos viven en `AbonoPaymentPolicy`; el recibo resultante usa `paymentDetail` y muestra `Recibido`/`Cambio` igual que el resto de recibos.
- **Un solo método por recibo:** el modelo actual guarda un `paymentMethod` y un `paymentDetail` por recibo; no se admite pago mixto (parte efectivo, parte tarjeta) en un mismo abono.
- **Notas por monto:** las notas de crédito `CreditNoteType.monto` no vinculadas se distribuyen entre las facturas con saldo disponible; el mediador deduplica por `id`, el modal muestra el total y bloquea el abono si las notas superan la capacidad.
- **Etiquetas:** los recibos usan `Recibido` y `Cambio`; las facturas conservan `Pagó con` y `Cambio`.

#### Modos del Abono Rápido

Tarjeta y transferencia mantienen su flujo con referencia bancaria y sin cambio en ambos modos.

| `useAbonoReceivedAmount` | Método | Captura | Regla |
| :---: | :--- | :--- | :--- |
| `false` | Efectivo | Un solo monto | Se aplica hasta la deuda; el excedente sobre la deuda es cambio. |
| `false` | Tarjeta/transferencia | Un solo monto | Limitado a la deuda; exige referencia; sin `paymentDetail`. |
| `true` | Efectivo | "Monto a Abonar" + "Dinero Recibido" | El abono no supera la deuda; recibido ≥ abono; cambio = recibido − abono. Recibido vacío se asume igual al abono. |
| `true` | Tarjeta/transferencia | Un solo monto | Igual que el modo apagado. |

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
