import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/devolution_history/read_devolution_history_cubit.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/devolution_history/web/devolution_history_web_screen.dart';

class DevolutionHistoryScreen extends StatelessWidget {
  const DevolutionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final devolutionRepo = context.read<DevolutionsRepository>();

    return BlocProvider(
      create: (context) => ReadDevolutionHistoryCubit(devolutionRepo)..loadDevolutionsHistory(),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const DevolutionHistoryWebScreen();
  }
}
