# Guía de Arquitectura y Estándares del Proyecto (Kardex App Front)

Este documento describe la arquitectura, estructura de archivos y patrones de diseño utilizados en este proyecto de Flutter. Cualquier agente (IA) o desarrollador que trabaje en este código **debe** apegarse estrictamente a estas directrices para asegurar la uniformidad, escalabilidad y mantenimiento del proyecto.

## 1. Arquitectura General y Patrón de Módulos

El proyecto sigue una arquitectura fuertemente modular basada en la separación de responsabilidades y el uso del patrón **BLoC (Cubit)** para la gestión de estados. 

Cada módulo de la aplicación (por ejemplo, `units`, `client_catalog`, `inventory`) implementa o respeta el siguiente flujo:
1. **Modelos (Domain):** Representación de datos y abstracción en objetos (DTOs). 
2. **DataSource (Data):** Entidades encargadas exclusivamente de comunicarse con el origen de los datos (ej. API REST / Backend FastAPI).
3. **Repositorios (Domain/Repositories):** Capa intermedia que sirve de fuente de verdad para la aplicación, maneja la caché en memoria y mapea los mapas (`Map<String, dynamic>`) crudos que provienen del DataSource hacia Modelos fuertemente tipados.
4. **Cubits (Lógica de Negocio y Estado):** Clases encargadas de tener comunicación con los Repositorios, emitir diferentes estados y reaccionar a los eventos generados por la Vista.
5. **Vista (UI):** Interfaces construidas en base a los estados provistos por el Cubit utilizando `BlocProvider` y `BlocBuilder/context.watch()`.

### Estructura del Router
El enrutamiento se maneja de forma declarativa. Las rutas se exponen e interactúan de manera centralizada frecuentemente localizadas en `lib/config/app_router.dart` (usualmente mediante el paquete `go_router`). 

---

## 2. Estructura y Orden de Directorios

El núcleo del proyecto reside en `lib/`:

```text
lib/
├── config/              # Configuraciones globales (app_router.dart, app_theme.dart, etc)
├── constants/           # Constantes globales de la app (colores, medidas, tamaños)
├── cubits/              # Cubits globales o legacy que afectan a múltiples módulos (ej. AppModeCubit)
├── src/                 # Contenido central modularizado e inyectado
│   ├── core/            # Archivos y lógicas de núcleo compartidas
│   ├── data/            # ARCHIVOS DATA SOURCE (*_data_source.dart)
│   ├── domain/          
│   │   ├── models/      # Modelos de datos agrupados por concepto
│   │   ├── repositories/# ARCHIVOS DE REPOSITORIO (*_repository.dart)
│   │   ├── responses/   # Modelos para parsear envolturas genéricas como ListResponses
│   │   └── query_params/# Parámetros de URLs centralizados
│   ├── modules/         # MÓDULOS DE VISTA Y LÓGICA (UI + sus Cubits)
│   │   ├── product_catalog/
│   │   │   └── units/   # Ejemplo de un submódulo
│   │   │       ├── cubit/ # Archivos *_cubit.dart y *_state.dart
│   │   │       ├── dialog/# Cuadros de diálogo y modales del módulo
│   │   │       ├── web/   # Vistas web-specific
│   │   │       └── units_screen.dart # Pantalla principal del módulo
│   ├── services/        # Servicios genéricos (ej. http_service.dart)
│   └── tools/           # Herramientas utilitarias y complementos (ej. printers, http_tool)
├── widgets/             # COMPONENTES UI REUTILIZABLES (Globales)
│   ├── dialogs/         # Modales y diálogos globales reutilizables (ej. product_viewer)
│   ├── elements/        # Widgets atómicos genéricos (ej. ClientShortInfo)
│   ├── tables/          # Componentes para tablas de alta interacción (ej. ProductTableController)
│   └── ...
└── main.dart            # Punto de entrada de la aplicación
```

---

## 3. Capa de Datos: Creación de DataSources

Los DataSource son **Singletons** que se comunican de forma directa y pura con los endpoints de la API. No transforman los objetos en modelos, simplemente retornan `Map<String, dynamic>`.

