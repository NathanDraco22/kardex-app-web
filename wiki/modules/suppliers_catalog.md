# Documentación del Módulo: Catálogo de Proveedores (`suppliers_catalog`)

El módulo **Catálogo de Proveedores** gestiona el directorio de abastecedores de mercancía y servicios de la empresa, sus condiciones comerciales, plazos de pago y cuentas corrientes en `kardex_app_front`.

---

## 1. Arquitectura y Submódulos

Ubicación: `lib/src/modules/suppliers_catalog/`:

```text
lib/src/modules/suppliers_catalog/
├── cubit/                                       # SuppliersCubit, SuppliersState
├── dialogs/                                     # CreateSupplierDialog, SupplierDetailDialog
├── view/                                        # Vistas responsivas del catálogo
│   ├── suppliers_catalog_screen.dart            # Entrada y selector de vista según dispositivo
│   ├── mobile/                                  # suppliers_catalog_mobile_screen.dart
│   ├── web/                                     # suppliers_catalog_web_screen.dart
│   └── widgets/                                 # Tablas, tarjetas y componentes de proveedor
```

---

## 2. Detalle de Submódulos Clave

### 2.1. Gestión y Directorio de Proveedores
- **Propósito:** Mantener el registro fidedigno de los proveedores comerciales:
  - Razón social y nombre de contacto comercial.
  - Registro tributario / RNC / NIT.
  - Teléfonos de contacto, correo electrónico de pedidos y dirección fiscal.
  - Días de crédito acordados para pagos a plazo.
- **Vistas:**
  - `SuppliersCatalogScreen`: Despliega la versión Web con tabla enriquecida o Mobile con tarjetas compactas.
- **Cubits:**
  - `SuppliersCubit`: Gestiona estados `SuppliersInitial`, `SuppliersLoading`, `SuppliersLoaded`, `SuppliersError`. Carga y filtra proveedores por búsqueda de texto y estado activo/inactivo.
- **Diálogos:**
  - `CreateSupplierDialog`: Modal interactivo para crear y actualizar proveedores.

### 2.2. Integración con Entradas de Inventario y Gastos
- Los proveedores registrados aquí alimentan automáticamente:
  - El selector de proveedor en `InventoryEntryScreen` (`lib/src/modules/inventory/inventory_entry/`).
  - Los egresos por facturas de proveedor en `SupplierExpensesView` (`lib/src/modules/expenses/supplier_expenses/`).

---

## 3. Repositorios y Fuentes de Datos Involucrados

| Submódulo | DataSource | Repositorio |
| :--- | :--- | :--- |
| Proveedores | `SuppliersDataSource` | `SuppliersRepository` |

---

## 4. Rutas en `app_router.dart`

- `/suppliers`: Pantalla principal del catálogo de proveedores.
