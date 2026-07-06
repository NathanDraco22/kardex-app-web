# kardex_business

Paquete Dart puro (sin dependencia de Flutter) que actúa como capa de negocio y SDK cliente para el backend REST **Kardex Server** (`kardex-server`). Expone **37 repositorios** que cubren todas las operaciones del sistema de gestión de inventario, ventas, compras, finanzas y administración.

---

## Tabla de Contenidos

1. [Requisitos e Instalación](#requisitos-e-instalación)
2. [Configuración e Inicialización](#configuración-e-inicialización)
3. [Cómo Funciona](#cómo-funciona)
4. [Arquitectura General](#arquitectura-general)
5. [Catálogo de Repositorios](#catálogo-de-repositorios)
   - [Autenticación y Usuarios](#51-autenticación-y-usuarios)
   - [Productos e Inventario](#52-productos-e-inventario)
   - [Entradas y Salidas](#53-entradas-y-salidas)
   - [Clientes y Transacciones](#54-clientes-y-transacciones)
   - [Órdenes, Facturas, Recibos y Devoluciones](#55-órdenes-facturas-recibos-y-devoluciones)
   - [Transferencias](#56-transferencias)
   - [Proveedores](#57-proveedores)
   - [Gastos](#58-gastos)
   - [Reportes y Dashboard](#59-reportes-y-dashboard)
   - [Sistema y Utilidades](#510-sistema-y-utilidades)
6. [Servicios y Herramientas](#6-servicios-y-herramientas)
7. [Excepciones HTTP](#7-excepciones-http)
8. [Modelos Compartidos y Respuestas](#8-modelos-compartidos-y-respuestas)
9. [Parámetros de Consulta](#9-parámetros-de-consulta)
10. [Ejemplo de Uso](#10-ejemplo-de-uso)

---

## Requisitos e Instalación

- **Dart SDK**: `^3.11.0`
- **Dependencias principales**: `http`, `dio`, `dio_cache_interceptor`, `hive`, `dart_jsonwebtoken`

Añadir al `pubspec.yaml` del proyecto consumidor:

```yaml
dependencies:
  kardex_business:
    path: packages/kardex_business
```

---

## Configuración e Inicialización

Antes de usar cualquier repositorio, debe inicializarse el cliente global proporcionando una implementación concreta de `KardexClientConfig`.

### KardexClientConfig

Clase abstracta que el proyecto consumidor debe implementar:

```dart
abstract class KardexClientConfig {
  String get baseUrl;          // URL base del servidor (ej. "http://localhost:8000")
  String? get practiceUrl;      // URL de práctica (opcional, reemplaza baseUrl si se define)
  String? get authToken;        // Token JWT de autenticación
  String? get servinNickname;   // Alias del licenciamiento Servin (opcional)
  String? get branchId;         // ID de la sucursal activa (opcional)
}
```

### KardexClient

Singleton que mantiene la configuración global:

```dart
KardexClient.initialize(MiConfig(
  baseUrl: 'http://localhost:8000',
));
```

Una vez inicializado, cualquier repositorio puede instanciarse directamente:

```dart
final productosRepo = ProductsRepository();
final clientesRepo = ClientsRepository();
```

---

## Cómo Funciona

### Construcción de URLs

Las URLs se construyen con el patrón:

```
{baseUrl}/api/v{versión}/{entidad}?{queryParams}
```

- `baseUrl` se toma de `KardexClientConfig.baseUrl`.
- Si `practiceUrl` está definida, reemplaza `baseUrl`.
- La versión por defecto es `1`.
- Soporta tanto `http` como `https`.

Ejemplo concreto:

```
GET http://localhost:8000/api/v1/products?offset=0&limit=50
POST http://localhost:8000/api/v1/products
GET http://localhost:8000/api/v1/products/abc123
PATCH http://localhost:8000/api/v1/products/abc123
DELETE http://localhost:8000/api/v1/products/abc123
```

### Autenticación y Headers

Toda petición autenticada incluye los siguientes headers generados por `HttpTools.generateAuthHeaders()`:

```
Authorization: Bearer <jwt_token>
X-Agent: Neptuno
X-Servin: <servinNickname>   (si está configurado)
X-Branch: <branchId>         (si está configurado)
```

### Ciclo de Vida del Token

`TokenManager` es un singleton en memoria que:

- Almacena el JWT tras el login (`/auths/login`).
- Decodifica el token con `dart_jsonwebtoken` para verificar su expiración.
- `isTokenGotExpired()` retorna `true` si el token expirará en menos de **1 hora** (buffer de seguridad de 3600 segundos).
- El proyecto consumidor es responsable de llamar a `/auths/refresh-token` cuando el token esté próximo a expirar.

### Clientes HTTP

El paquete ofrece dos mixins distintos según la necesidad de caché:

| Mixin | Paquete base | Caché | Uso típico |
|---|---|---|---|
| `HttpService` | `package:http` | No | CRUD estándar (la mayoría de los DataSources) |
| `DioHttpService` | `dio` + `dio_cache_interceptor` + `hive` | Sí, en disco vía Hive | Consultas de lectura frecuente (admin panels, integraciones, transferencias) |

---

## Arquitectura General

El paquete sigue una arquitectura **Onion (Clean Architecture)** estricta:

```
┌─────────────────────────────────────────────────┐
│ Capa de Presentación (Flutter App)              │
│  → Cubits / BLoCs                               │
├─────────────────────────────────────────────────┤
│ Capa de Dominio (kardex_business)               │
│  ┌───────────────────────────────────────────┐  │
│  │ Repositories                              │  │
│  │  → Parsean JSON a modelos tipados         │  │
│  │  → Mantienen caché en memoria (opcional)  │  │
│  │  → Emiten eventos reactivos (opcional)    │  │
│  ├───────────────────────────────────────────┤  │
│  │ Data Sources                              │  │
│  │  → Llamadas HTTP crudas                   │  │
│  │  → Retornan Map<String, dynamic>          │  │
│  └───────────────────────────────────────────┘  │
├─────────────────────────────────────────────────┤
│ Capa de Infraestructura                         │
│  → HttpService / DioHttpService                 │
│  → TokenManager / HiveService                   │
└─────────────────────────────────────────────────┘
```

**Regla**: la capa de presentación **nunca** consume DataSources directamente; siempre lo hace a través de Repositories.

Cada repositorio sigue el patrón CRUD estándar cuando aplica:

| Operación | Método HTTP | Path |
|---|---|---|
| Crear | `POST` | `/{entidad}` |
| Listar | `GET` | `/{entidad}` |
| Obtener | `GET` | `/{entidad}/{id}` |
| Actualizar | `PATCH` | `/{entidad}/{id}` |
| Eliminar | `DELETE` | `/{entidad}/{id}` |

---

## Catálogo de Repositorios

> **Leyenda**: `✓` Cache en memoria | `ListResponse` Retorna `ListResponse<T>` | `⚡` Tiene métodos de estado (state machine)

---

### 5.1 Autenticación y Usuarios

#### AuthRepository
**Propósito**: Gestiona la autenticación del usuario. Maneja login, refresh de token JWT, cambio de contraseña y recuperación de sesión desde almacenamiento local. No es un repositorio de entidades CRUD, sino un servicio de autenticación.

| Característica | Detalle |
|---|---|
| Modelos | `LoginResponse`, `ChangePasswordBody`, `ServinStatusResponse`, `UserStatusResponse` |
| Query Params | Ninguno |
| Cache en memoria | No |
| DataSources | `AuthDataSource`, `ServinStatusDataSource` |

| Método | Firma | Descripción |
|---|---|---|
| `login` | `Future<LoginResponse> login(String userId, String password)` | Autentica al usuario con ID y contraseña. Retorna `LoginResponse` con token y datos de usuario. |
| `refreshToken` | `Future<LoginResponse> refreshToken(String token)` | Refresca el token JWT actual. |
| `changePassword` | `Future<void> changePassword(ChangePasswordBody data)` | Cambia la contraseña del usuario autenticado. |
| `getLocalSession` | `Future<LoginResponse?> getLocalSession()` | Recupera la sesión guardada localmente (del almacenamiento persistente). Retorna `null` si no hay sesión. |
| `getServinStatus` | `Future<ServinStatusResponse> getServinStatus()` | Obtiene el estado del licenciamiento Servin. |
| `getUserStatus` | `Future<UserStatusResponse> getUserStatus(String userId)` | Consulta el estado (activo/inactivo/conectado) de un usuario por su ID. |

---

#### UsersRepository
**Propósito**: Administración de usuarios del sistema. Permite crear, consultar, buscar, actualizar y eliminar usuarios. Soporta paginación por offset y filtrado de usuarios activos por sucursal. Distingue entre `UserInDb` (usuario base) y `UserInDbWithRole` (usuario con su rol asociado).

| Característica | Detalle |
|---|---|
| Modelos | `UserInDb`, `CreateUser`, `UpdateUser`, `UserInDbWithRole` |
| Query Params | Ninguno |
| Cache en memoria | No |

| Método | Firma | Descripción |
|---|---|---|
| `createUser` | `Future<UserInDb> createUser(CreateUser user)` | Crea un nuevo usuario en el sistema. |
| `getPaginatedUsers` | `Future<List<UserInDbWithRole>> getPaginatedUsers(int offset)` | Obtiene usuarios paginados con información de rol. |
| `getAllActiveUsers` | `Future<List<UserInDbWithRole>> getAllActiveUsers({String? branchId})` | Lista todos los usuarios activos, opcionalmente filtrados por sucursal. |
| `getUserById` | `Future<UserInDb?> getUserById(String id)` | Obtiene un usuario por su ID. |
| `searchUserByKeyword` | `Future<List<UserInDb>> searchUserByKeyword(String keyword)` | Busca usuarios por palabra clave (nombre, email, etc.). |
| `updateUserById` | `Future<UserInDb?> updateUserById(String id, UpdateUser data)` | Actualiza los datos de un usuario. |
| `deleteUserById` | `Future<UserInDb?> deleteUserById(String id)` | Elimina un usuario del sistema. |

---

#### UserRolesRepository
**Propósito**: Gestión de roles de usuario. Define los permisos y niveles de acceso que pueden asignarse a los usuarios del sistema.

| Característica | Detalle |
|---|---|
| Modelos | `UserRoleInDb`, `CreateUserRole`, `UpdateUserRole` |
| Query Params | Ninguno |
| Cache en memoria | No |

| Método | Firma | Descripción |
|---|---|---|
| `createUserRole` | `Future<UserRoleInDb> createUserRole(CreateUserRole role)` | Crea un nuevo rol de usuario. |
| `getAllUserRoles` | `Future<List<UserRoleInDb>> getAllUserRoles()` | Obtiene todos los roles disponibles. |
| `getUserRoleById` | `Future<UserRoleInDb?> getUserRoleById(String id)` | Obtiene un rol por su ID. |
| `updateUserRoleById` | `Future<UserRoleInDb?> updateUserRoleById(String id, UpdateUserRole data)` | Actualiza un rol existente. |
| `deleteUserRoleById` | `Future<UserRoleInDb?> deleteUserRoleById(String id)` | Elimina un rol. |

---

#### ServinRepository
**Propósito**: Gestiona el licenciamiento **Servin**, el sistema de activación de la aplicación. Verifica la licencia contra el servidor usando API key y alias (nickname), almacena la licencia localmente y permite refrescar su estado. Es el guardián que determina si la aplicación está autorizada para operar.

| Característica | Detalle |
|---|---|
| Modelos | `Servin`, `ServinStatusResponse` |
| Query Params | Ninguno |
| Cache en memoria | Sí (persistencia vía `AppConfigStore`) |
| DataSources | `ServinDataSource`, `AppConfigStore` |

| Método | Firma | Descripción |
|---|---|---|
| `getActiveServin` | `Future<Servin> getActiveServin(String apiKey, String nickname)` | Activa/verifica una licencia Servin con la API key y alias proporcionados. |
| `getCurrentServinFromLocal` | `Future<Servin?> getCurrentServinFromLocal()` | Recupera la licencia Servin almacenada localmente. |
| `clearCurrentServin` | `Future<void> clearCurrentServin()` | Elimina la licencia Servin almacenada localmente. |
| `refreshServinStatus` | `Future<Servin?> refreshServinStatus()` | Actualiza el estado de la licencia actual combinando datos remotos y locales. |

---

### 5.2 Productos e Inventario

#### ProductsRepository
**Propósito**: Repositorio central de productos. Administra el catálogo completo de productos con soporte para búsqueda por palabra clave, paginación por offset y consultas contextualizadas por sucursal (inventario multi-sucursal). Distingue entre `ProductInDb` (datos maestros del producto) y `ProductInDbInBranch` (datos del producto en una sucursal específica, incluyendo stock y precio).

| Característica | Detalle |
|---|---|
| Modelos | `ProductInDb`, `CreateProduct`, `UpdateProduct`, `ProductInDbInBranch`, `GetProductsInBranchRequest` |
| Query Params | `ProductQueryParams` |
| Cache en memoria | No |

| Método | Firma | Descripción |
|---|---|---|
| `createProduct` | `Future<ProductInDb> createProduct(CreateProduct prod)` | Crea un nuevo producto en el catálogo. |
| `getPaginatedProducts` | `Future<List<ProductInDb>> getPaginatedProducts(int offset)` | Obtiene productos paginados (offset-based). |
| `getProductById` | `Future<ProductInDb?> getProductById(String id)` | Obtiene un producto por su ID. |
| `searchProductByKeyword` | `Future<List<ProductInDb>> searchProductByKeyword(String keyword)` | Busca productos globalmente por palabra clave. |
| `getAllProductsInBranch` | `Future<List<ProductInDbInBranch>> getAllProductsInBranch(ProductQueryParams params, String branchId)` | Obtiene todos los productos con datos de inventario en una sucursal específica. |
| `getProductInBranchById` | `Future<ProductInDbInBranch> getProductInBranchById(String productId, String branchId)` | Obtiene un producto con sus datos de sucursal (stock, precio local). |
| `searchProductInBranch` | `Future<List<ProductInDbInBranch>> searchProductInBranch(String keyword, String branchId)` | Busca productos dentro de una sucursal por palabra clave. |
| `updateProductById` | `Future<ProductInDb?> updateProductById(String id, UpdateProduct data)` | Actualiza los datos maestros de un producto. |
| `deleteProductById` | `Future<ProductInDb?> deleteProductById(String id)` | Elimina un producto del catálogo. |
| `getProductsInBranchByIds` | `Future<List<ProductInDbInBranch>> getProductsInBranchByIds({required String branchId, required GetProductsInBranchRequest body})` | Obtiene múltiples productos por sus IDs en una sucursal (consulta batch). |

---

#### ProductCategoriesRepository
**Propósito**: Categorización de productos. Permite organizar el catálogo en categorías jerárquicas para facilitar filtrado y reportes. Soporta búsqueda tanto remota (API) como local (en memoria) para optimizar respuestas en UI.

| Característica | Detalle |
|---|---|
| Modelos | `ProductCategoryInDb`, `CreateProductCategory`, `UpdateProductCategory` |
| Query Params | Ninguno |
| Cache en memoria | ✓ (ordenado A-Z) |

| Método | Firma | Descripción |
|---|---|---|
| `createProductCategory` | `Future<ProductCategoryInDb> createProductCategory(CreateProductCategory cat)` | Crea una nueva categoría de producto. |
| `getAllProductCategories` | `Future<List<ProductCategoryInDb>> getAllProductCategories()` | Obtiene todas las categorías, refresca caché en memoria. |
| `getProductCategoryById` | `Future<ProductCategoryInDb?> getProductCategoryById(String id)` | Obtiene una categoría por su ID. |
| `searchProductCategoryByKeyword` | `Future<List<ProductCategoryInDb>> searchProductCategoryByKeyword(String kw)` | Busca categorías por palabra clave contra la API. |
| `searchProductCategoryByKeywordLocal` | `Future<List<ProductCategoryInDb>> searchProductCategoryByKeywordLocal(String kw)` | Busca categorías en la caché local (sin llamada HTTP). |
| `updateProductCategoryById` | `Future<ProductCategoryInDb?> updateProductCategoryById(String id, UpdateProductCategory data)` | Actualiza una categoría. Actualiza caché. |
| `deleteProductCategoryById` | `Future<ProductCategoryInDb?> deleteProductCategoryById(String id)` | Elimina una categoría. Sincroniza caché. |

---

#### ProductPricesRepository
**Propósito**: Gestión de precios de producto. Permite definir y administrar precios de venta asociados a productos, útiles para listas de precios, perfiles de venta y facturación.

| Característica | Detalle |
|---|---|
| Modelos | `ProductPriceInDb`, `CreateProductPrice`, `UpdateProductPrice` |
| Query Params | Ninguno |
| Cache en memoria | ✓ (ordenado A-Z) |

| Método | Firma | Descripción |
|---|---|---|
| `createProductPrice` | `Future<ProductPriceInDb> createProductPrice(CreateProductPrice price)` | Crea un nuevo precio de producto. |
| `getAllProductPrices` | `Future<List<ProductPriceInDb>> getAllProductPrices()` | Obtiene todos los precios, refresca caché. |
| `getProductPriceById` | `Future<ProductPriceInDb?> getProductPriceById(String id)` | Obtiene un precio por su ID. |
| `searchProductPriceByKeyword` | `Future<List<ProductPriceInDb>> searchProductPriceByKeyword(String kw)` | Busca precios por palabra clave. |
| `updateProductPriceById` | `Future<ProductPriceInDb?> updateProductPriceById(String id, UpdateProductPrice data)` | Actualiza un precio. Sincroniza caché. |
| `deleteProductPriceById` | `Future<ProductPriceInDb?> deleteProductPriceById(String id)` | Elimina un precio. Sincroniza caché. |

---

#### ProductStatsRepository
**Propósito**: Analítica de productos. Proporciona estadísticas de rendimiento, proyecciones de inventario y generación de reportes en Excel. Es un repositorio de sólo lectura orientado a la inteligencia de negocio sobre el catálogo de productos.

| Característica | Detalle |
|---|---|
| Modelos | `ProductStatInDb`, `ProductStatInDbWithInfo`, `ProductStatInDbWithAccount` |
| Query Params | `ProductStatQueryParams` |
| Cache en memoria | No |

| Método | Firma | Descripción |
|---|---|---|
| `getAll` | `Future<List<ProductStatInDb>> getAll({String? branchId})` | Obtiene estadísticas base de todos los productos. |
| `getAllWithInfo` | `Future<List<ProductStatInDbWithInfo>> getAllWithInfo({String? branchId})` | Obtiene estadísticas con información adicional (ventas, rotación, etc.). |
| `getAllWithAccount` | `Future<List<ProductStatInDbWithAccount>> getAllWithAccount({String? branchId})` | Obtiene estadísticas con datos contables. |
| `generateExcel` | `Future<void> generateExcel(int projectionDays)` | Dispara la generación de un reporte Excel con proyección de inventario a N días. |
| `estimate` | `Future<void> estimate(ProductStatQueryParams params)` | Dispara un cálculo de estimación para los parámetros dados. |

---

#### ProductAccountsRepository
**Propósito**: Contabilidad de inventario por producto. Permite registrar **entradas** (add) y **salidas** (substract) de stock con su costo promedio asociado. Es el repositorio que alimenta el kárdex contable de cada producto.

| Característica | Detalle |
|---|---|
| Modelos | `ProductAccountInDb` |
| Query Params | Ninguno |
| Cache en memoria | No |

| Método | Firma | Descripción |
|---|---|---|
| `getProductAccountsByProduct` | `Future<List<ProductAccountInDb>> getProductAccountsByProduct(String productId)` | Obtiene el historial contable de un producto. |
| `addProductAccount` | `Future<ProductAccountInDb> addProductAccount(String productId, String branchId, {required int currentStock, required double averageCost})` | Registra un aumento de stock (entrada) con costo promedio. |
| `substractProductAccount` | `Future<ProductAccountInDb> substractProductAccount(String productId, String branchId, {required int currentStock})` | Registra una disminución de stock (salida). |

---

#### ProductSaleProfilesRepository
**Propósito**: Perfiles de venta por producto y sucursal. Define cómo se vende un producto en cada sucursal (precio, visibilidad, configuración de venta). Opera siempre en contexto de sucursal. Distingue entre `ProductSaleProfileInDb` (datos del perfil) y `ProductSaleProfileInDbWithProduct` (perfil con datos del producto anidados).

| Característica | Detalle |
|---|---|
| Modelos | `ProductSaleProfileInDb`, `CreateProductSaleProfile`, `ProductSaleProfileInDbWithProduct`, `UpdateProductSaleProfile` |
| Query Params | Ninguno |
| Cache en memoria | No |

| Método | Firma | Descripción |
|---|---|---|
| `createProductSaleProfile` | `Future<ProductSaleProfileInDb> createProductSaleProfile(CreateProductSaleProfile profile)` | Crea un perfil de venta para un producto en una sucursal. |
| `getAllProductSaleProfilesCurrentBranch` | `Future<List<ProductSaleProfileInDbWithProduct>> getAllProductSaleProfilesCurrentBranch(String branchId)` | Obtiene todos los perfiles de venta de la sucursal activa, con datos del producto. |
| `getProductSaleProfileByProductId` | `Future<ProductSaleProfileInDbWithProduct?> getProductSaleProfileByProductId(String productId, String branchId)` | Obtiene el perfil de venta de un producto específico en una sucursal. |
| `updateProductSaleProfileByProductId` | `Future<ProductSaleProfileInDb?> updateProductSaleProfileByProductId(String productId, UpdateProductSaleProfile data, String branchId)` | Actualiza el perfil de venta de un producto en una sucursal. |

---

#### ProductTransactionsRepository
**Propósito**: Historial transaccional de productos. Registro de sólo lectura de todos los movimientos (entradas, salidas, ajustes) que afectan a cada producto. Esencial para trazabilidad y auditoría de inventario.

| Característica | Detalle |
|---|---|
| Modelos | `ProductTransactionInDb` |
| Query Params | `TransactionQueryParams` |
| Cache en memoria | No |
| `ListResponse` | ✓ |

| Método | Firma | Descripción |
|---|---|---|
| `getAllProductTransactions` | `Future<ListResponse<ProductTransactionInDb>> getAllProductTransactions(TransactionQueryParams params)` | Obtiene transacciones paginadas de productos según los filtros. |

---

#### UnitsRepository
**Propósito**: Unidades de medida. Define las unidades en que se mide el inventario (unidad, caja, kilogramo, litro, etc.). Soporta búsqueda local y remota para optimizar la experiencia de usuario en formularios.

| Característica | Detalle |
|---|---|
| Modelos | `UnitInDb`, `CreateUnit`, `UpdateUnit` |
| Query Params | Ninguno |
| Cache en memoria | ✓ (ordenado A-Z) |

| Método | Firma | Descripción |
|---|---|---|
| `createUnit` | `Future<UnitInDb> createUnit(CreateUnit unit)` | Crea una nueva unidad de medida. |
| `getAllUnits` | `Future<List<UnitInDb>> getAllUnits()` | Obtiene todas las unidades, refresca caché. |
| `getUnitById` | `Future<UnitInDb?> getUnitById(String id)` | Obtiene una unidad por su ID. |
| `searchUnitByKeyword` | `Future<List<UnitInDb>> searchUnitByKeyword(String kw)` | Busca unidades contra la API. |
| `searchUnitByKeywordLocal` | `Future<List<UnitInDb>> searchUnitByKeywordLocal(String kw)` | Busca unidades en caché local. |
| `updateUnitById` | `Future<UnitInDb?> updateUnitById(String id, UpdateUnit data)` | Actualiza una unidad. Sincroniza caché. |
| `deleteUnitById` | `Future<UnitInDb?> deleteUnitById(String id)` | Elimina una unidad. Sincroniza caché. |

---

#### InventoriesRepository
**Propósito**: Consulta de inventario actual. Devuelve el estado del inventario en una sucursal específica: qué productos hay, cuánto stock, y su valoración. Es de sólo lectura.

| Característica | Detalle |
|---|---|
| Modelos | `InventoryInDb` |
| Query Params | Ninguno |
| Cache en memoria | No |

| Método | Firma | Descripción |
|---|---|---|
| `getAllInventories` | `Future<List<InventoryInDb>> getAllInventories(String branchId)` | Obtiene el inventario completo de una sucursal. |

---

### 5.3 Entradas y Salidas

#### EntryDocsRepository
**Propósito**: Documentos de entrada de mercancía. Gestiona las entradas de productos al inventario (compras a proveedores, devoluciones de clientes que entran, ajustes positivos). Cada documento de entrada tiene un consecutivo y detalla los productos recibidos.

| Característica | Detalle |
|---|---|
| Modelos | `EntryDocInDb`, `CreateEntryDoc` |
| Query Params | Ninguno |
| Cache en memoria | No |

| Método | Firma | Descripción |
|---|---|---|
| `createEntryDoc` | `Future<EntryDocInDb> createEntryDoc(CreateEntryDoc doc)` | Crea un nuevo documento de entrada. |
| `getPaginatedEntryDocs` | `Future<List<EntryDocInDb>> getPaginatedEntryDocs(int offset)` | Obtiene documentos de entrada paginados (offset-based). |
| `getEntryDocById` | `Future<EntryDocInDb?> getEntryDocById(String id)` | Obtiene un documento de entrada por su ID. |
| `searchEntryDocByKeyword` | `Future<List<EntryDocInDb>> searchEntryDocByKeyword(String kw)` | Busca documentos de entrada por palabra clave. |

---

#### EntryHistoriesRepository
**Propósito**: Historial detallado de entradas. A diferencia de `EntryDocsRepository` que maneja los documentos cabecera, este repositorio expone el historial de cada línea de entrada: qué producto entró, en qué cantidad, a qué costo, en qué fecha y desde qué proveedor. Usa `ListResponse` para paginación.

| Característica | Detalle |
|---|---|
| Modelos | `EntryHistoryInDb` |
| Query Params | Parámetros nombrados: `branchId`, `offset`, `limit?`, `supplierId?`, `startDate?`, `endDate?` |
| Cache en memoria | No |
| `ListResponse` | ✓ |

| Método | Firma | Descripción |
|---|---|---|
| `getEntryHistories` | `Future<ListResponse<EntryHistoryInDb>> getEntryHistories({required String branchId, required int offset, int? limit, String? supplierId, String? startDate, String? endDate})` | Obtiene historial de entradas con filtros opcionales. |
| `getEntryDocsByProductId` | `Future<ListResponse<EntryHistoryInDb>> getEntryDocsByProductId(String productId)` | Obtiene el historial de entradas para un producto específico. |
| `getEntryHistoryById` | `Future<EntryHistoryInDb> getEntryHistoryById(String id)` | Obtiene una línea de historial de entrada por su ID. |

---

#### ExitDocsRepository
**Propósito**: Documentos de salida de mercancía. Gestiona las salidas de productos del inventario (ventas a clientes, ajustes negativos, traslados a otras sucursales). Espejo de `EntryDocsRepository` para el flujo de egreso.

| Característica | Detalle |
|---|---|
| Modelos | `ExitDocInDb`, `CreateExitDoc` |
| Query Params | Ninguno |
| Cache en memoria | No |

| Método | Firma | Descripción |
|---|---|---|
| `createExitDoc` | `Future<ExitDocInDb> createExitDoc(CreateExitDoc doc)` | Crea un nuevo documento de salida. |
| `getPaginatedExitDocs` | `Future<List<ExitDocInDb>> getPaginatedExitDocs(int offset)` | Obtiene documentos de salida paginados. |
| `getExitDocById` | `Future<ExitDocInDb?> getExitDocById(String id)` | Obtiene un documento de salida por su ID. |
| `searchExitDocByKeyword` | `Future<List<ExitDocInDb>> searchExitDocByKeyword(String kw)` | Busca documentos de salida por palabra clave. |

---

#### ExitHistoriesRepository
**Propósito**: Historial detallado de salidas. Expone cada línea de salida del inventario: qué producto salió, cantidad, precio de venta, fecha y cliente asociado. Usa `ListResponse` para paginación.

| Característica | Detalle |
|---|---|
| Modelos | `ExitHistoryInDb` |
| Query Params | Parámetros nombrados: `branchId`, `offset`, `clientId?`, `startDate?`, `endDate?` |
| Cache en memoria | No |
| `ListResponse` | ✓ |

| Método | Firma | Descripción |
|---|---|---|
| `getExitHistories` | `Future<ListResponse<ExitHistoryInDb>> getExitHistories({required String branchId, required int offset, String? clientId, String? startDate, String? endDate})` | Obtiene historial de salidas con filtros opcionales. |
| `getExitHistoryById` | `Future<ExitHistoryInDb> getExitHistoryById(String id)` | Obtiene una línea de historial de salida por su ID. |

---

#### AdjustEntriesRepository
**Propósito**: Ajustes de entrada al inventario. Permite registrar correcciones manuales de inventario que incrementan el stock (por conteo físico, correcciones administrativas, etc.). Se diferencia de `EntryDocsRepository` en que son ajustes, no compras.

| Característica | Detalle |
|---|---|
| Modelos | `AdjustEntryInDb`, `CreateAdjustEntry` |
| Query Params | `AdjustQueryParams` |
| Cache en memoria | No |

| Método | Firma | Descripción |
|---|---|---|
| `createAdjustEntry` | `Future<AdjustEntryInDb> createAdjustEntry(CreateAdjustEntry entry)` | Crea un ajuste de entrada. |
| `getAllAdjustEntries` | `Future<List<AdjustEntryInDb>> getAllAdjustEntries(AdjustQueryParams params)` | Obtiene todos los ajustes de entrada con filtros. |
| `getAdjustEntryById` | `Future<AdjustEntryInDb> getAdjustEntryById(String id)` | Obtiene un ajuste de entrada por su ID. |
| `getAdjustEntryByDocNumber` | `Future<AdjustEntryInDb> getAdjustEntryByDocNumber(String docNumber, String branchId)` | Busca un ajuste de entrada por número de documento y sucursal. |

---

#### AdjustExitsRepository
**Propósito**: Ajustes de salida del inventario. Permite registrar correcciones manuales que disminuyen el stock (mermas, deterioros, correcciones por conteo físico). Espejo de `AdjustEntriesRepository` para decrementos.

| Característica | Detalle |
|---|---|
| Modelos | `AdjustExitInDb`, `CreateAdjustExit` |
| Query Params | `AdjustQueryParams` |
| Cache en memoria | No |

| Método | Firma | Descripción |
|---|---|---|
| `createAdjustExit` | `Future<AdjustExitInDb> createAdjustExit(CreateAdjustExit exit)` | Crea un ajuste de salida. |
| `getAllAdjustExits` | `Future<List<AdjustExitInDb>> getAllAdjustExits(AdjustQueryParams params)` | Obtiene todos los ajustes de salida con filtros. |
| `getAdjustExitById` | `Future<AdjustExitInDb> getAdjustExitById(String id)` | Obtiene un ajuste de salida por su ID. |
| `getAdjustExitByDocNumber` | `Future<AdjustExitInDb> getAdjustExitByDocNumber(String docNumber, String branchId)` | Busca un ajuste de salida por número de documento y sucursal. |

---

### 5.4 Clientes y Transacciones

#### ClientsRepository
**Propósito**: Administración de clientes. Es el repositorio más grande de su categoría con 11 métodos. Maneja el ciclo completo del cliente: creación, consulta, búsqueda, actualización y eliminación. Además expone variantes especializadas:
- `getClientWithBalance` / `searchClientWithBalance`: incluyen el saldo contable del cliente.
- `getClientByCardId`: búsqueda por código de tarjeta (fidelización).
- `createMultipleInitialBalance`: asignación de saldo inicial a múltiples clientes.

| Característica | Detalle |
|---|---|
| Modelos | `ClientInDb`, `CreateClient`, `UpdateClient`, `CreateMultipleInitialBalance` |
| Query Params | `ClientQueryParams` |
| Cache en memoria | ✓ (ordenado A-Z) |

| Método | Firma | Descripción |
|---|---|---|
| `createClient` | `Future<ClientInDb> createClient(CreateClient client)` | Crea un nuevo cliente. Sincroniza caché. |
| `createMultipleInitialBalance` | `Future<ClientInDb> createMultipleInitialBalance(CreateMultipleInitialBalance data)` | Asigna saldo inicial a múltiples clientes. Sincroniza caché local. |
| `getAllClients` | `Future<List<ClientInDb>> getAllClients()` | Obtiene todos los clientes, refresca caché. |
| `getClients` | `Future<List<ClientInDb>> getClients(ClientQueryParams params)` | Obtiene clientes con filtros de query params. |
| `getClientWithBalance` | `Future<List<ClientInDb>> getClientWithBalance(ClientQueryParams params)` | Obtiene clientes incluyendo su saldo contable actual. |
| `getClientById` | `Future<ClientInDb?> getClientById(String id)` | Obtiene un cliente por su ID. |
| `getClientByCardId` | `Future<ClientInDb> getClientByCardId(String cardId)` | Busca un cliente por el código de su tarjeta de fidelización. |
| `searchClientByKeyword` | `Future<List<ClientInDb>> searchClientByKeyword(String kw)` | Busca clientes por palabra clave contra la API. |
| `searchClientWithBalance` | `Future<List<ClientInDb>> searchClientWithBalance(String kw)` | Busca clientes por palabra clave incluyendo su saldo. |
| `updateClientById` | `Future<ClientInDb?> updateClientById(String id, UpdateClient data)` | Actualiza un cliente. Sincroniza caché. |
| `deleteClientById` | `Future<ClientInDb?> deleteClientById(String id)` | Elimina un cliente. Sincroniza caché. |

---

#### ClientGroupsRepository
**Propósito**: Agrupación de clientes. Permite organizar clientes en categorías o segmentos (ej.: "Mayoristas", "Minoristas", "VIP"). Facilita filtros, reportes y asignación de precios por grupo. Soporta búsqueda local para rendimiento en dropdowns.

| Característica | Detalle |
|---|---|
| Modelos | `ClientGroupInDb`, `CreateClientGroup`, `UpdateClientGroup` |
| Query Params | Ninguno |
| Cache en memoria | ✓ (ordenado A-Z) |

| Método | Firma | Descripción |
|---|---|---|
| `createClientGroup` | `Future<ClientGroupInDb> createClientGroup(CreateClientGroup group)` | Crea un nuevo grupo de clientes. |
| `getAllClientGroups` | `Future<List<ClientGroupInDb>> getAllClientGroups()` | Obtiene todos los grupos, refresca caché. |
| `getClientGroupById` | `Future<ClientGroupInDb?> getClientGroupById(String id)` | Obtiene un grupo por su ID. |
| `searchClientGroupByKeywordLocal` | `Future<List<ClientGroupInDb>> searchClientGroupByKeywordLocal(String kw)` | Busca grupos en caché local (sin llamada HTTP). |
| `updateClientGroupById` | `Future<ClientGroupInDb?> updateClientGroupById(String id, UpdateClientGroup data)` | Actualiza un grupo. Sincroniza caché. |
| `deleteClientGroupById` | `Future<ClientGroupInDb?> deleteClientGroupById(String id)` | Elimina un grupo. Sincroniza caché. |

---

#### ClientTransactionsRepository
**Propósito**: Historial de transacciones de clientes. Registro de sólo lectura de los movimientos contables de cada cliente: abonos, cargos, pagos, ajustes de saldo. Retorna `ListResponse` para paginación.

| Característica | Detalle |
|---|---|
| Modelos | `ClientTransactionInDb` |
| Query Params | `ClientTransactionQueryParams` |
| Cache en memoria | No |
| `ListResponse` | ✓ |

| Método | Firma | Descripción |
|---|---|---|
| `getAllClientTransactions` | `Future<ListResponse<ClientTransactionInDb>> getAllClientTransactions(ClientTransactionQueryParams params)` | Obtiene transacciones de clientes paginadas con filtros. |
| `getClientTransactionById` | `Future<ClientTransactionInDb?> getClientTransactionById(String id)` | Obtiene una transacción por su ID. |

---

### 5.5 Órdenes, Facturas, Recibos y Devoluciones

#### OrdersRepository `⚡`
**Propósito**: Ciclo de vida completo de los pedidos (órdenes de venta). Es una máquina de estados: un pedido nace como **borrador** (draft), puede **convertirse en factura** (`convertOrderToInvoice`), **cancelarse** (`cancelOrderById`) o **eliminarse como borrador** (`deleteOrderDraft`). También expone analíticas: productos más pedidos (`getProductsInOrders`) y demanda vs inventario disponible (`productVSDemand`).

| Característica | Detalle |
|---|---|
| Modelos | `OrderInDb`, `CreateOrder`, `UpdateOrder`, `ProductSalesTotal`, `ProductStockDemand`, `OrderToInvoiceResponse` |
| Query Params | `OrderQueryParams` |
| Cache en memoria | No |
| `ListResponse` | ✓ |
| ⚡ State Machine | ✓ |

| Método | Firma | Descripción |
|---|---|---|
| `createOrder` | `Future<OrderInDb> createOrder(CreateOrder order)` | Crea un nuevo pedido (en estado borrador). |
| `getPaginatedOrders` | `Future<ListResponse<OrderInDb>> getPaginatedOrders({required OrderQueryParams params})` | Obtiene pedidos paginados con filtros. |
| `getProductsInOrders` | `Future<List<ProductSalesTotal>> getProductsInOrders({required OrderQueryParams params})` | Obtiene agregado de productos en pedidos (cantidades, totales). |
| `productVSDemand` | `Future<List<ProductStockDemand>> productVSDemand({required OrderQueryParams params})` | Compara stock actual vs demanda de pedidos pendientes. |
| `getOrderById` | `Future<OrderInDb?> getOrderById(String id)` | Obtiene un pedido por su ID. |
| `updateOrderById` | `Future<OrderInDb?> updateOrderById(String id, UpdateOrder data)` | Actualiza un pedido existente. |
| `convertOrderToInvoice` | `Future<OrderToInvoiceResponse?> convertOrderToInvoice(String id)` | Convierte un pedido en factura. Transición de estado. |
| `cancelOrderById` | `Future<OrderInDb?> cancelOrderById(String id)` | Cancela un pedido. |
| `deleteOrderDraft` | `Future<OrderInDb> deleteOrderDraft(String id)` | Elimina un pedido en estado borrador. |

---

#### InvoicesRepository
**Propósito**: El repositorio más grande del paquete (15 métodos). Gestiona el ciclo completo de facturación: creación de facturas, consultas paginadas, filtros por cliente, facturas pendientes de pago, facturas pagadas, totalizadores, ventas por producto, historial y búsqueda por número de documento. Incluye soporte para **facturas anónimas** (cliente de mostrador `kSaleClientId`). Usa dos DataSources (`InvoicesDataSource` e `InvoiceDevolutionsDataSource`).

| Característica | Detalle |
|---|---|
| Modelos | `InvoiceInDb`, `CreateInvoice`, `UpdateInvoice`, `InvoiceTotals`, `ProductSalesTotal`, `InvoiceDevolutionResponse` |
| Query Params | `InvoiceQueryParams` |
| Cache en memoria | No |
| `ListResponse` | ✓ |
| DataSources | 2 (`InvoicesDataSource`, `InvoiceDevolutionsDataSource`) |

| Método | Firma | Descripción |
|---|---|---|
| `createInvoice` | `Future<InvoiceInDb> createInvoice(CreateInvoice invoice)` | Crea una nueva factura. Soporta cliente anónimo. |
| `getAllInvoices` | `Future<ListResponse<InvoiceInDb>> getAllInvoices(InvoiceQueryParams params)` | Obtiene facturas paginadas con filtros. |
| `getInvoicesByClientId` | `Future<ListResponse<InvoiceInDb>> getInvoicesByClientId(String clientId)` | Obtiene facturas de un cliente específico. |
| `getPendingInvoices` | `Future<ListResponse<InvoiceInDb>> getPendingInvoices(String clientId)` | Obtiene facturas pendientes de pago de un cliente. |
| `getPaidInvoices` | `Future<ListResponse<InvoiceInDb>> getPaidInvoices({String branchId, String? clientId, String? startDate, String? endDate, String? userCreatorId, int? offset})` | Obtiene facturas pagadas con múltiples filtros opcionales. |
| `getTotalFromPaidInvoices` | `Future<InvoiceTotals> getTotalFromPaidInvoices({String branchId, String? clientId, String? startDate, String? endDate, String? userCreatorId})` | Obtiene totales agregados de facturas pagadas. |
| `getClientInvoices` | `Future<ListResponse<InvoiceInDb>> getClientInvoices({String branchId, String? clientId, String? startDate, String? endDate, int? offset})` | Obtiene facturas de clientes con filtros de sucursal y fechas. |
| `getTotalFromInvoices` | `Future<InvoiceTotals> getTotalFromInvoices(InvoiceQueryParams params)` | Obtiene totales de facturas según query params. |
| `getAllProductSales` | `Future<List<ProductSalesTotal>> getAllProductSales(InvoiceQueryParams params)` | Obtiene ventas agregadas por producto desde facturas. |
| `getInvoiceById` | `Future<InvoiceInDb?> getInvoiceById(String id)` | Obtiene una factura por su ID. |
| `updateInvoiceById` | `Future<InvoiceInDb?> updateInvoiceById(String id, UpdateInvoice data)` | Actualiza una factura existente. |
| `getInvoicesHistory` | `Future<List<InvoiceInDb>> getInvoicesHistory(InvoiceQueryParams params)` | Obtiene historial de facturas. |
| `getInvoiceByDocNumber` | `Future<InvoiceInDb> getInvoiceByDocNumber(String docNumber)` | Busca una factura por número de documento. |
| `getAnonInvoiceDevolutionByDocNumber` | `Future<InvoiceDevolutionResponse> getAnonInvoiceDevolutionByDocNumber(String docNumber)` | Obtiene datos de devolución de factura anónima por número de documento. |
| `getInvoicesByProduct` | `Future<ListResponse<InvoiceInDb>> getInvoicesByProduct(String productId, InvoiceQueryParams params)` | Obtiene facturas que contienen un producto específico. |

---

#### ReceiptsRepository
**Propósito**: Gestión de recibos de pago. Administra los comprobantes de pago que los clientes realizan contra facturas. Permite crear recibos, consultar por factura, obtener totales acumulados, buscar por número de documento y consultar historial de pagos.

| Característica | Detalle |
|---|---|
| Modelos | `ReceiptInDb`, `CreateReceipt`, `ReceiptTotal` |
| Query Params | `ReceiptQueryParams`, `InvoiceQueryParams` |
| Cache en memoria | No |
| `ListResponse` | ✓ |

| Método | Firma | Descripción |
|---|---|---|
| `createReceipt` | `Future<ReceiptInDb> createReceipt(CreateReceipt receipt)` | Crea un nuevo recibo de pago. |
| `getAllReceipts` | `Future<ListResponse<ReceiptInDb>> getAllReceipts(ReceiptQueryParams params)` | Obtiene recibos paginados con filtros. |
| `getAllReceiptsByInvoiceId` | `Future<ListResponse<ReceiptInDb>> getAllReceiptsByInvoiceId(String invoiceId)` | Obtiene todos los recibos asociados a una factura. |
| `getReceiptTotal` | `Future<ReceiptTotal> getReceiptTotal(ReceiptQueryParams params)` | Obtiene totales agregados de recibos. |
| `getReceiptByDocNumber` | `Future<ReceiptInDb> getReceiptByDocNumber(String docNumber)` | Busca un recibo por número de documento. |
| `getReceiptHistory` | `Future<List<ReceiptInDb>> getReceiptHistory(InvoiceQueryParams params)` | Obtiene historial de recibos usando parámetros de factura. |

---

#### DevolutionsRepository `⚡`
**Propósito**: Gestión de devoluciones de productos. Maneja el ciclo de vida de una devolución desde su creación hasta su **confirmación** o **cancelación**. Soporta dos flujos de confirmación: regular (`confirmDevolutionById`) y anónima (`confirmAnonDevolutionById`). Expone consultas de devoluciones activas, confirmadas e historial.

| Característica | Detalle |
|---|---|
| Modelos | `DevolutionInDb`, `CreateDevolution`, `DevolutionStatus` (enum) |
| Query Params | `DevolutionQueryParams`, `InvoiceQueryParams` |
| Cache en memoria | No |
| ⚡ State Machine | ✓ |

| Método | Firma | Descripción |
|---|---|---|
| `createDevolution` | `Future<DevolutionInDb> createDevolution(CreateDevolution devolution)` | Crea una nueva devolución. |
| `getAllDevolutions` | `Future<List<DevolutionInDb>> getAllDevolutions(DevolutionQueryParams params)` | Obtiene todas las devoluciones con filtros. |
| `getConfirmedDevolutions` | `Future<List<DevolutionInDb>> getConfirmedDevolutions(String userId, String branchId)` | Obtiene devoluciones ya confirmadas. |
| `getAllActiveDevolutions` | `Future<List<DevolutionInDb>> getAllActiveDevolutions(String userId, String branchId)` | Obtiene devoluciones activas (no confirmadas ni canceladas). |
| `getDevolutionById` | `Future<DevolutionInDb?> getDevolutionById(String id)` | Obtiene una devolución por su ID. |
| `confirmDevolutionById` | `Future<DevolutionInDb?> confirmDevolutionById(String id)` | Confirma una devolución (transición de estado). |
| `confirmAnonDevolutionById` | `Future<DevolutionInDb?> confirmAnonDevolutionById(String id)` | Confirma una devolución de factura anónima. |
| `cancelDevolutionById` | `Future<DevolutionInDb?> cancelDevolutionById(String id)` | Cancela una devolución. |
| `deleteDevolutionById` | `Future<DevolutionInDb?> deleteDevolutionById(String id)` | Elimina una devolución. |
| `getDevolutionHistory` | `Future<List<DevolutionInDb>> getDevolutionHistory(InvoiceQueryParams params)` | Obtiene historial de devoluciones. |
| `getDevolutionByDocNumber` | `Future<DevolutionInDb> getDevolutionByDocNumber(String docNumber)` | Busca una devolución por número de documento. |

---

### 5.6 Transferencias

#### TransfersRepository `⚡`
**Propósito**: Transferencias de mercancía entre sucursales. Gestiona el envío de productos de una sucursal origen a una sucursal destino. Expone una máquina de estados: crear transferencia, **recibir** (`receiveTransfer` con `ReceiveTransferIntent`) y **cancelar** (`cancelTransfer` con `CancelTransferIntent`). Usa `DioHttpService` para caché en las consultas.

| Característica | Detalle |
|---|---|
| Modelos | `TransferInDb`, `CreateTransfer`, `ReceiveTransferIntent`, `CancelTransferIntent` |
| Query Params | `TransferQueryParams` |
| Cache en memoria | No |
| ⚡ State Machine | ✓ |

| Método | Firma | Descripción |
|---|---|---|
| `createTransfer` | `Future<TransferInDb> createTransfer(CreateTransfer transfer)` | Crea una nueva transferencia entre sucursales. |
| `getAllTransfers` | `Future<List<TransferInDb>> getAllTransfers(TransferQueryParams params)` | Obtiene todas las transferencias con filtros. |
| `receiveTransfer` | `Future<TransferInDb> receiveTransfer(String id, ReceiveTransferIntent intent)` | Registra la recepción de una transferencia en la sucursal destino. |
| `cancelTransfer` | `Future<TransferInDb> cancelTransfer(String id, CancelTransferIntent intent)` | Cancela una transferencia. |
| `getTransferById` | `Future<TransferInDb> getTransferById(String id)` | Obtiene una transferencia por su ID. |

---

### 5.7 Proveedores

#### SuppliersRepository
**Propósito**: Administración de proveedores. Gestiona el catálogo de proveedores de mercancía y servicios. Full CRUD con caché en memoria ordenada alfabéticamente y búsqueda por palabra clave.

| Característica | Detalle |
|---|---|
| Modelos | `SupplierInDb`, `CreateSupplier`, `UpdateSupplier` |
| Query Params | Ninguno |
| Cache en memoria | ✓ (ordenado A-Z) |

| Método | Firma | Descripción |
|---|---|---|
| `createSupplier` | `Future<SupplierInDb> createSupplier(CreateSupplier supplier)` | Crea un nuevo proveedor. |
| `getAllSuppliers` | `Future<List<SupplierInDb>> getAllSuppliers()` | Obtiene todos los proveedores, refresca caché. |
| `getSupplierById` | `Future<SupplierInDb?> getSupplierById(String id)` | Obtiene un proveedor por su ID. |
| `searchSupplierByKeyword` | `Future<List<SupplierInDb>> searchSupplierByKeyword(String kw)` | Busca proveedores por palabra clave. |
| `updateSupplierById` | `Future<SupplierInDb?> updateSupplierById(String id, UpdateSupplier data)` | Actualiza un proveedor. Sincroniza caché. |
| `deleteSupplierById` | `Future<SupplierInDb?> deleteSupplierById(String id)` | Elimina un proveedor. Sincroniza caché. |

---

### 5.8 Gastos

#### ExpensesRepository
**Propósito**: Registro de gastos operativos. Permite crear, consultar, actualizar y eliminar gastos. Incluye una operación especial `addToAmountPaid` para registrar abonos parciales a un gasto, manteniendo trazabilidad de cuánto se ha pagado y cuánto queda pendiente.

| Característica | Detalle |
|---|---|
| Modelos | `ExpenseInDb`, `CreateExpense`, `UpdateExpense`, `AddToAmountRequest` |
| Query Params | `ExpenseQueryParams` |
| Cache en memoria | ✓ |

| Método | Firma | Descripción |
|---|---|---|
| `createExpense` | `Future<ExpenseInDb> createExpense(CreateExpense expense)` | Registra un nuevo gasto. |
| `getAllExpenses` | `Future<List<ExpenseInDb>> getAllExpenses(ExpenseQueryParams params)` | Obtiene todos los gastos con filtros. |
| `getExpenseById` | `Future<ExpenseInDb?> getExpenseById(String id)` | Obtiene un gasto por su ID. |
| `updateExpenseById` | `Future<ExpenseInDb?> updateExpenseById(String id, UpdateExpense data)` | Actualiza un gasto. Sincroniza caché. |
| `addToAmountPaid` | `Future<ExpenseInDb> addToAmountPaid(AddToAmountRequest request)` | Registra un abono al gasto. Sincroniza caché. |
| `deleteExpenseById` | `Future<ExpenseInDb?> deleteExpenseById(String id)` | Elimina un gasto. Sincroniza caché. |

---

#### ExpenseCategoriesRepository
**Propósito**: Categorización de gastos. Permite clasificar los gastos en rubros contables (servicios, nómina, insumos, mantenimiento, etc.) para facilitar reportes financieros y control presupuestario.

| Característica | Detalle |
|---|---|
| Modelos | `ExpenseCategoryInDb`, `CreateExpenseCategory`, `UpdateExpenseCategory` |
| Query Params | Ninguno |
| Cache en memoria | ✓ |

| Método | Firma | Descripción |
|---|---|---|
| `createExpenseCategory` | `Future<ExpenseCategoryInDb> createExpenseCategory(CreateExpenseCategory cat)` | Crea una nueva categoría de gasto. |
| `getAllExpenseCategories` | `Future<List<ExpenseCategoryInDb>> getAllExpenseCategories()` | Obtiene todas las categorías, refresca caché. |
| `getExpenseCategoryById` | `Future<ExpenseCategoryInDb?> getExpenseCategoryById(String id)` | Obtiene una categoría por su ID. |
| `updateExpenseCategoryById` | `Future<ExpenseCategoryInDb?> updateExpenseCategoryById(String id, UpdateExpenseCategory data)` | Actualiza una categoría. Sincroniza caché. |
| `deleteExpenseCategoryById` | `Future<ExpenseCategoryInDb?> deleteExpenseCategoryById(String id)` | Elimina una categoría. Sincroniza caché. |

---

### 5.9 Reportes y Dashboard

#### ReportsRepository
**Propósito**: Reportes financieros y operativos. Obtiene totales y resultados agregados por rango de fechas. Punto de entrada para reportes de cierre, balances y consolidados.

| Característica | Detalle |
|---|---|
| Modelos | `TotalsResult` |
| Query Params | `TotalsQueryParams` |
| Cache en memoria | No |

| Método | Firma | Descripción |
|---|---|---|
| `getTotalResultsByDateRange` | `Future<TotalsResult> getTotalResultsByDateRange(TotalsQueryParams params)` | Obtiene resultados totales agregados en un rango de fechas. |

---

#### AdminPanelRepository
**Propósito**: Dashboard administrativo. Proporciona datos agregados para gráficos y KPIs del panel principal. Soporta consulta global y filtrada por sucursal. Utiliza `DioHttpService` con caché en Hive para optimizar consultas frecuentes.

| Característica | Detalle |
|---|---|
| Modelos | `AdminChartsResponses` |
| Query Params | Parámetro nombrado: `endDate` (timestamp) |
| Cache en memoria | No |
| HTTP Client | `DioHttpService` (caché Hive) |

| Método | Firma | Descripción |
|---|---|---|
| `getAdminCharts` | `Future<AdminChartsResponses> getAdminCharts({required int endDate})` | Obtiene datos de gráficos del dashboard global. |
| `getAdminChartsByBranch` | `Future<AdminChartsResponses> getAdminChartsByBranch({required String branchId, required int endDate})` | Obtiene datos de gráficos del dashboard filtrados por sucursal. |

---

#### DailySummariesRepository
**Propósito**: Resúmenes diarios de operaciones. Proporciona una vista consolidada de la actividad del negocio día a día: ventas, compras, gastos, movimientos de inventario. Datos históricos de sólo lectura.

| Característica | Detalle |
|---|---|
| Modelos | `DailySummaryInDb` |
| Query Params | `DailySummaryQueryParams` |
| Cache en memoria | No |

| Método | Firma | Descripción |
|---|---|---|
| `getAll` | `Future<List<DailySummaryInDb>> getAll(DailySummaryQueryParams params)` | Obtiene resúmenes diarios con filtros. |
| `getById` | `Future<DailySummaryInDb> getById(String id)` | Obtiene un resumen diario por su ID. |

---

#### ExecutiveSummariesRepository
**Propósito**: Resúmenes ejecutivos. Versión gerencial de los resúmenes diarios, con datos agregados de más alto nivel para la toma de decisiones. Misma estructura que `DailySummariesRepository` pero con un enfoque en KPIs estratégicos.

| Característica | Detalle |
|---|---|
| Modelos | `ExecutiveSummaryInDb` |
| Query Params | `DailySummaryQueryParams` |
| Cache en memoria | No |

| Método | Firma | Descripción |
|---|---|---|
| `getAll` | `Future<List<ExecutiveSummaryInDb>> getAll(DailySummaryQueryParams params)` | Obtiene resúmenes ejecutivos con filtros. |
| `getById` | `Future<ExecutiveSummaryInDb> getById(String id)` | Obtiene un resumen ejecutivo por su ID. |

---

### 5.10 Sistema y Utilidades

#### BranchesRepository
**Propósito**: Administración de sucursales. Gestiona las ubicaciones físicas del negocio. Cada sucursal tiene su propio inventario, precios y operación independiente. Full CRUD con caché en memoria y búsqueda.

| Característica | Detalle |
|---|---|
| Modelos | `BranchInDb`, `CreateBranch`, `UpdateBranch` |
| Query Params | Ninguno |
| Cache en memoria | ✓ |

| Método | Firma | Descripción |
|---|---|---|
| `createBranch` | `Future<BranchInDb> createBranch(CreateBranch branch)` | Crea una nueva sucursal. |
| `getAllBranches` | `Future<List<BranchInDb>> getAllBranches()` | Obtiene todas las sucursales, refresca caché. |
| `getBranchById` | `Future<BranchInDb?> getBranchById(String branchId)` | Obtiene una sucursal por su ID. |
| `searchBranchByKeyword` | `Future<List<BranchInDb>> searchBranchByKeyword(String keyword)` | Busca sucursales por palabra clave. |
| `updateBranchById` | `Future<BranchInDb?> updateBranchById(String id, UpdateBranch data)` | Actualiza una sucursal. Sincroniza caché. |
| `deleteBranchById` | `Future<BranchInDb?> deleteBranchById(String id)` | Elimina una sucursal. Sincroniza caché. |

---

#### IntegrationsRepository
**Propósito**: Configuración de integraciones externas. Gestiona las conexiones con servicios de terceros (Telegram, notificaciones, etc.). Actualmente expone un endpoint de prueba para notificaciones de Telegram. Sin create/delete; los registros vienen preconfigurados.

| Característica | Detalle |
|---|---|
| Modelos | `IntegrationModel`, `UpdateIntegration` |
| Query Params | Ninguno |
| Cache en memoria | ✓ |
| HTTP Client | `DioHttpService` (caché Hive) |

| Método | Firma | Descripción |
|---|---|---|
| `getAllIntegrations` | `Future<List<IntegrationModel>> getAllIntegrations()` | Obtiene todas las integraciones configuradas. |
| `getIntegrationById` | `Future<IntegrationModel?> getIntegrationById(String id)` | Obtiene una integración por su ID. |
| `updateIntegrationById` | `Future<IntegrationModel?> updateIntegrationById(String id, UpdateIntegration data)` | Actualiza la configuración de una integración. |
| `sendTelegramTestNotification` | `Future<void> sendTelegramTestNotification()` | Envía una notificación de prueba a Telegram. |

---

#### ExpirationLogsRepository
**Propósito**: Control de caducidades. Gestiona el registro de productos próximos a vencer o ya vencidos. Permite crear alertas de caducidad, consultar el log y verificar si una sucursal tiene productos con caducidad activa (`hasExpiration`). No tiene método de actualización.

| Característica | Detalle |
|---|---|
| Modelos | `ExpirationLogInDb`, `CreateExpirationLog` |
| Query Params | `ExpirationQueryParams` |
| Cache en memoria | No |

| Método | Firma | Descripción |
|---|---|---|
| `createExpirationLog` | `Future<ExpirationLogInDb> createExpirationLog(CreateExpirationLog log)` | Registra una nueva alerta de caducidad. |
| `getAllExpirationLogs` | `Future<List<ExpirationLogInDb>> getAllExpirationLogs(ExpirationQueryParams params)` | Obtiene todas las alertas de caducidad con filtros. |
| `getExpirationLogById` | `Future<ExpirationLogInDb?> getExpirationLogById(String id)` | Obtiene una alerta de caducidad por su ID. |
| `deleteExpirationLogById` | `Future<ExpirationLogInDb?> deleteExpirationLogById(String id)` | Elimina un registro de caducidad. |
| `hasExpiration` | `Future<bool> hasExpiration(String branchId)` | Verifica si una sucursal tiene productos caducados o próximos a vencer. |

---

## 6. Servicios y Herramientas

### 6.1 HttpTools

Utilidad estática para construir URIs y headers.

```dart
// Construir URI
Uri uri = HttpTools.generateUri(
  '/products',
  queryParams: {'offset': '0', 'limit': '50'},
);

// Generar headers de autenticación
Map<String, String> headers = HttpTools.generateAuthHeaders();
```

| Método estático | Descripción |
|---|---|
| `generateUri(String path, {Map<String, dynamic>? queryParams, int version = 1})` | Construye la URI completa: `{baseUrl}/api/v{version}{path}?{params}` |
| `generateAuthHeaders()` | Retorna headers `Authorization`, `X-Agent`, opcionalmente `X-Servin` y `X-Branch` |

### 6.2 TokenManager

Singleton para gestión del JWT en memoria.

| Método | Descripción |
|---|---|
| `storeToken(String token)` | Almacena el token JWT actual |
| `getToken()` | Recupera el token actual o `null` |
| `removeToken()` | Elimina el token |
| `isTokenGotExpired()` | `true` si el token expira en menos de 1 hora |

### 6.3 HttpService

Mixin para operaciones HTTP estándar sin caché. Usado por la mayoría de los DataSources.

| Método | Método HTTP | Descripción |
|---|---|---|
| `getQuery(String path, {Map<String, dynamic>? queryParams})` | `GET` | Consulta GET |
| `postQuery(String path, {Map<String, dynamic>? queryParams, Map<String, dynamic>? body})` | `POST` | Creación |
| `putQuery(String path, {Map<String, dynamic>? queryParams, Map<String, dynamic>? body})` | `PUT` | Reemplazo total |
| `patchQuery(String path, {Map<String, dynamic>? queryParams, Map<String, dynamic>? body})` | `PATCH` | Actualización parcial |
| `deleteQuery(String path, {Map<String, dynamic>? queryParams})` | `DELETE` | Eliminación |
| `multipartQuery(String path, {required String method, Map<String, dynamic>? fields, List<MultipartFile>? files})` | Multipart | Subida de archivos |

### 6.4 DioHttpService

Mixin para operaciones HTTP con caché en disco vía Hive. Usado por `AdminPanelDataSource`, `IntegrationsDataSource` y `TransfersDataSource`.

| Método | Descripción |
|---|---|
| `getCachedQuery(String path, {Map<String, dynamic>? queryParams, String cacheKey, Duration? maxStale})` | GET con caché en Hive |
| `post(String path, {Map<String, dynamic>? body})` | POST sin caché |

### 6.5 HiveService

Mixin para abrir/cerrar cajas Hive (almacenamiento clave-valor local).

| Método | Descripción |
|---|---|
| `openBox<T>(String name)` | Abre una caja Hive |
| `closeBox(String name)` | Cierra una caja Hive |

### 6.6 ReactiveRepository

Mixin que añade capacidad reactiva a un repositorio. Emite eventos a través de un `Stream` cuando se crean, actualizan o eliminan entidades.

```dart
enum RepoOperation { created, updated, deleted }

class RepoEvent<T> {
  final RepoOperation operation;
  final T model;
}
```

Actualmente ningún repositorio del paquete utiliza este mixin, pero está disponible para que el proyecto consumidor lo aplique si necesita reactividad.

---

## 7. Excepciones HTTP

El paquete define una jerarquía de excepciones selladas en `http_exceptions.dart`:

| Excepción | Código HTTP | Descripción |
|---|---|---|
| `NoInternetException` | N/A | Sin conexión a internet |
| `ServerException` | 5xx | Error interno del servidor |
| `BadRequestException` | 400 | Datos inválidos en la petición |
| `UnauthorizedException` | 401 | Token expirado o credenciales inválidas |
| `ForbiddenException` | 403 | Sin permisos para el recurso |
| `InternalRequestException` | Otros 4xx | Otros errores de cliente |

Todas extienden de `HttpException` que incluye el `statusCode` y el `message` del servidor.

---

## 8. Modelos Compartidos y Respuestas

### 8.1 ListResponse\<T\>

Wrapper genérico para respuestas paginadas del servidor:

```dart
class ListResponse<T> {
  final int count;
  final List<T> data;

  factory ListResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT);
}
```

Usado por repositorios que retornan grandes volúmenes de datos: `ClientTransactionsRepository`, `EntryHistoriesRepository`, `ExitHistoriesRepository`, `InvoicesRepository`, `OrdersRepository`, `ProductTransactionsRepository`, `ReceiptsRepository`, etc.

### 8.2 LoginResponse

Respuesta del endpoint de autenticación:

```dart
class LoginResponse {
  final KardexUser user;
  final String accessToken;
}
```

`KardexUser` incluye los datos del usuario autenticado: ID, nombre, email, rol, sucursal, etc.

### 8.3 Otras Respuestas Tipadas

| Clase | Uso |
|---|---|
| `UserStatusResponse` | Estado de conexión/actividad de un usuario |
| `ServinStatusResponse` | Estado del licenciamiento Servin |
| `AdminChartsResponses` | Datos agregados para gráficos del dashboard |
| `InvoiceTotals` | Totales de facturación (monto, impuestos, descuentos) |
| `ProductSalesTotal` | Ventas agregadas por producto |
| `ReceiptTotal` | Totales de recibos de pago |
| `OrderToInvoiceResponse` | Resultado de convertir un pedido en factura |
| `InvoiceDevolutionResponse` | Datos de devolución de factura anónima |
| `TotalsResult` | Resultados totales de reportes por rango de fechas |
| `ProductStockDemand` | Comparativa stock vs demanda para pedidos |

---

## 9. Parámetros de Consulta

El paquete incluye clases tipadas para construir query params de forma segura. Cada una tiene un método de serialización que convierte los filtros a `Map<String, dynamic>`:

| Clase | Método de serialización | Repositorios que la usan |
|---|---|---|
| `AdjustQueryParams` | `.toMap()` | `AdjustEntriesRepository`, `AdjustExitsRepository` |
| `ClientQueryParams` | `.toMap()` | `ClientsRepository` |
| `ClientTransactionQueryParams` | `.toMap()` | `ClientTransactionsRepository` |
| `DailySummaryQueryParams` | `.toQueryParams()` | `DailySummariesRepository`, `ExecutiveSummariesRepository` |
| `DevolutionQueryParams` | `.toMap()` | `DevolutionsRepository` |
| `ExpenseQueryParams` | `.toMap()` | `ExpensesRepository` |
| `ExpirationQueryParams` | `.toMap()` | `ExpirationLogsRepository` |
| `InvoiceQueryParams` | `.toMap()` | `InvoicesRepository`, `DevolutionsRepository`, `ReceiptsRepository` |
| `OrderQueryParams` | `.toQueryParameters()` | `OrdersRepository` |
| `ProductQueryParams` | `.toQueryParameters()` | `ProductsRepository` |
| `ProductStatQueryParams` | `.toQueryMap()` | `ProductStatsRepository` |
| `ReceiptQueryParams` | `.toMap()` | `ReceiptsRepository` |
| `TotalsQueryParams` | `.toMap()` | `ReportsRepository` |
| `TransactionQueryParams` | (se pasa directo) | `ProductTransactionsRepository` |
| `TransferQueryParams` | `.toQueryMap()` | `TransfersRepository` |

---

## 10. Ejemplo de Uso

```dart
import 'package:kardex_business/kardex_business.dart';

void main() async {
  // 1. Inicializar el cliente
  KardexClient.initialize(MiConfig(
    baseUrl: 'http://localhost:8000',
    branchId: 'branch-001',
  ));

  // 2. Autenticarse
  final authRepo = AuthRepository();
  final loginResponse = await authRepo.login('admin', 'password123');

  // 3. Consultar productos
  final productosRepo = ProductsRepository();
  final productos = await productosRepo.getPaginatedProducts(0);

  // 4. Obtener inventario por sucursal
  final inventarioRepo = InventoriesRepository();
  final inventario = await inventarioRepo.getAllInventories('branch-001');

  // 5. Crear un pedido
  final pedidosRepo = OrdersRepository();
  final nuevoPedido = await pedidosRepo.createOrder(CreateOrder(
    clientId: 'client-123',
    products: [...],
  ));

  // 6. Convertir pedido a factura
  final facturaResponse = await pedidosRepo.convertOrderToInvoice(nuevoPedido.id);

  // 7. Consultar dashboard
  final dashboardRepo = AdminPanelRepository();
  final charts = await dashboardRepo.getAdminCharts(
    endDate: DateTime.now().millisecondsSinceEpoch,
  );

  // 8. Verificar caducidades
  final expRepo = ExpirationLogsRepository();
  final hayCaducados = await expRepo.hasExpiration('branch-001');

  // 9. Obtener reporte financiero
  final reportesRepo = ReportsRepository();
  final totales = await reportesRepo.getTotalResultsByDateRange(
    TotalsQueryParams(startDate: '2024-01-01', endDate: '2024-01-31'),
  );

  // 10. Cerrar sesión
  TokenManager().removeToken();
}
```

---

## Resumen Estadístico

| Métrica | Cantidad |
|---|---|
| Repositorios totales | **37** |
| Con caché en memoria | 11 |
| Con `ReactiveRepository` disponible | 0 (disponible como mixin) |
| Con clase de Query Params | 16 |
| Sólo lectura | 7 |
| Con múltiples DataSources | 3 |
| Con máquina de estados (⚡) | 3 |
| Con `ListResponse<T>` | 10 |
| Con búsqueda local en caché | 3 |
| Método más grande | `InvoicesRepository` (15 métodos) |
