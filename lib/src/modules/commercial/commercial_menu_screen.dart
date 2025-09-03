import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommercialMenuScreen extends StatelessWidget {
  const CommercialMenuScreen({super.key});

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
      appBar: AppBar(title: const Text("Menu Comercio")),
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
            leading: Icon(
              FluentIcons.person_money_20_filled,
              size: 32,
              color: Colors.green.shade600,
            ),
            title: const Text("Facturacion a Clientes"),
            onTap: () {
              context.pushNamed("client-invoice");
            },
          ),

          ListTile(
            leading: Icon(
              FluentIcons.money_calculator_20_filled,
              size: 32,
              color: Colors.blue.shade600,
            ),
            title: const Text("Configuracion de Precios de Productos"),
            onTap: () {
              context.pushNamed("product-price-setting");
            },
          ),
        ],
      ),
    );
  }
}
