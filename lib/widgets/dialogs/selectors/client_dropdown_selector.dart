import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/client_selection_dialog.dart';
import 'package:kardex_business/kardex_business.dart';

/// Selector de cliente con estética de botón desplegable (OutlinedButton con bordes redondeados,
/// icono de empresa/negocio, flecha dropdown y botón X de limpieza rápida),
/// que al ser pulsado abre el diálogo modal [showClientSelectionDialog].
class ClientDropdownSelector extends StatelessWidget {
  const ClientDropdownSelector({
    super.key,
    this.selectedClient,
    this.selectedClientId,
    this.selectedClientName,
    this.clientsMap,
    this.clientsList,
    this.onChanged,
    this.onIdChanged,
    this.allOptionText = "Todos los Clientes",
    this.width,
    this.isExpanded = false,
  });

  /// Instancia de [ClientInDb] seleccionada actualmente.
  final ClientInDb? selectedClient;

  /// ID del cliente seleccionado (alternativo o complementario a [selectedClient]).
  final String? selectedClientId;

  /// Nombre del cliente seleccionado (usado cuando solo se dispone del nombre).
  final String? selectedClientName;

  /// Mapa opcional de clientes [id: nombre] para resolución de nombres en memoria.
  final Map<String, String>? clientsMap;

  /// Lista opcional de [ClientInDb].
  final List<ClientInDb>? clientsList;

  /// Callback con la entidad [ClientInDb] seleccionada (o `null` al limpiar).
  final ValueChanged<ClientInDb?>? onChanged;

  /// Callback únicamente con el ID seleccionado (o `null` al limpiar).
  final ValueChanged<String?>? onIdChanged;

  /// Texto mostrado cuando no hay cliente seleccionado.
  final String allOptionText;

  /// Ancho fijo opcional del botón.
  final double? width;

  /// Si es `true`, el contenido del botón toma el ancho máximo disponible.
  final bool isExpanded;

  Future<void> _pickClient(BuildContext context) async {
    final selected = await showClientSelectionDialog(context);
    if (selected != null) {
      onChanged?.call(selected);
      onIdChanged?.call(selected.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determinar el nombre a mostrar y si hay un cliente seleccionado
    String displayName;
    bool isClientSelected = false;

    if (selectedClient != null) {
      displayName = selectedClient!.name;
      isClientSelected = true;
    } else if (selectedClientName != null && selectedClientName!.isNotEmpty) {
      displayName = selectedClientName!;
      isClientSelected = true;
    } else if (selectedClientId != null && selectedClientId!.isNotEmpty) {
      if (clientsMap != null && clientsMap!.containsKey(selectedClientId)) {
        displayName = clientsMap![selectedClientId]!;
      } else if (clientsList != null && clientsList!.any((c) => c.id == selectedClientId)) {
        displayName = clientsList!.firstWhere((c) => c.id == selectedClientId).name;
      } else {
        displayName = selectedClientId!;
      }
      isClientSelected = true;
    } else {
      displayName = allOptionText;
      isClientSelected = false;
    }

    final btn = OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(
        isClientSelected ? Icons.business : Icons.business_outlined,
        color: Theme.of(context).colorScheme.primary,
        size: 20,
      ),
      label: Row(
        mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              displayName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          if (isClientSelected)
            Tooltip(
              message: "Restablecer a $allOptionText",
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  onChanged?.call(null);
                  onIdChanged?.call(null);
                },
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(Icons.close, size: 19, color: Colors.red.shade400),
                ),
              ),
            )
          else
            const Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey),
        ],
      ),
      onPressed: () => _pickClient(context),
    );

    if (width != null) {
      return SizedBox(width: width, child: btn);
    }

    return btn;
  }
}
