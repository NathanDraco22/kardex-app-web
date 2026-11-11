import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/menu_app_bar.dart';
import 'package:kardex_app_front/widgets/shortcut_addable_list_tile.dart';
import 'package:kardex_business/kardex_business.dart';

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
      appBar: MenuAppBar(title: 'Gastos'),
      body: ExpensesHubBody(),
    );
  }
}

/// Contenido del hub de gastos.
///
/// Es un widget puro: las rutas y el envoltorio de atajos se resuelven desde
/// las acciones, de modo que puede probarse sin `GetIt`.
class ExpensesHubBody extends StatelessWidget {
  const ExpensesHubBody({
    super.key,
    this.shortcutBuilder,
  });

  /// Permite sustituir el envoltorio de atajos en pruebas o contextos donde
  /// `ShortcutsCubit` no está disponible.
  final Widget Function(String routeName, Widget child)? shortcutBuilder;

  static const Color _rose = Color(0xFFE11D48);
  static const Color _operative = Color(0xFF16A34A);
  static const Color _supplier = Color(0xFFEA580C);

  Widget _wrapShortcut(String routeName, Widget child) {
    return shortcutBuilder?.call(routeName, child) ?? ShortcutAddableListTile(routeName: routeName, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 16.0;

        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _ExpensesHero(),
                  const _HubSectionHeader(title: 'Operación'),
                  _wrapShortcut(
                    RouteNames.operativeExpenses,
                    AppActionTile(
                      icon: Icons.account_balance_wallet_rounded,
                      accentColor: _operative,
                      title: 'Gastos Operativos',
                      subtitle: 'Salidas diarias de caja, servicios y mantenimiento.',
                      onTap: () => context.pushNamed('operative-expenses'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _wrapShortcut(
                    RouteNames.supplierExpenses,
                    AppActionTile(
                      icon: Icons.storefront_rounded,
                      accentColor: _supplier,
                      title: 'Gastos de Proveedores',
                      subtitle: 'Pagos y compras asociadas a proveedores de mercancía y servicios.',
                      onTap: () => context.pushNamed('supplier-expenses'),
                    ),
                  ),
                  const _HubSectionHeader(title: 'Análisis y configuración'),
                  _wrapShortcut(
                    RouteNames.expenseCategories,
                    AppActionTile(
                      icon: Icons.category_rounded,
                      accentColor: AppThemeTokens.indigo,
                      title: 'Categorías de Gastos',
                      subtitle: 'Clasifica conceptos y rubros de egreso para tus reportes.',
                      onTap: () => context.pushNamed('expense-categories'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _wrapShortcut(
                    RouteNames.expensesReport,
                    AppActionTile(
                      icon: Icons.insert_chart_rounded,
                      accentColor: AppThemeTokens.info,
                      title: 'Reporte de Gastos',
                      subtitle: 'Analiza el consolidado de egresos por período y categoría.',
                      onTap: () => context.pushNamed('expenses-report'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _ExpensesTip(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ExpensesHero extends StatelessWidget {
  const _ExpensesHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF1F2),
            Color(0xFFFDF2F8),
            Colors.white,
          ],
        ),
        borderRadius: AppThemeTokens.borderRadiusXl,
        border: Border.all(color: ExpensesHubBody._rose.withValues(alpha: 0.22)),
        boxShadow: AppThemeTokens.subtleCardShadow(accent: ExpensesHubBody._rose),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: ExpensesHubBody._rose.withValues(alpha: 0.12),
              borderRadius: AppThemeTokens.borderRadiusMd,
              border: Border.all(color: ExpensesHubBody._rose.withValues(alpha: 0.24)),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: ExpensesHubBody._rose, size: 27),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Centro de Gastos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Registra, clasifica y analiza todos los egresos de tu negocio desde un solo lugar.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HubSectionHeader extends StatelessWidget {
  const _HubSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 22, 2, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Divider(height: 1, color: AppThemeTokens.borderLight),
          ),
        ],
      ),
    );
  }
}

class _ExpensesTip extends StatelessWidget {
  const _ExpensesTip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppThemeTokens.indigo.withValues(alpha: 0.05),
        borderRadius: AppThemeTokens.borderRadiusMd,
        border: Border.all(color: AppThemeTokens.indigo.withValues(alpha: 0.16)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppThemeTokens.indigo),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Clasifica tus gastos para mejorar los reportes.',
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
