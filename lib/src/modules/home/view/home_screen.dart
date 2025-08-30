import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
        title: const Text("Nombre del Sistema"),
      ),
      backgroundColor: Colors.white,
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
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text("Bienvenido, Usuario Numero 1", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          const Text("Elige una opcion", style: TextStyle(fontSize: 18)),

          const SizedBox(height: 12),

          Wrap(
            spacing: 24,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              HomeOptionCard(
                title: "Lista de Clientes",
                icon: FluentIcons.contact_card_16_filled,
                onTap: () {
                  context.pushNamed("client-catalog");
                },
              ),

              HomeOptionCard(
                title: "Lista de Proveedores",
                icon: FluentIcons.building_multiple_20_filled,
                onTap: () {
                  context.pushNamed("suppliers-catalog");
                },
              ),

              HomeOptionCard(
                title: "Catalogo de Productos",
                icon: FluentIcons.receipt_bag_20_filled,
                onTap: () {
                  context.pushNamed("product-catalog");
                },
              ),

              HomeOptionCard(
                title: "Comercio",
                icon: FluentIcons.money_calculator_20_filled,
                onTap: () {
                  context.pushNamed("commercial");
                },
              ),

              HomeOptionCard(
                title: "Inventario",
                icon: FluentIcons.box_toolbox_20_filled,
                onTap: () {
                  context.pushNamed("inventory");
                },
              ),

              HomeOptionCard(
                title: "Configuraciones",
                icon: FluentIcons.settings_20_filled,
                onTap: () {
                  context.pushNamed("settings");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeOptionCard extends StatelessWidget {
  const HomeOptionCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Ink(
        height: 120,
        width: 300,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
            ),

            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
