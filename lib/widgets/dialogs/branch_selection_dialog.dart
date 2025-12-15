import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch_model.dart';

Future<BranchInDb?> showBranchSelectionDialog(BuildContext context, List<BranchInDb> branches) async {
  return await showDialog<BranchInDb?>(
    context: context,
    builder: (context) => BranchSelectionDialog(branches: branches),
  );
}

class BranchSelectionDialog extends StatelessWidget {
  final List<BranchInDb> branches;
  const BranchSelectionDialog({super.key, required this.branches});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Seleccionar Sucursal"),
      content: SizedBox(
        width: 500,
        child: branches.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("No hay sucursales disponibles"),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: branches.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final branch = branches[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(branch.name.substring(0, 1).toUpperCase()),
                    ),
                    title: Text(branch.name),
                    subtitle: Text(branch.address),
                    onTap: () {
                      Navigator.pop(context, branch);
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
      ],
    );
  }
}
