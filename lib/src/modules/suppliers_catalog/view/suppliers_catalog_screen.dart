import 'package:flutter/material.dart';

import '../dialogs/create_supplier_dialog.dart';
import '../widgets/suppliers_table.dart';

class SuppliersCatalogScreen extends StatelessWidget {
  const SuppliersCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lista de Proveedores")),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const CreateSupplierDialog();
                        },
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Agregar Nuevo Proveedor"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Expanded(
              child: SuppliersTable(),
            ),
          ],
        ),
      ),
    );
  }
}
