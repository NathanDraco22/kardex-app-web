import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch_model.dart';

Future<List<String>?> showMultiBranchSelectionDialog(
  BuildContext context, {
  required List<BranchInDb> allBranches,
  required List<String> initialSelectedBranchIds,
}) async {
  return await showDialog<List<String>?>(
    context: context,
    builder: (context) => MultiBranchSelectionDialog(
      allBranches: allBranches,
      initialSelectedBranchIds: initialSelectedBranchIds,
    ),
  );
}

class MultiBranchSelectionDialog extends StatefulWidget {
  final List<BranchInDb> allBranches;
  final List<String> initialSelectedBranchIds;

  const MultiBranchSelectionDialog({
    super.key,
    required this.allBranches,
    required this.initialSelectedBranchIds,
  });

  @override
  State<MultiBranchSelectionDialog> createState() => _MultiBranchSelectionDialogState();
}

class _MultiBranchSelectionDialogState extends State<MultiBranchSelectionDialog> {
  late List<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.initialSelectedBranchIds);
  }

  void _onItemChanged(String id, bool? isSelected) {
    setState(() {
      if (isSelected == true) {
        if (!_selectedIds.contains(id)) {
          _selectedIds.add(id);
        }
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Seleccionar Sucursales"),
      content: SizedBox(
        width: 500,
        child: widget.allBranches.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("No hay sucursales disponibles"),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: widget.allBranches.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final branch = widget.allBranches[index];
                  final isSelected = _selectedIds.contains(branch.id);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) => _onItemChanged(branch.id, value),
                    title: Text(branch.name),
                    subtitle: Text(branch.address),
                    secondary: CircleAvatar(
                      child: Text(branch.name.substring(0, 1).toUpperCase()),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selectedIds),
          child: const Text("Aceptar"),
        ),
      ],
    );
  }
}
