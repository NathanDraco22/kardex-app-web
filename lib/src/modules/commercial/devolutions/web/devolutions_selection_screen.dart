import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'devolutions_confirmation_screen.dart';
import 'mediators/devolutions_selection_mediator.dart';

part 'devolutions_selection_sections/content_section.dart';
part 'devolutions_selection_sections/header_section.dart';

class DevolutionsSelectionScreen extends StatefulWidget {
  const DevolutionsSelectionScreen({
    super.key,
    required this.invoice,
    required this.devolutions,
  });

  final InvoiceInDb invoice;
  final List<DevolutionInDb> devolutions;

  @override
  State<DevolutionsSelectionScreen> createState() => _DevolutionsSelectionScreenState();
}

class _DevolutionsSelectionScreenState extends State<DevolutionsSelectionScreen> {
  final viewController = DevolutionsSelectionViewController();

  @override
  Widget build(BuildContext context) {
    return DevolutionsSelectionMediator(
      notifier: viewController,
      child: _RootScaffold(
        invoice: widget.invoice,
        devolutions: widget.devolutions,
      ),
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
      body: _Body(
        invoice: invoice,
        devolutions: devolutions,
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.check),
        label: const Text("Crear Devolución"),
        onPressed: () async {
          final viewController = DevolutionsSelectionMediator.of(context).notifier!;
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
                      if (value.length < 15) return "El motivo debe tener más de 15 caracteres";
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
                builder: (context) => DevolutionsConfirmationScreen(
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
