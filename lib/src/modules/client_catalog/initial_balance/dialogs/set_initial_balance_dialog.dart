import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch_model.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/repositories/branch_repository.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/widgets/dialogs/branch_selection_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

Future<({String branchId, int balance})?> showSetInitialBalanceDialog(
  BuildContext context,
  ClientInDb client,
) async {
  return await showDialog<({String branchId, int balance})?>(
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
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  BranchInDb? _selectedBranch;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectBranch() async {
    final branches = context.read<BranchesRepository>().branches;
    final selected = await showBranchSelectionDialog(context, branches);
    if (selected != null) {
      setState(() {
        _selectedBranch = selected;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBranch == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona una sucursal.')),
        );
        return;
      }

      final doubleValue = double.tryParse(_amountController.text);
      if (doubleValue == null) {
        return;
      }

      final confirm = await DialogManager.slideToConfirmActionDialog(
        context,
        '¿Confirmar saldo inicial de \$ ${_amountController.text}?',
      );

      if (confirm) {
        if (!mounted) return;
        final balanceInCents = NumberFormatter.convertFromDoubleToCents(doubleValue);

        Navigator.pop(context, (
          branchId: _selectedBranch!.id,
          balance: balanceInCents,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Establecer Saldo Inicial'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Cliente: ${widget.client.name}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              TitleTextField(
                title: 'Saldo Inicial (Ej. 150.50)',
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un monto válido';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Formato numérico incorrecto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