**Reglas para DataSources:**
- Se ubican en `lib/src/data/`.
- Deben tener extensión `_data_source.dart`.
- Utilizan `with HttpService` para tener acceso a los métodos `getQuery`, `postQuery`, `patchQuery`, `deleteQuery`.
- Almacenan su ruta base principal en un string privado `_endpoint`.
- Utilizan la utilidad `HttpTools` para generar la URI con `HttpTools.generateUri` y los headers con `HttpTools.generateAuthHeaders`.

**Plantilla Base / Ejemplo:**
```dart
import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class EntityDataSource with HttpService {
  EntityDataSource._();
  static final EntityDataSource instance = EntityDataSource._();
  factory EntityDataSource() {
    return instance;
  }

  final _endpoint = "/entities";

  Future<Map<String, dynamic>> getAllEntities() async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  // Idem para createEntity (postQuery), updateEntityById (patchQuery), deleteEntityById (deleteQuery)
}
```

---

## 4. Capa de Dominio: Los Repositorios

Los repositorios se encargan de **gestionar el estado local de la entidad en memoria**, mapear de JSON a Modelo con `.fromJson()`, y ser el proveedor de confianza para el Cubit.

**Reglas para Repositorios:**
- Se ubican en `lib/src/domain/repositories/`.
- Instancian como dependencia privada su propio DataSource en el constructor.
- Mantienen el estado in-memory generalmente en una lista o variable privada (`List<Model> _list`).
- Hacen los parseos de respuesta utilizando Modelos genéricos como `ListResponse<Model>.fromJson(results, Model.fromJson)`.
- Si se crea, actualiza o borra en el backend (vía DataSource), **el repositorio muta y sincroniza la lista privada y retorna la entidad mapeada.**

**Ejemplo de Patrón Mutación en Repositorio:**
```dart
Future<EntityModel?> updateEntityById(String id, UpdateModel unit) async {
  final result = await entityDataSource.updateEntityById(id, unit.toJson());
  if (result == null) return null;

  final updatedEntity = EntityModel.fromJson(result);
  final index = _entities.indexWhere((e) => e.id == id);
  if (index != -1) {
    _entities[index] = updatedEntity; // Sincronización in-memory
  }
  return updatedEntity;
}
```

---

## 5. Lógica de Estado: Los Cubits

Los Cubits se segmentan fuertemente para tener responsabilidad única. Se dividen en dos categorías principales: **Read Cubits** (operaciones de lectura) y **Write Cubits** (operaciones de escritura/mutación).

### Read Cubits (Ej. `ReadUnitCubit`)
Encargados exclusivamente de traer datos (`getAll`, `getById`).
- Su estado `Success` (ej. `ReadUnitSuccess`) contiene todos los elementos listos para mostrarse.
- Del estado `Success` derivan estados para indicar elementos afectados recientemente. Por ejemplo, listas que contienen qué elementos fueron `created`, `updated`, o `deleted`, lo cual permite a la UI resaltarlos o animarlos.
- También derivan estados como `Searching` para indicar filtros aplicados conservando la carga útil base.
- **Carga Condicional para Evitar Parpadeos (UX Premium)**: En el método `getAll`, al refrescar o filtrar los datos, si el estado actual ya es exitoso (`ReadSuccess`), se debe emitir el estado intermedio `ReadSearching` (u otro estado que herede de `ReadSuccess` y conserve las listas en memoria) en lugar de un `ReadLoading()` global. Esto previene que la pantalla se borre de golpe para mostrar un spinner de carga central grande, posibilitando que la interfaz use un indicador de red discreto (como un `LinearProgressIndicator` superior) mientras mantiene visibles los datos anteriores en segundo plano.

**Ejemplo de Estados (Read):**
```dart
sealed class ReadState {}
final class ReadInitial extends ReadState {}
final class ReadLoading extends ReadState {}

class ReadSuccess extends ReadState {
  final List<Model> items;
  List<Model> newItems;
  List<Model> updatedItems;
  List<Model> deletedItems;

  ReadSuccess(
    this.items, {
    this.newItems = const [], 
    this.updatedItems = const [], 
    this.deletedItems = const [],
  });
}

final class ReadSearching extends ReadSuccess {
  ReadSearching(
    super.items, {
    super.newItems,
    super.updatedItems,
    super.deletedItems,
  });
}

class HighlightedItem extends ReadSuccess {
  HighlightedItem(
    super.items, {
    super.newItems,
    super.updatedItems,
    super.deletedItems,
  });
}

final class ReadError extends ReadState {
  final String message;
  ReadError(this.message);
}
```

