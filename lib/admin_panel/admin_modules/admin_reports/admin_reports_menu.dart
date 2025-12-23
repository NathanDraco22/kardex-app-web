import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminReportsMenuScreen extends StatelessWidget {
  const AdminReportsMenuScreen({super.key});

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
      appBar: AppBar(
        title: const Text("Finanzas (Reportes)"),
      ),
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
            leading: const Icon(Icons.bar_chart_rounded, color: Colors.blue),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            title: const Text("Resumen Diario"),
            onTap: () => context.pushNamed("daily-summary"),
          ),
          ListTile(
            leading: const Icon(Icons.pie_chart_rounded, color: Colors.purple),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            title: const Text("Resumen Ejecutivo"),
            onTap: () => context.pushNamed("executive-summary"),
          ),
        ],
      ),
    );
  }
}
