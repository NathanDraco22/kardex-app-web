import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_app_front/widgets/menu_app_bar.dart';
import 'package:kardex_app_front/widgets/shortcut_addable_list_tile.dart';

class AdvancedToolsScreen extends StatelessWidget {
  const AdvancedToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MenuAppBar(title: "Herramientas Avanzadas"),
      body: _Body(),
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
            routeName: RouteNames.productStats,
            child: MenuOptionCard(
              icon: Icons.calculate,
              accentColor: Colors.blue.shade600,
              title: "Estimación de Productos por Ventas",
              subtitle: "Cálculo de reposición óptima de inventario",
              onTap: () => context.pushNamed("product-stats"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.saleProjection,
            child: MenuOptionCard(
              icon: Icons.auto_graph_rounded,
              accentColor: Colors.green.shade600,
              title: "Proyección de Ventas",
              subtitle: "Modelos predictivos de demanda mensual",
              onTap: () => context.pushNamed("sale-projection"),
            ),
          ),
        ],
      ),
    );
  }
}
