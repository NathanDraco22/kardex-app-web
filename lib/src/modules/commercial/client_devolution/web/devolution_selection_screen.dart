import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'devolution_confirmation_screen.dart';
import 'mediators/devolution_selection_mediator.dart';

part 'devolution_sections/content_section.dart';
part 'devolution_sections/header_section.dart';

class DevolutionSelectionScreen extends StatefulWidget {
  const DevolutionSelectionScreen({
    super.key,
    required this.invoice,
    required this.devolutions,
  });

  final InvoiceInDb invoice;
  final List<DevolutionInDb> devolutions;

  @override
  State<DevolutionSelectionScreen> createState() => _DevolutionSelectionScreenState();
}

class _DevolutionSelectionScreenState extends State<DevolutionSelectionScreen> {
  final viewController = DevolutionSelectionViewController();

  @override
  Widget build(BuildContext context) {
    return DevolutionSelectionMediator(
      notifier: viewController,
      child: _RootScaffold(invoice: widget.invoice, devolutions: widget.devolutions),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold({required this.invoice, required this.devolutions});
  final InvoiceInDb invoice;
  final List<DevolutionInDb> devolutions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seleccionar para Devolución"),
      ),
      body: _Body(invoice: invoice, devolutions: devolutions),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.check),
        label: const Text("Crear Devolución"),
        onPressed: () async {
          final viewController = DevolutionSelectionMediator.of(context).notifier!;
          bool confirmed = false;
          await showDialog(
            context: context,
            builder: (context) {
              final formKey = GlobalKey<FormState>();
              return AlertDialog(
                title: const Text("Motivo de Devolución"),
                content: Form(
                  key: formKey,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    initialValue: viewController.devolutionDescription,
                    maxLines: 3,
                    onChanged: (value) {
                      viewController.devolutionDescription = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Campo requerido";
                      if (value.length < 15) return "El motivo debe tener menos de 15 caracteres";
                      return null;
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text("Cancelar"),
                    onPressed: () => context.pop(),
                  ),
                  TextButton(
                    child: const Text("Aceptar"),
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      confirmed = true;
                      context.pop();
                    },
                  ),
                ],
              );
            },
          );

          if (!confirmed) return;

          final selectedItems = viewController.selectedItems;

          if (selectedItems.isNotEmpty) {
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DevolutionConfirmationScreen(
                  invoice: invoice,
                  selectedItems: selectedItems,
                  description: viewController.devolutionDescription,
                ),
              ),
            );
          } else {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Selecciona al menos un producto para devolver.')),
            );
          }
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.invoice, required this.devolutions});
  final InvoiceInDb invoice;
  final List<DevolutionInDb> devolutions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderSection(invoice: invoice),
              const SizedBox(height: 8),
              const Expanded(
                child: _ContentSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
