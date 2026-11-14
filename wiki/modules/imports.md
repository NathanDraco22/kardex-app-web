# Documentación del Módulo: Importaciones CSV (`imports`)

El módulo **Importaciones CSV** permite la carga masiva de inventario, clientes y proveedores desde archivos CSV. Está disponible para usuarios con acceso al módulo de Configuraciones.

---

## 1. Arquitectura y Archivos

Ubicación: `lib/src/modules/imports/`:

```text
lib/src/modules/imports/
├── imports_screen.dart                 # Pantalla principal y flujo de selección de archivos
├── cubit/
│   ├── imports_cubit.dart              # Orquestación de importaciones y refresco de cachés
│   └── imports_state.dart              # Estados Initial, Loading, Success y Error
├── dialogs/
│   ├── import_confirmation_dialog.dart # Confirmación con archivo, sucursal y advertencias
│   └── import_result_dialog.dart       # Resultado exitoso o error detallado
├── tools/import_templates.dart         # Plantillas CSV por tipo de importación
└── widgets/import_option_card.dart      # Tarjeta premium de cada tipo de importación
```

Capa de datos en `packages/kardex_business`:

- `packages/kardex_business/lib/src/data/imports_data_source.dart`
- `packages/kardex_business/lib/src/domain/repositories/imports_repository.dart`
- `packages/kardex_business/lib/src/domain/models/imports/import_result.dart`
- `packages/kardex_business/lib/src/domain/models/imports/import_type.dart`

---

## 2. Tipos de Importación

| Tipo | Endpoint | Requiere sucursal | Descripción |
| :--- | :--- | :---: | :--- |
| Inventario inicial | `POST /api/v1/imports/init-inventory` | Sí | Crea productos, stock y documento de inventario inicial. Solo una vez por sucursal. |
| Inventario | `POST /api/v1/imports/inventory` | Sí | Crea productos y carga existencias adicionales. |
| Clientes | `POST /api/v1/imports/clients` | Sí | Crea clientes, límites de crédito y saldos iniciales. |
| Proveedores | `POST /api/v1/imports/suppliers` | No | Crea proveedores con datos de contacto. |

Todos los endpoints reciben `multipart/form-data` con el campo `file`. Los tres primeros aceptan el header de sucursal `X-Branch` o `branch-id`.

---

## 3. Flujo de Usuario

1. El usuario entra a **Configuraciones → Importaciones CSV** (`/settings/imports`).
2. Selecciona una tarjeta y descarga la plantilla si lo necesita.
3. `file_picker` abre el selector restringido a `.csv`.
4. Se valida tamaño máximo (10 MB) y extensión.
5. Se muestra un diálogo de confirmación con archivo, tamaño, sucursal y advertencias.
6. El `ImportsCubit` llama al repositorio y muestra un overlay de carga.
7. Al finalizar, se muestra un diálogo con el resultado y el `importedCount`.
8. Si se importaron clientes o proveedores, se refrescan sus repositorios en memoria.

---

## 4. Plantillas CSV

Las plantillas se generan en el cliente con BOM UTF-8 para compatibilidad con Excel y se guardan con `CsvExportTool.saveCsvContent`.

### Inventario inicial / inventario

```text
name,description,code,brandName,unitName,categoryName,tags,hasIva,isActive,quantity,cost,price,price2,price3,price4
```

### Clientes

```text
name,cardId,phone,address,location,email,group,creditLimit,initialBalance
```

### Proveedores

```text
name,cardId,email,phone
```

Los montos se interpretan como decimales (`12.50`) y se convierten a centavos. `quantity` debe ser un entero. `tags` acepta una lista JSON o valores separados por `;`.

---

## 5. Manejo de Errores

El backend valida columnas obligatorias, codificación, delimitador, filas vacías y tipos de datos. Los errores se devuelven como `400` con mensajes del tipo:

```text
Fila 12: 'price' no es un número válido ('abc')
```

El frontend traduce ese `detail` a un diálogo de error legible.

---

## 6. Rutas y Permisos

- Ruta: `/settings/imports` (nombre `imports`).
- Permiso de UI: `Modules.settings`.
- Accesos: tarjeta en `SettingsScreen` y submenú de Configuraciones en `home_modules_registry.dart`.
- El backend exige autenticación JWT en los cuatro endpoints.
