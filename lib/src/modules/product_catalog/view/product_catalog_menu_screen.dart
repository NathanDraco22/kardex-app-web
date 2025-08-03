import 'package:flutter/material.dart';

class ProductCatalogMenuScreen extends StatelessWidget {
  const ProductCatalogMenuScreen({super.key});

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
      appBar: AppBar(title: const Text("Catalogo de Productos")),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.square_rounded),
            title: const Text("Lista de Productos"),
            onTap: () {},
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(
            height: 0.0,
          ),
          ListTile(
            leading: const Icon(Icons.monetization_on_outlined),
            title: const Text("Lista de Precios por Producto"),
            onTap: () {},
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(
            height: 0.0,
          ),
          ListTile(
            leading: const Icon(Icons.category_rounded),
            title: const Text("Lista de Categorias de Productos"),
            onTap: () {},
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(
            height: 0.0,
          ),
        ],
      ),
    );
  }
}
