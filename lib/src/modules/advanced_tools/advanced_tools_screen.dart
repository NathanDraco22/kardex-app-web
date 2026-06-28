import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/route_names.dart';
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
        children: [
          ShortcutAddableListTile(
            routeName: RouteNames.productStats,
            child: ListTile(
              leading: const Icon(
                Icons.calculate,
                color: Colors.blue,
                size: 28,
              ),
              title: const Text("Estimación de Productos por Ventas"),
              onTap: () {
                context.pushNamed("product-stats");
              },
            ),
          ),
          const Divider(height: 0.0),

          ShortcutAddableListTile(
            routeName: RouteNames.saleProjection,
            child: ListTile(
              leading: const Icon(
                Icons.calculate,
                color: Colors.green,
                size: 28,
              ),
              title: const Text("Projecion de Ventas"),
              onTap: () {
                context.pushNamed("sale-projection");
              },
            ),
          ),
          const Divider(height: 0.0),
        ],
      ),
    );
  }
}