### Write Cubits (Ej. `WriteUnitCubit`)
Encargados de mutar el backend (Create, Update, Delete).
- Únicamente tienen estados transitorios y de acción. El estado equivalente de carga se llama `Writing` (no loading).
- El éxito base es `Success`, del que derivan explícitamente 3 confirmaciones: `Created`, `Updated`, y `Deleted`. Esto permite a la interfaz reaccionar (cerrar modales, mostrar notificaciones y llamar al ReadCubit para insertar el dato visualmente sin repeticiones de red).
- Ambos contextos comparten la lógica de errores (`Error` state).

**Ejemplo de Estados (Write):**
```dart
sealed class WriteState {}
final class WriteInitial extends WriteState {}
final class Writing extends WriteState {}

class WriteSuccess extends WriteState {
  final Model item;
  WriteSuccess(this.item);
}

final class ItemCreated extends WriteSuccess {
  ItemCreated(super.item);
}

final class ItemUpdated extends WriteSuccess {
  ItemUpdated(super.item);
}

final class ItemDeleted extends WriteSuccess {
  ItemDeleted(super.item);
}

final class WriteError extends WriteState {
  final String message;
  WriteError(this.message);
}
```

**Reglas de los Cubits (*_cubit.dart):**
- Inyectan el Repositorio a través del constructor.
- Manejan excepciones con un bloque try/catch y emiten `Error(error.toString())`.
- Si se requiere actualizar en un listado persistente localmente, el `ReadCubit` expone métodos síncronos (como `markUnitUpdated` o `putUnitFirst`) para recibir el push directo del objeto modificado por el `WriteCubit`.
- **Sincronización Reactiva vía UI (Recomendado):** Para mantener la legibilidad y evitar acoplamiento imperativo en diálogos individuales, se prefiere envolver la vista principal o tabla en un `BlocListener<WriteCubit, WriteState>` para capturar los eventos de éxito del cubit de escritura (ej. `ItemCreated`, `ItemUpdated`, `ItemDeleted`) y llamar automáticamente a los métodos síncronos de actualización del cubit de lectura (ej. `markItemUpdated`).

## 6. Patrón de Repositorios Reactivos (ReactiveRepository Mixin)

Para desacoplar la UI de la coordinación entre Cubits de Lectura y Escritura, la aplicación implementa de manera opcional/avanzada el estándar de **Repositorio Reactivo** apoyado en eventos genéricos.

**Ubicación de la abstracción:** `lib/src/tools/reactive_repo/reactive_repository.dart`

Los repositorios pueden mezclar el `ReactiveRepository<T>` el cual expone un `eventStream` de estados sellados genéricos `RepoEvent<T>` (`RepoItemCreated`, `RepoItemUpdated`, `RepoItemDeleted`).

**Reglas de Uso (Patrón Reactivo):**
1. **En el Repositorio**: Se mezcla el mixin especificando el tipo de modelo (`class EntityRepository with ReactiveRepository<EntityModel>`). Tras una mutación exitosa con el Backend (Create, Update, Delete) y tras actualizar su lista local en memoria, el repositorio llama al notificador correspondiente (ej. `notifyItemCreated(newEntity)`).
2. **En el Cubit de Lectura**: Dentro de su constructor, se suscribe al repositorio mediante `eventStream.listen((event) {...})`. Dependiendo de la clase sellada (ej. `if (event is RepoItemCreated)`), el Cubit automáticamente invoca sus métodos de inserción visual y emite un `HighlightedItem` sin que la UI se lo tenga que ordenar.

---

## 7. Capa de UI (Vista) y Widgets Reutilizables

Las carpetas de UI están atadas a la estructura de módulos de negocio (`lib/src/modules/`). Si un widget es genérico, debe declararse en `/lib/widgets/`.

**Estándares de UI:**
- Pantallas divididas modularmente. Se sugiere utilizar `context.watch<Cubit>()` de Provider en el `build` para reaccionar a cambios o utilizar `BlocBuilder` para regiones más estrechas.
- Componentes altamente granulares en `widgets/elements/`, un ejemplo claro de widget genérico estandarizado es `ClientShortInfo` que empaqueta datos comunes para ser reutilizados en listados y tablas de clientes en múltiples partes de la app.
- Uso prominente de notificaciones (ChangeNotifier, InheritedNotifier, NotificationListener) y controladores para tablas altamente complejas como `inventory_movement_product_table.dart`.

