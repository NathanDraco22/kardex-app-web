import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_app_front/widgets/menu_app_bar.dart';
import 'package:kardex_app_front/widgets/shortcut_addable_list_tile.dart';

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
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          ShortcutAddableListTile(
            routeName: RouteNames.operativeExpenses,
            child: MenuOptionCard(
              icon: Icons.monetization_on,
              accentColor: Colors.green.shade600,
              title: "Gastos Operativos",
              subtitle: "Salidas diarias de caja y servicios operativos",
              onTap: () => context.pushNamed("operative-expenses"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.supplierExpenses,
            child: MenuOptionCard(
              icon: Icons.shopping_cart,
              accentColor: Colors.orange.shade700,
              title: "Compras a Proveedores",
              subtitle: "Registro de pagos de mercadería y compras",
              onTap: () => context.pushNamed("supplier-expenses"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.expenseCategories,
            child: MenuOptionCard(
              icon: Icons.category,
              accentColor: Colors.indigo.shade600,
              title: "Categorías de Gastos",
              subtitle: "Clasificación de conceptos y rubros de egreso",
              onTap: () => context.pushNamed("expense-categories"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.expensesReport,
            child: MenuOptionCard(
              icon: Icons.assessment,
              accentColor: Colors.blue.shade600,
              title: "Reporte de Gastos",
              subtitle: "Análisis y consolidado de egresos por período",
              onTap: () => context.pushNamed("expenses-report"),
            ),
          ),
        ],
      ),
    );
  }
}
