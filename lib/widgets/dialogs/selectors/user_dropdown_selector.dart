import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/user_selection_dialog.dart';
import 'package:kardex_business/kardex_business.dart';

/// Selector de usuario con estética de botón desplegable (OutlinedButton con bordes redondeados,
/// iconos person / group_outlined, flecha dropdown y botón X de limpieza rápida),
/// que al ser pulsado abre el diálogo modal [showActiveUserSelectionDialog].
///
/// Si el usuario actual tiene rol de ventas (Vendedor o Preventa según [RoleTools.isSeller]),
/// el componente se bloquea en modo solo lectura mostrando únicamente su usuario.
class UserDropdownSelector extends StatelessWidget {
  const UserDropdownSelector({
    super.key,
    this.selectedUser,
    this.selectedUserId,
    this.selectedUserName,
    this.usersMap,
    this.usersList,
    this.onChanged,
    this.onIdChanged,
    this.allOptionText = "Todos los Usuarios",
    this.width,
    this.isExpanded = false,
  });

  /// Instancia de [UserInDb] seleccionada actualmente.
  final UserInDb? selectedUser;

  /// ID del usuario seleccionado (alternativo o complementario a [selectedUser]).
  final String? selectedUserId;

  /// Nombre del usuario seleccionado (usado cuando solo se dispone del nombre).
  final String? selectedUserName;

  /// Mapa opcional de usuarios [id: nombre] para resolución de nombres en memoria.
  final Map<String, String>? usersMap;

  /// Lista opcional de [UserInDb].
  final List<UserInDb>? usersList;

  /// Callback con la entidad [UserInDb] seleccionada (o `null` al limpiar).
  final ValueChanged<UserInDb?>? onChanged;

  /// Callback únicamente con el ID seleccionado (o `null` al limpiar).
  final ValueChanged<String?>? onIdChanged;

  /// Texto mostrado cuando no hay usuario seleccionado.
  final String allOptionText;

  /// Ancho fijo opcional del botón.
  final double? width;

  /// Si es `true`, el contenido del botón toma el ancho máximo disponible.
  final bool isExpanded;

  Future<void> _pickUser(BuildContext context) async {
    final (isSeller, _) = RoleTools.isSeller();
    if (isSeller) return;

    final selected = await showActiveUserSelectionDialog(context);
    if (selected != null) {
      onChanged?.call(selected);
      onIdChanged?.call(selected.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (isSeller, sellerUser) = RoleTools.isSeller();

    // Determinar el nombre a mostrar y si hay un usuario seleccionado
    String displayName;
    bool isUserSelected = false;

    if (isSeller && sellerUser != null) {
      displayName = sellerUser.username;
      isUserSelected = true;
    } else if (selectedUser != null) {
      displayName = selectedUser!.username;
      isUserSelected = true;
    } else if (selectedUserName != null && selectedUserName!.isNotEmpty) {
      displayName = selectedUserName!;
      isUserSelected = true;
    } else if (selectedUserId != null && selectedUserId!.isNotEmpty) {
      if (usersMap != null && usersMap!.containsKey(selectedUserId)) {
        displayName = usersMap![selectedUserId]!;
      } else if (usersList != null && usersList!.any((u) => u.id == selectedUserId)) {
        displayName = usersList!.firstWhere((u) => u.id == selectedUserId).username;
      } else {
        displayName = selectedUserId!;
      }
      isUserSelected = true;
    } else {
      displayName = allOptionText;
      isUserSelected = false;
    }

    final btn = OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(
        isUserSelected ? Icons.person : Icons.group_outlined,
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
          if (isUserSelected && !isSeller)
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
          else if (!isSeller)
            const Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey),
        ],
      ),
      onPressed: isSeller ? null : () => _pickUser(context),
    );

    if (width != null) {
      return SizedBox(width: width, child: btn);
    }

    return btn;
  }
}
