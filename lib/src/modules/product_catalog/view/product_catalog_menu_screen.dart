import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_app_front/widgets/shortcut_addable_list_tile.dart';

class ProductCatalogMenuScreen extends StatelessWidget {
  const ProductCatalogMenuScreen({super.key});

  static final accessName = Modules.products.name;

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
      appBar: AppBar(title: const Text("Catálogo de Productos")),
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
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          ShortcutAddableListTile(
            routeName: RouteNames.productList,
            child: MenuOptionCard(
              icon: FluentIcons.cube_12_filled,
              accentColor: const Color(0xFF7C3AED),
              title: "Lista Global de Productos",
              subtitle: "Inventario maestro, precios y códigos de barra",
              onTap: () => context.pushNamed("product-list"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.units,
            child: MenuOptionCard(
              icon: Icons.tag,
              accentColor: Colors.blue.shade600,
              title: "Unidades de Medida de Productos",
              subtitle: "Factores de conversión y unidades de empaque",
              onTap: () => context.pushNamed("units"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.productCategory,
            child: MenuOptionCard(
              icon: Icons.category_rounded,
              accentColor: Colors.orange.shade700,
              title: "Lista de Categorías de Productos",
              subtitle: "Clasificación de familias y líneas de producto",
              onTap: () => context.pushNamed("product-category"),
            ),
          ),
        ],
      ),
    );
  }
}
