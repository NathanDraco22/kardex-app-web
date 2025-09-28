import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/const_modules.dart';

class ProductCatalogMenuScreen extends StatelessWidget {
  const ProductCatalogMenuScreen({super.key});

  static const accessName = Modules.products;

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
            leading: const Icon(FluentIcons.cube_12_filled),
            title: const Text("Lista de Productos"),
            onTap: () {
              context.pushNamed("product-list");
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(
            height: 0.0,
          ),

          ListTile(
            leading: const Icon(Icons.tag),
            title: const Text("Unidades de Medida de Productos"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.pushNamed("units");
            },
          ),
          const Divider(height: 0.0),
          ListTile(
            leading: const Icon(Icons.category_rounded),
            title: const Text("Lista de Categorias de Productos"),
            onTap: () {
              context.pushNamed("product-category");
            },
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
