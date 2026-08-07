# Activación Programática de Dropdowns con Atajos de Teclado (FocusNode + ActivateIntent)

Este documento explica el patrón utilizado para desplegar o enfocar menús desplegables (`DropdownButtonFormField`, `DropdownMenu`, etc.) utilizando atajos de teclado globales o contextuales (como `CtrlKeyTip` con **CTRL+1**) en Flutter.

---

## 1. El Problema Original
Por defecto, al asignar un atajo de teclado a una sugerencia visual (`CtrlKeyTip`), este suele invocar un `setState(() {})` simple. Si bien esto actualiza el estado de la vista, no le otorga el foco al control interactivo ni despliega su menú de opciones para navegación por teclado.

---

## 2. La Solución Técnica

Flutter utiliza internamente el patrón **Shortcuts / Actions / Intents**. Todos los widgets de botón e interacción (incluyendo `DropdownButton`) escuchan la intencion estándar `ActivateIntent()` para ejecutar su acción por defecto (abrir el menú desplegable en el caso de los dropdowns).

### Pasos de Implementación

1. **Aceptar `focusNode` en el Widget Selector (`CommercialProductUnitSelector`):**
   ```dart
   class CommercialProductUnitSelector extends StatelessWidget {
     const CommercialProductUnitSelector({
       super.key,
       required this.result,
       required this.onChanged,
       this.focusNode,
     });

     final FocusNode? focusNode;

     @override
     Widget build(BuildContext context) {
       return DropdownButtonFormField<int>(
         focusNode: focusNode,
         // ...
       );
     }
   }
   ```

2. **Crear y vincular el `FocusNode` en la Vista Padre (`CommercialProductDialog`):**
   ```dart
   class _FormContentState extends State<_FormContent> {
     FocusNode unitFocusNode = FocusNode();

     @override
     void dispose() {
       unitFocusNode.dispose();
       super.dispose();
     }

     @override
     Widget build(BuildContext context) {
       return CtrlKeyTip(
         hotKey: "1",
         onShortcut: () {
           // 1. Enfoca el control
           unitFocusNode.requestFocus();
           // 2. Invoca el evento de activación de Flutter sobre el BuildContext del Dropdown
           if (unitFocusNode.context != null) {
             Actions.invoke(unitFocusNode.context!, const ActivateIntent());
           }
         },
         child: CommercialProductUnitSelector(
           focusNode: unitFocusNode,
           result: commercialProductResult,
           onChanged: () => setState(() {}),
         ),
       );
     }
   }
   ```

---

## 3. ¿Por qué se utiliza `unitFocusNode.context`?

En Flutter, `Actions.invoke(context, intent)` busca hacia arriba en la jerarquía del árbol de widgets comenzando desde el `BuildContext` proporcionado:

- Usar el `context` raíz del diálogo busca acciones desde la cima, donde no existe la acción privada del desplegable.
- Usar `unitFocusNode.context` ubica el `BuildContext` exacto adjunto al `DropdownButtonFormField`, permitiendo localizar e invocar directamente el manejador `ActivateIntent` que abre el overlay de opciones.
