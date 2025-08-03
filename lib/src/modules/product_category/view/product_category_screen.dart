import 'package:flutter/material.dart';

import '../dialogs/create_product_category_dialog.dart';
import '../widgets/product_category_table.dart';

class ProductCategoryScreen extends StatelessWidget {
  const ProductCategoryScreen({super.key});

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
      appBar: AppBar(title: const Text("Lista de Clientes")),
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
                          return const CreateProductCategoryDialog();
                        },
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Agregar Nuevo Cliente"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Expanded(
              child: ProductCategoryTable(),
            ),
          ],
        ),
      ),
    );
  }
}
