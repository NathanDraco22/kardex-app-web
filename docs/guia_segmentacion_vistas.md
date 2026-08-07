# Guía: Segmentación de Vistas UI

Reglas generales para estructurar interfaces complejas de forma mantenible y escalable.
Agnósticas a lenguaje, framework o librería: aplicables a Flutter, React, Vue, SwiftUI, etc.

---

## 1. La pantalla es un orquestador, no un monolito

Un componente raíz que **solo arma el layout** y delega cada región visual a un componente
independiente. El orquestador no contiene lógica de negocio ni detalles de implementación:
conecta regiones y define proporciones, orden y espaciado.

- La raíz debe poder leerse de corrido (10-40 líneas): se entiende la pantalla con una mirada.
- Cada región (header, contenido, panel lateral, barra de acciones...) es un componente propio.

## 2. Una unidad = una responsabilidad

Criterios para extraer una región a su propia unidad:

- Supera un tamaño razonable de líneas (≈200).
- Tiene estado interno o lógica propia (búsqueda, filtros, expansión).
- Se reutiliza en más de un contexto.

Reglas de la unidad extraída:

- Todo lo interno es **privado** a la unidad (clases/componentes `_privados`).
- Solo el orquestador se expone al resto del sistema.
- Una unidad = una razón de cambio. Si un cambio toca dos regiones sin relación,
  la frontera está mal trazada.

## 3. Comunicación sin prop-drilling

Las secciones necesitan el estado de la pantalla. En lugar de pasar props/callbacks
por una cadena de widgets, **exponer el estado por contexto**:

- InheritedWidget / InheritedNotifier, Provider, slots, inyección de dependencias...
  cualquier mecanismo de tu stack que permita leer desde cualquier descendiente.
- Las secciones leen el estado directamente (`obtener de contexto`) y notifican intenciones.
- El contrato: la raíz provee, las secciones consumen. No hay intermediarios.

Beneficio: mover, reordenar o extraer secciones no obliga a reescribir la cadena de props.

## 4. Fuente de verdad única por pantalla

Un único objeto de estado mutable (notifier / store / view-model / controller) concentra
todo el estado local de la pantalla:

- **Setters con efectos secundarios**: cambiar un selector puede recalcular precios,
  invalidar dependencias o cambiar el método de pago. Ese efecto vive en el setter,
  no en la UI.
- **Getters derivados**: totales, validaciones, estados combinados se calculan en el
  objeto de estado, no en los componentes.
- La UI **solo lee y notifica intención**: nunca muta datos ni esconde reglas de negocio.
- La UI se suscribe de forma **granular**: solo los componentes afectados se reconstruyen
  (listeners/selectores específicos, no reconstruir la pantalla entera).

## 5. Estado asíncrono en dos canales

Separar **lectura** (fetch, búsqueda, filtros) de **escritura** (crear, actualizar, eliminar):

- Los filtros y búsquedas **no deben borrar los datos visibles**: usa un estado
  intermedio de tipo "buscando" que conserva la carga anterior y muestra un indicador
  discreto (barra de progreso) en lugar de un spinner central que vacía la pantalla.
- Los efectos secundarios de escritura (loading, error, éxito) se **orquestan en un
  solo lugar** (listener/efecto raíz), no dispersos en cada botón.
- Flujo típico: botón → mutación → estado transitorio "en progreso" → éxito/error
  → sincronización del canal de lectura.

## 6. Adaptación por capacidad, no por dispositivo

Decidir el layout por **ancho disponible**, no por tipo de dispositivo:

- Breakpoints para variantes, o un layout único que se reacomoda (proporciones,
  columnas según espacio).
- Ocultar/mostrar acciones según el espacio disponible, no según "es celular/tablet".
- No duplicar pantallas completas si el mismo layout funciona adaptándose.
- Regla pragmática: si un dispositivo no es objetivo del módulo, igualmente el layout
  debe **degradar sin romperse** (sin overflow, sin contenido inaccesible).

## 7. Reutilizar lo genérico, copiar lo que diverge

- Los componentes de propósito general (selectores, visualizadores de unidades,
  formateadores, diálogos de confirmación) van al nivel **compartido**.
- Si un módulo necesita una variante específica del comportamiento, **cópiala local**,
  hazla exclusiva del módulo y modifícala ahí.
- **Nunca sobrecargues** el componente compartido con flags del caso particular:
  cada flag nuevo es un acoplamiento nuevo. Un diálogo compartido que acumula opciones
  para "este módulo" se vuelve inmantenible.
- Si la variante es genuinamente general, primero generalízala en el nivel compartido;
  si solo sirve a un contexto, que viva en ese contexto.

## 8. Feedback siempre visible

Todo estado debe ser evidente para el usuario:

- Estados bien definidos: **vacío, carga, error, sin resultados, deshabilitado**.
- Si un botón se deshabilita por una condición (falta de datos, valores inválidos),
  **explica el porqué** con un tooltip o mensaje contextual.
- Los estados vacíos invitan a la acción ("agrega un producto", "reintenta").
- Los errores ofrecen una salida (reintentar, volver).

## 9. Regla de oro: una sola razón de cambio

Antes de escribir o extraer código, pregúntate:

- ¿Este cambio toca más de una responsabilidad? → divide.
- ¿Esta unidad tendría que modificarse por motivos no relacionados? → la frontera está mal.
- ¿Puedo mover, reordenar o eliminar esta región sin tocar las demás? → el diseño es correcto.

La segmentación no es un fin: es el medio para que un cambio local sea local.

---

*Documento de principios generales. Los nombres de patrones (mediator, notifier, cubit)
son ejemplos; en cada stack se implementan con los mecanismos nativos equivalentes.*
