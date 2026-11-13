import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';

class RoleEditorResult {
  final String name;
  final List<String> access;

  const RoleEditorResult({
    required this.name,
    required this.access,
  });
}

Future<RoleEditorResult?> showRoleEditorDialog(
  BuildContext context, {
  required ModulesCatalog catalog,
  UserRoleInDb? existingRole,
}) {
  return showDialog<RoleEditorResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _RoleEditorDialog(
      catalog: catalog,
      existingRole: existingRole,
    ),
  );
}

class _RoleEditorDialog extends StatefulWidget {
  const _RoleEditorDialog({
    required this.catalog,
    this.existingRole,
  });

  final ModulesCatalog catalog;
  final UserRoleInDb? existingRole;

  @override
  State<_RoleEditorDialog> createState() => _RoleEditorDialogState();
}

class _RoleEditorDialogState extends State<_RoleEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late Set<String> _selectedAccess;

  bool get _isEditing => widget.existingRole != null;
  bool get _isAdminRole => widget.existingRole?.id == 'Admin';
  bool get _hasAllAccess =>
      _selectedAccess.contains(widget.catalog.allAccessKey);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingRole?.name ?? '',
    );
    _selectedAccess = Set<String>.from(widget.existingRole?.access ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleAllAccess(bool enabled) {
    if (_isAdminRole && !enabled) return;
    setState(() {
      if (enabled) {
        _selectedAccess = {widget.catalog.allAccessKey};
      } else {
        _selectedAccess.remove(widget.catalog.allAccessKey);
      }
    });
  }

  void _toggleModule(ModuleDefinition module, bool enabled) {
    setState(() {
      if (enabled) {
        _selectedAccess.add(module.key);
      } else {
        _selectedAccess.remove(module.key);
        for (final sub in module.submodules) {
          _selectedAccess.remove(sub.key);
        }
      }
    });
  }

  void _toggleSubmodule(
    ModuleDefinition parent,
    SubModuleDefinition sub,
    bool enabled,
  ) {
    setState(() {
      if (enabled) {
        _selectedAccess.add(parent.key);
        _selectedAccess.add(sub.key);
      } else {
        _selectedAccess.remove(sub.key);
      }
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedAccess.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activa al menos un módulo o permiso para el rol.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      RoleEditorResult(
        name: _nameController.text.trim(),
        access: _selectedAccess.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final dialogWidth = width > 720 ? 640.0 : width * 0.92;

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.indigo.shade700,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Editar Rol' : 'Nuevo Rol',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Activa los módulos y submódulos permitidos',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        height: MediaQuery.sizeOf(context).height * 0.68,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                enabled: !_isAdminRole,
                decoration: InputDecoration(
                  labelText: 'Nombre del Rol',
                  hintText: 'Ej. Cajero, Bodega, Auditor...',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: _isAdminRole
                      ? Colors.grey.shade100
                      : const Color(0xFFF8FAFC),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa un nombre para el rol';
                  }
                  if (value.trim().length < 2) {
                    return 'El nombre debe tener al menos 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: _hasAllAccess
                      ? Colors.indigo.shade50
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hasAllAccess
                        ? Colors.indigo.shade300
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: SwitchListTile(
                  value: _hasAllAccess,
                  onChanged: _isAdminRole ? null : _toggleAllAccess,
                  secondary: Icon(
                    Icons.verified_user_rounded,
                    color: _hasAllAccess
                        ? Colors.indigo.shade700
                        : Colors.grey.shade600,
                  ),
                  title: const Text(
                    'Acceso Total (Administrador)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: Text(
                    _isAdminRole
                        ? 'El rol Admin siempre mantiene acceso total.'
                        : 'Otorga acceso completo a todos los módulos del sistema.',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Módulos del Sistema',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _hasAllAccess
                          ? 'Todos activos'
                          : '${_selectedAccess.length} permiso(s)',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.catalog.modules.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final module = widget.catalog.modules[index];
                    final isModuleActive =
                        _hasAllAccess || _selectedAccess.contains(module.key);

                    return _ModuleSwitchCard(
                      module: module,
                      isModuleActive: isModuleActive,
                      isLockedByAll: _hasAllAccess,
                      selectedAccess: _selectedAccess,
                      onToggleModule: (val) => _toggleModule(module, val),
                      onToggleSubmodule: (sub, val) =>
                          _toggleSubmodule(module, sub, val),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save_rounded, size: 18),
          label: Text(_isEditing ? 'Guardar Cambios' : 'Crear Rol'),
        ),
      ],
    );
  }
}

class _ModuleSwitchCard extends StatelessWidget {
  const _ModuleSwitchCard({
    required this.module,
    required this.isModuleActive,
    required this.isLockedByAll,
    required this.selectedAccess,
    required this.onToggleModule,
    required this.onToggleSubmodule,
  });

  final ModuleDefinition module;
  final bool isModuleActive;
  final bool isLockedByAll;
  final Set<String> selectedAccess;
  final ValueChanged<bool> onToggleModule;
  final void Function(SubModuleDefinition sub, bool value) onToggleSubmodule;

  @override
  Widget build(BuildContext context) {
    final hasSubmodules = module.submodules.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isModuleActive
              ? Colors.blue.shade200
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            value: isModuleActive,
            onChanged: isLockedByAll ? null : onToggleModule,
            title: Text(
              module.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              module.description,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          if (hasSubmodules && isModuleActive) ...[
            const Divider(height: 1),
            Container(
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text(
                      'Submódulos de ${module.name}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.blueGrey.shade600,
                      ),
                    ),
                  ),
                  ...module.submodules.map((sub) {
                    final isSubActive =
                        isLockedByAll || selectedAccess.contains(sub.key);
                    return SwitchListTile(
                      dense: true,
                      value: isSubActive,
                      onChanged: isLockedByAll
                          ? null
                          : (val) => onToggleSubmodule(sub, val),
                      title: Text(
                        sub.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        sub.description,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
