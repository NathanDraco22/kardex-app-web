import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/user_role/modules.dart';
import 'package:kardex_app_front/widgets/menu_app_bar.dart';

class ExpensesMenuScreen extends StatelessWidget {
  const ExpensesMenuScreen({super.key});

  static final accessName = Modules.expenses.name;

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
      appBar: MenuAppBar(title: "Gastos"),
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
          ListTile(
            leading: const Icon(Icons.monetization_on, color: Colors.green),
            title: const Text("Gastos Operativos"),
            onTap: () => context.pushNamed("operative-expenses"),
          ),
          const Divider(height: 0.0),
          ListTile(
            leading: const Icon(Icons.shopping_cart, color: Colors.orange),
            title: const Text("Compras a Proveedores"),
            onTap: () => context.pushNamed("supplier-expenses"),
          ),
          const Divider(height: 0.0),
          ListTile(
            leading: const Icon(Icons.assessment, color: Colors.blue),
            title: const Text("Reporte de Gastos"),
            onTap: () => context.pushNamed("expenses-report"),
          ),
          const Divider(height: 0.0),
        ],
      ),
    );
  }
}
