import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';

class MultibranchHomeScreen extends StatelessWidget {
  const MultibranchHomeScreen({super.key});

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
        title: const Text("Neptuno App"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final authState = authCubit.state;

    if (authState is! Authenticated) {
      return const Center(
        child: Text("Error"),
      );
    }

    final user = authState.session.user;

    return Center(
      child: Column(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              const Text(
                "Bienvenido",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                user.username,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Card(
            child: InkWell(
              onTap: () {},
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                width: 350,
                height: 50,
                child: const Row(
                  spacing: 12,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: Colors.blue,
                    ),
                    Text(
                      "Panel de Administración",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Card(
            child: InkWell(
              onTap: () {},
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                width: 350,
                height: 50,
                child: const Row(
                  spacing: 12,
                  children: [
                    Icon(Icons.store_rounded, color: Colors.blue),
                    Text(
                      "Sucursales",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