## 8. Instrucciones para la IA (Agentes)

1. **Alineación con el backend:** Respeta siempre los objetos en backend y front. Si actualizas un endpoint en FastAPI, el frontend debe en simultáneo crear un modelo DTO (`CreateUnit`, `UpdateUnit`, etc) para mantener paridad en el mapeo de variables.
2. **Evitar hardcode en rutas y auth:** Utiliza SIEMPRE `HttpTools` y `with HttpService`. 
3. **No realizar parseos Json en DataSource:** El return del source siempre viaja en bruto a la capa de Repositorio. El repositorio se hace responsable del tipado fuerte.
4. **Respeto a Dart Moderno:** Las directivas de "Null Safety" y Mapas con null coalescing como `map?['value']` deben respetarse como prácticas soportadas y recomendadas (Dart 3+).
5. Persistencia de estilos en UI: Respeta colores, tipografía global y formatos. Los costos no editables se formatean tipicamente dividiendo sobre 100 con `.toStringAsFixed(2)`.
6. **Uso de Formateadores de Entrada (Input Formatters):** Antes de crear cualquier campo de entrada de texto (`TextField`, `TextFormField`, `TitleTextField`) que requiera entrada de tipo numérico o decimal, se debe verificar la existencia de los formateadores predefinidos en `lib/src/tools/input_formatters.dart` (por ejemplo, `IntegerTextInputFormatter` para números enteros o `DecimalTextInputFormatter` para decimales con dos dígitos) y aplicarlos para asegurar la integridad de los datos.

---

## 9. Uso de la Herramienta Onion CLI

El proyecto cuenta con un helper CLI en Python llamado `onion` para automatizar la creación de código siguiendo la Arquitectura Onion. Esta herramienta está instalada globalmente en el sistema y se puede ejecutar escribiendo `onion` en la terminal.

### Reglas de Nomenclatura
- Todos los nombres de las entidades deben proveerse en **singular** (ej. `product`, no `products`). La CLI las pluralizará y formateará automáticamente (PascalCase y snake_case).

### Comandos Comunes para Dart / Flutter
Cuando se trabaje en el frontend, se pueden usar los siguientes comandos desde la raíz del proyecto para generar plantillas consistentes:

- **Generar Capa de Datos Completa:** Genera modelo, datasource y repositorio.
  ```bash
  onion dart <nombre_de_entidad_en_singular>
  ```
  *Archivos generados:* `lib/src/models/<entidad>_model.dart`, `lib/src/data/<entidad>_data_source.dart`, `lib/src/domain/repositories/<entidad>_repository.dart`.
  
- **Generar Módulo Flutter Completo:** Genera la estructura de directorios recomendada en `lib/src/modules/` (vista básica, cubits de lectura/escritura, stubs de dialogs y widgets).
  ```bash
  onion flutter-module <nombre_de_entidad_en_singular>
  ```

- **Generar solo Cubits:** Genera los archivos de cubit y estados para lectura (`Read`) y escritura (`Write`) en un directorio.
  ```bash
  onion dart-cubit <nombre_de_entidad_en_singular>
  ```

- **Generar solo Modelos:** Genera las 4 clases de datos (`Base`, `Create`, `Update`, `InDb`) en Dart.
  ```bash
  onion dart-model <nombre_de_entidad_en_singular>
  ```

- **Generar solo la Vista:** Genera una pantalla base StatelessWidget.
  ```bash
  onion dart-view <nombre_de_entidad_en_singular>
  ```

### Comandos Comunes para FastAPI (Backend)
Si se requiere trabajar en el backend, la CLI permite generar endpoints y persistencia rápidamente:
- **CRUD Completo (Memoria/Stubs):** `onion crud <entidad> --version <v>`
- **CRUD Completo con MongoDB:** `onion crud-mongo <entidad> --version <v>`
- **Generar solo Router/Controller:** `onion router <entidad> --version <v>`
- **Generar solo Repositorio/DataSource:** `onion repo <entidad> --version <v>`
