import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch_model.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/models/client/initial_balance_model.dart';
import 'package:kardex_app_front/src/domain/repositories/branch_repository.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/widgets/dialogs/branch_selection_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

Future<({String branchId, List<InitBalanceItem> balances})?> showSetInitialBalanceDialog(
  BuildContext context,
  ClientInDb client,
) async {
  return await showDialog<({String branchId, List<InitBalanceItem> balances})?>(
    context: context,
    builder: (context) {
      return SetInitialBalanceDialog(client: client);
    },
  );
}

class SetInitialBalanceDialog extends StatefulWidget {
  final ClientInDb client;

  const SetInitialBalanceDialog({super.key, required this.client});

  @override
  State<SetInitialBalanceDialog> createState() => _SetInitialBalanceDialogState();
}

class _SetInitialBalanceDialogState extends State<SetInitialBalanceDialog> {
  BranchInDb? _selectedBranch;
  List<InitBalanceItem> balances = [];

  void _selectBranch() async {
    final branches = context.read<BranchesRepository>().branches;
    final selected = await showBranchSelectionDialog(context, branches);
    if (selected != null) {
      setState(() {
        _selectedBranch = selected;
      });
    }
  }

  void _addBalance() async {
    final newBalance = await _showAddEditBalanceDialog(context);
    if (newBalance != null) {
      setState(() {
        balances.add(newBalance);
      });
    }
  }

  void _editBalance(int index) async {
    final updatedBalance = await _showAddEditBalanceDialog(context, balanceToEdit: balances[index]);
    if (updatedBalance != null) {
      setState(() {
        balances[index] = updatedBalance;
      });
    }
  }

  void _deleteBalance(int index) async {
    final result = await DialogManager.confirmActionDialog(
      context,
      "¿Estás seguro de que deseas eliminar este saldo inicial?",
    );
    if (result) {
      setState(() {
        balances.removeAt(index);
      });
    }
  }

  void _submit() async {
    if (balances.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor agrega al menos un saldo inicial.')),
      );
      return;
    }

    if (_selectedBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una sucursal.')),
      );
      return;
    }

    final totalFormatted = NumberFormatter.convertToMoneyLike(
      balances.fold(0, (sum, item) => sum + item.initialBalance),
    );

    final confirm = await DialogManager.slideToConfirmActionDialog(
      context,
      '¿Confirmar creación de ${balances.length} saldos por un total de $totalFormatted\npara ${widget.client.name}?',
    );

    if (confirm) {
      if (!mounted) return;
      context.pop((
        branchId: _selectedBranch!.id,
        balances: balances,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AlertDialog(
        title: Text('Saldos Iniciales: ${widget.client.name}'),
        content: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: Colors.grey.shade400, width: 1),
                ),
                title: Text(_selectedBranch?.name ?? 'Seleccionar Sucursal (Requerido)'),
                subtitle: _selectedBranch != null ? Text(_selectedBranch!.address) : null,
                trailing: const Icon(Icons.store),
                onTap: _selectBranch,
              ),
              const SizedBox(height: 16),
              const Text("Lista de Saldos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Expanded(
                child: balances.isEmpty
                    ? const Center(
                        child: Text(
                          "No has agregado ningún saldo inicial aún.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: balances.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = balances[index];
                          return ListTile(
                            title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Monto: ${NumberFormatter.convertToMoneyLike(item.initialBalance)}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editBalance(index),
                                  tooltip: "Editar",
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteBalance(index),
                                  tooltip: "Eliminar",
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _addBalance,
                icon: const Icon(Icons.add),
                label: const Text("Agregar Saldo"),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => context.pop(null),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Guardar Todo'),
          ),
        ],
      ),
    );
  }

  Future<InitBalanceItem?> _showAddEditBalanceDialog(
    BuildContext context, {
    InitBalanceItem? balanceToEdit,
  }) async {
    final formKey = GlobalKey<FormState>();
    final isEditing = balanceToEdit != null;

    String productName = balanceToEdit?.productName ?? 'SALDO INICIAL';
    String amountText = balanceToEdit != null
        ? NumberFormatter.convertFromCentsToDouble(balanceToEdit.initialBalance).toStringAsFixed(2)
        : '';

    return await showDialog<InitBalanceItem?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? "Editar Saldo" : "Añadir Saldo"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TitleTextField(
                    key: const ValueKey("balance_amount"),
                    textInputAction: TextInputAction.next,
                    title: "Monto (Ej. 150.50)*",
                    initialValue: amountText,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Requerido";
                      if (double.tryParse(value) == null) {
                        return 'Formato numérico incorrecto';
                      }
                      amountText = value.trim();
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TitleTextField(
                    key: const ValueKey("balance_productName"),
                    textInputAction: TextInputAction.done,
                    title: "Concepto/Nombre del Producto (Opcional)",
                    initialValue: productName,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        productName = value.trim().toUpperCase();
                      } else {
                        productName = 'SALDO INICIAL';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final doubleValue = double.parse(amountText);
                  final balanceInCents = NumberFormatter.convertFromDoubleToCents(doubleValue);

                  final newItem = InitBalanceItem(
                    initialBalance: balanceInCents,
                    productName: productName,
                  );
                  Navigator.pop(context, newItem);
                }
              },
              child: Text(isEditing ? "Guardar Cambios" : "Agregar"),
            ),
          ],
        );
      },
    );
  }
}
