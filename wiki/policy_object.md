# Policy Object — Decisiones de negocio centralizadas

> **Patrón:** `Policy Object` (también llamado `Domain Policy`).
> **Alias interno:** `Decision Object`.
> **Implementación de referencia:** `AppSettingsPolicy` en `packages/kardex_business/lib/src/core/policies/app_settings/`.

> **Ubicación obligatoria (frontend y backend):** toda policy vive en `packages/kardex_business/lib/src/core/policies/<dominio>/`, con una subcarpeta por dominio. No se crean policies en `lib/`, en `lib/src/modules/` ni fuera del paquete de negocio. El backend replica la misma estructura en `packages/kardex-business/src/kardex/core/policies/<dominio>/`.

---

## 1. Qué problema resuelve

Cuando una decisión depende de varias banderas, la lógica se repite y se desalinea:

```dart
final shouldCharge =
    settings.useShifts && settings.chargeConvertedOrdersToShift;
final requiresShift =
    shouldCharge && settings.requireShiftForConvertedOrders;
```

Ese bloque aparece en varias pantallas, cada una puede interpretarlo distinto y agregar una condición nueva obliga a buscar todos los lugares.

El `Policy Object` concentra la decisión en un solo objeto puro:

```dart
final policy = getIt<AppSettingsCubit>().policy;
final shiftPolicy = policy.convertedOrderShiftPolicy;

if (shiftPolicy.requiresOpenShift) {
  // ...
}
```

La pantalla ya no combina banderas: pregunta por la decisión de negocio.

---

## 2. Contrato del patrón

Un `Policy`:

- Vive en `packages/kardex_business/lib/src/core/policies/<dominio>/`, con una subcarpeta por dominio. No se admiten policies sueltas en `core/policies/` ni en otras capas.
- Es **Dart puro**: no importa Flutter, no hace HTTP, no consulta repositorios.
- Recibe su contexto por constructor o parámetro (por ejemplo, `AppSettingModel`).
- No muta estado.
- Devuelve resultados tipados.

### Regla de retorno

| Situación | Retorno |
| :--- | :--- |
| Una decisión binaria | `bool` |
| Varias decisiones excluyentes | `enum` |
| Un resultado que puede existir o no | Objeto opcional (`T?`) |
| Un resultado compuesto que siempre existe | Objeto respuesta |

Ejemplos de `AppSettingsPolicy`:

```dart
bool get hasExchangeRate;
ConvertedOrderShiftPolicy get convertedOrderShiftPolicy;
SecondaryCurrencyPaymentTerms? get secondaryCurrencyPaymentTerms;
InvoiceDisplayConfig get invoiceDisplayConfig;
```

Los enums pueden llevar comportamiento para que la UI no lo reinterprete:

```dart
enum ConvertedOrderShiftPolicy {
  never(linkToShift: false, requiresOpenShift: false),
  optional(linkToShift: true, requiresOpenShift: false),
  required(linkToShift: true, requiresOpenShift: true);

  const ConvertedOrderShiftPolicy({
    required this.linkToShift,
    required this.requiresOpenShift,
  });

  final bool linkToShift;
  final bool requiresOpenShift;
}
```

---

## 3. Composición con el cubit

El `Policy` no es un singleton global. El cubit es el dueño del estado y lo construye a partir de `currentSettings`:

```dart
class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsPolicy get policy =>
      AppSettingsPolicy(currentSettings ?? AppSettingModel.defaults);
}
```

Los consumidores usan:

```dart
final policy = getIt<AppSettingsCubit>().policy;
```

o, en un widget reactivo:

```dart
final policy = context.watch<AppSettingsCubit>().policy;
```

El cubit **no replica cada bandera como getter**. Solo expone `policy` y el estado crudo necesario (`currentSettings`). Añadir `bool get useOrders => policy.useOrders` vuelve a crear el problema que el patrón intenta resolver: dos formas de acceder a la misma decisión y una superficie pública que crece con cada ajuste.

Para los modelos profundos que no tienen acceso al cubit se mantiene el patrón de **resolver inyectado**:

```dart
InvoiceRounding.configureEnabledResolver(
  () => policy.roundUpInvoiceTotals,
);
BaseInvoice.configureDisplayConfigResolver(
  () => policy.invoiceDisplayConfig,
);
```

Esos closures leen el `policy` actual, así que siguen las mismas transiciones que el cubit.

---

## 4. Transiciones de estado

`policy` es una vista calculada de `currentSettings`, no un estado paralelo:

| Estado | `policy` |
| :--- | :--- |
| `Initial` / primera carga | defaults de `AppSettingModel` |
| `Loading` con caché previa | última configuración confirmada |
| `Loaded` | nueva configuración |
| `Saving` | configuración anterior (no aplica cambios a medias) |
| `Error` al guardar | `lastSettings` o última configuración confirmada |
| `clear` / logout | defaults |

El formulario de settings mantiene su propio draft local y solo se sincroniza cuando llega `Loaded`. Por eso puede mostrar cambios sin que el resto de la app los vea antes de guardar.

---

## 5. Cómo agregar una policy

1. Identifica una decisión repetida o con muchos `if`.
2. Crea `packages/kardex_business/lib/src/core/policies/<dominio>/<nombre>_policy.dart`.
3. Define el contexto mínimo que necesita.
4. Elige el retorno según la regla anterior.
5. Expórtala en `packages/kardex_business/lib/src/core/core.dart`.
6. Si depende de ajustes globales, expón un getter en el cubit correspondiente.
7. Agrega tests con la tabla de decisión completa.
8. Documenta la tabla en la wiki del módulo.

### Cuándo no usarlo

- Un `if` local y simple que no se repite.
- Lógica que necesita I/O, transacciones o repositorios: eso es un **Core / Orchestrator**, no una policy.
- Una decisión que todavía no tiene consumidores claros.

---

## 6. Relación con el backend

El mismo patrón aplica al servidor, pero con una separación adicional:

- **Policy:** decisión pura, recibe modelos y devuelve `bool`, `Enum` o un `@dataclass` de resultado.
- **Core / Orchestrator:** consulta Mongo, maneja transacciones y llama a la policy.

En el backend, `AppSettingsTool` sigue siendo el acceso a la configuración y `AppSettingsPolicy` interpreta esas banderas. Las policies viven en `packages/kardex-business/src/kardex/core/policies/<dominio>/`, con la misma separación entre policy pura y orquestador.

---

## 7. Referencias

- `packages/kardex_business/lib/src/core/policies/app_settings/app_settings_policy.dart`
- `packages/kardex_business/lib/src/core/policies/receipts/abono_payment_policy.dart`
- `lib/cubits/app_settings/app_settings_cubit.dart`
- `wiki/modules/settings.md`
- `test/app_settings_policy_test.dart`
- `test/abono_payment_policy_test.dart`
- `test/app_settings_cubit_policy_test.dart`
