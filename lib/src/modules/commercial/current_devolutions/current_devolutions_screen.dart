import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/current_devolutions/cubit/read_devolution_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_devolutions/web/current_devolutions_web_screen.dart';

class CurrentDevolutionsScreen extends StatelessWidget {
  const CurrentDevolutionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final devolutionRepo = context.read<DevolutionsRepository>();

    return BlocProvider(
      create: (context) => ReadDevolutionCubit(
        devolutionsRepository: devolutionRepo,
      )..loadAllDevolutions(),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Devoluciones Pendientes")),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const CurrentDevolutionsWebScreen();
  }
}
