import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/settings/view/roles/cubit/roles_cubit.dart';
import 'package:kardex_app_front/src/modules/settings/view/roles/widgets/role_editor_dialog.dart';
import 'package:kardex_business/kardex_business.dart';

class RolesScreen extends StatelessWidget {
  const RolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rolesRepo = context.read<UserRolesRepository>();
    return BlocProvider(
      create: (_) =>
          RolesCubit(userRolesRepository: rolesRepo)..loadRolesAndModules(),
      child: const _RolesView(),
    );
  }
}

class _RolesView extends StatelessWidget {
  const _RolesView();

  Future<void> _openCreateDialog(BuildContext context, ModulesCatalog catalog) async {
    final result = await showRoleEditorDialog(context, catalog: catalog);
    if (result == null || !context.mounted) return;
    await context.read<RolesCubit>().createRole(
          name: result.name,
          access: result.access,
        );
  }

  Future<void> _openEditDialog(
    BuildContext context,
    ModulesCatalog catalog,
    UserRoleInDb role,
  ) async {
    final result = await showRoleEditorDialog(
      context,
      catalog: catalog,
      existingRole: role,
    );
    if (result == null || !context.mounted) return;
    await context.read<RolesCubit>().updateRole(
          roleId: role.id,
          name: result.name,
          access: result.access,
        );
  }

  Future<void> _confirmDelete(BuildContext context, UserRoleInDb role) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Rol'),
        content: Text(
          '¿Seguro que deseas eliminar el rol "${role.name}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await context.read<RolesCubit>().deleteRole(role);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RolesCubit, RolesState>(
      listener: (context, state) {
        if (state is RolesLoaded) {
          if (state.actionError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionError!),
                backgroundColor: Colors.redAccent,
              ),
            );
          } else if (state.actionSuccess != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionSuccess!),
                backgroundColor: Colors.green.shade700,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        final loadedState = state is RolesLoaded ? state : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Roles y Permisos'),
            actions: [
              IconButton(
                tooltip: 'Actualizar',
                onPressed: loadedState?.isSubmitting == true
                    ? null
                    : () => context.read<RolesCubit>().loadRolesAndModules(),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          floatingActionButton: loadedState == null
              ? null
              : Visibility(
                  visible: MediaQuery.viewInsetsOf(context).bottom == 0.0,
                  child: FloatingActionButton.extended(
                    onPressed: loadedState.isSubmitting
                        ? null
                        : () => _openCreateDialog(context, loadedState.catalog),
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Nuevo Rol'),
                  ),
                ),
          body: switch (state) {
            RolesInitial() || RolesLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            RolesError(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Error al cargar roles: $message',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () =>
                            context.read<RolesCubit>().loadRolesAndModules(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            RolesLoaded(:final roles, :final catalog, :final isSubmitting) =>
              Stack(
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: roles.isEmpty
                          ? const Center(
                              child: Text('No hay roles registrados.'),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                              itemCount: roles.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final role = roles[index];
                                return _RoleCard(
                                  role: role,
                                  catalog: catalog,
                                  onEdit: () =>
                                      _openEditDialog(context, catalog, role),
                                  onDelete: role.isDefault
                                      ? null
                                      : () => _confirmDelete(context, role),
                                );
                              },
                            ),
                    ),
                  ),
                  if (isSubmitting)
                    Container(
                      color: Colors.black12,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
          },
        );
      },
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.catalog,
    required this.onEdit,
    this.onDelete,
  });

  final UserRoleInDb role;
  final ModulesCatalog catalog;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final hasAllAccess = role.access.contains(catalog.allAccessKey);
    final subtitleText = hasAllAccess
        ? 'Acceso total a todos los módulos'
        : '${role.access.length} permiso(s) activo(s)';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: hasAllAccess
                ? Colors.indigo.shade50
                : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            hasAllAccess
                ? Icons.verified_user_rounded
                : Icons.admin_panel_settings_outlined,
            color: hasAllAccess
                ? Colors.indigo.shade700
                : Colors.blue.shade700,
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                role.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: role.isDefault
                    ? Colors.amber.shade50
                    : Colors.teal.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: role.isDefault
                      ? Colors.amber.shade200
                      : Colors.teal.shade200,
                ),
              ),
              child: Text(
                role.isDefault ? 'Sistema' : 'Personalizado',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: role.isDefault
                      ? Colors.amber.shade900
                      : Colors.teal.shade800,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitleText,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Editar permisos',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: role.isDefault
                  ? 'Los roles del sistema no se pueden eliminar'
                  : 'Eliminar rol',
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                color: onDelete == null
                    ? Colors.grey.shade400
                    : Colors.red.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
