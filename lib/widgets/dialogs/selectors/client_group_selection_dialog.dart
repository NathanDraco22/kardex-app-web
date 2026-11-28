import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/client_group_cubit/read_client_group_cubit.dart';
import 'package:kardex_app_front/src/modules/client_catalog/client_groups/dialog/client_group_form_dialog.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

class ClientGroupSelection {
  const ClientGroupSelection(this.group);

  final ClientGroupInDb? group;
}

Future<ClientGroupSelection?> showClientGroupSelectionDialog(
  BuildContext context, {
  String? selectedGroupName,
  bool showNoGroupOption = true,
}) async {
  return await showDialog<ClientGroupSelection?>(
    context: context,
    builder: (context) => ClientGroupSelectionDialog(
      selectedGroupName: selectedGroupName,
      showNoGroupOption: showNoGroupOption,
    ),
  );
}

class ClientGroupSelectionDialog extends StatefulWidget {
  const ClientGroupSelectionDialog({
    super.key,
    this.selectedGroupName,
    this.showNoGroupOption = true,
  });

  final String? selectedGroupName;
  final bool showNoGroupOption;

  @override
  State<ClientGroupSelectionDialog> createState() => _ClientGroupSelectionDialogState();
}

class _ClientGroupSelectionDialogState extends State<ClientGroupSelectionDialog> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ReadClientGroupCubit>().ensureLoaded();
  }

  void _onSearch(String value) {
    setState(() {
      _searchQuery = value.trim().toLowerCase();
    });
  }

  List<ClientGroupInDb> _filterGroups(List<ClientGroupInDb> groups) {
    if (_searchQuery.isEmpty) return groups;

    return groups.where((group) {
      return group.name.toLowerCase().contains(_searchQuery) || group.description.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Future<void> _createGroup() async {
    final created = await showClientGroupFormDialog(context);
    if (!mounted || created == null) return;
    Navigator.pop(context, ClientGroupSelection(created));
  }

  @override
  Widget build(BuildContext context) {
    final dialogHeight = (MediaQuery.sizeOf(context).height * 0.68).clamp(320.0, 620.0).toDouble();
    final selectedGroupName = widget.selectedGroupName?.trim();

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(child: Text("Buscar Grupo de Clientes")),
          IconButton(
            tooltip: "Cerrar",
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: 540,
        height: dialogHeight,
        child: Column(
          children: [
            SearchFieldDebounced(
              autoFocus: true,
              hintText: "Nombre o descripción",
              duration: const Duration(milliseconds: 250),
              onSearch: _onSearch,
            ),
            if (widget.showNoGroupOption) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: ActionChip(
                  avatar: const Icon(Icons.person_off_outlined, size: 18),
                  label: const Text("Sin grupo"),
                  onPressed: () => Navigator.pop(context, const ClientGroupSelection(null)),
                ),
              ),
            ],
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _createGroup,
                icon: const Icon(Icons.add),
                label: const Text("Crear Grupo de Clientes"),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<ReadClientGroupCubit, ReadClientGroupState>(
                builder: (context, state) {
                  if (state is ReadClientGroupLoading || state is ReadClientGroupInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ClientGroupReadError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Error: ${state.message}",
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () => context.read<ReadClientGroupCubit>().loadAllClientGroups(),
                              icon: const Icon(Icons.refresh),
                              label: const Text("Reintentar"),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is! ReadClientGroupSuccess) {
                    return const SizedBox.shrink();
                  }

                  if (state.clientGroups.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Aún no hay grupos de clientes registrados.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final groups = _filterGroups(state.clientGroups);
                  if (groups.isEmpty) {
                    return const Center(child: Text("No se encontraron grupos"));
                  }

                  return ListView.separated(
                    itemCount: groups.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      final isSelected =
                          selectedGroupName != null &&
                          selectedGroupName.isNotEmpty &&
                          group.name.trim() == selectedGroupName;

                      return _ClientGroupResultTile(
                        group: group,
                        isSelected: isSelected,
                        onTap: () => Navigator.pop(context, ClientGroupSelection(group)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientGroupResultTile extends StatelessWidget {
  const _ClientGroupResultTile({
    required this.group,
    required this.isSelected,
    required this.onTap,
  });

  final ClientGroupInDb group;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = group.name.trim();
    final initial = name.isEmpty ? null : name.substring(0, 1).toUpperCase();
    final description = group.description.trim();

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: CircleAvatar(
        child: initial == null ? const Icon(Icons.groups) : Text(initial),
      ),
      title: Text(
        name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: description.isEmpty
          ? null
          : Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }
}
