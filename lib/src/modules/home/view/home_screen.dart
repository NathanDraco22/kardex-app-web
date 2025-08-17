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
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    icon: Icons.people,
                    onTap: () {
                      context.pushNamed("client-catalog");
                    },
                  ),

                  HomeOptionCard(
                    title: "Lista de Proveedores",
                    icon: Icons.warehouse,
                    onTap: () {
                      context.pushNamed("suppliers-catalog");
                    },
                  ),

                  HomeOptionCard(
                    title: "Catalogo de Productos",
                    icon: Icons.shopping_bag_sharp,
                    onTap: () {
                      context.pushNamed("product-catalog");
                    },
                  ),

                  HomeOptionCard(
                    title: "Inventario",
                    icon: Icons.inventory_2_outlined,
                    onTap: () {
                      context.pushNamed("inventory");
                    },
                  ),

                  HomeOptionCard(
                    title: "Configuraciones",
                    icon: Icons.settings,
                    onTap: () {
                      context.pushNamed("settings");
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
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
