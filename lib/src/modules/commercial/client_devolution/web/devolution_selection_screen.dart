import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/src/modules/commercial/client_devolution/web/devolution_confirmation_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/client_devolution/web/mediators/devolution_selection_mediator.dart';

part 'devolution_sections/content_section.dart';
part 'devolution_sections/header_section.dart';

class DevolutionSelectionScreen extends StatefulWidget {
  const DevolutionSelectionScreen({super.key, required this.invoice});

  final InvoiceInDb invoice;

  @override
  State<DevolutionSelectionScreen> createState() => _DevolutionSelectionScreenState();
}

class _DevolutionSelectionScreenState extends State<DevolutionSelectionScreen> {
  final viewController = DevolutionSelectionViewController();

  @override
  Widget build(BuildContext context) {
    return DevolutionSelectionMediator(
      notifier: viewController,
      child: _RootScaffold(invoice: widget.invoice),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold({required this.invoice});
  final InvoiceInDb invoice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seleccionar para Devolución"),
      ),
      body: _Body(invoice: invoice),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.check),
        label: const Text("Crear Devolución"),
        onPressed: () {
          final viewController = DevolutionSelectionMediator.of(context).notifier!;
          final selectedItems = viewController.selectedItems;

          if (selectedItems.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DevolutionConfirmationScreen(
                  invoice: invoice,
                  selectedItems: selectedItems,
                ),
              ),
            );
          } else {
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
  const _Body({required this.invoice});
  final InvoiceInDb invoice;

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
